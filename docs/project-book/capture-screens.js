/* Capture real TesTly web screens → diagrams/png/screen-*.png (for the project book).
 *
 * Prereqs: backend on :3001 (seeded Neon/local DB) and frontend on :3000.
 *   apps/backend:  rm -f tsconfig*.tsbuildinfo && npx tsc -p tsconfig.build.json && PORT=3001 node dist/main
 *   apps/frontend: echo 'NEXT_PUBLIC_API_BASE_URL="http://localhost:3001"' > .env.local && npm run dev
 * Then from repo root:  node docs/project-book/capture-screens.js
 *
 * Auth note: dev is cross-origin (:3000 → :3001). We mint a JWT via /auth/login and add it as an
 * `access_token` cookie on domain `localhost` so the Next middleware (:3000) authenticates too.
 */
const { chromium } = require("playwright");
const path = require("path");

const WEB = "http://localhost:3000";
const API = "http://localhost:3001";
const OUT = path.join(__dirname, "diagrams", "png");
const HIDE = "nextjs-portal{display:none!important}"; // hide the Next dev-tools badge

async function token(email, selectedRole) {
  const r = await fetch(`${API}/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password: "password123", selectedRole }),
  });
  if (!r.ok) throw new Error(`login ${email} failed: ${r.status}`);
  return (await r.json()).access_token;
}

async function authedContext(browser, email, role, viewport = { width: 1440, height: 900 }) {
  const ctx = await browser.newContext({ viewport, deviceScaleFactor: 2 });
  const t = await token(email, role);
  await ctx.addCookies([{ name: "access_token", value: t, domain: "localhost", path: "/", sameSite: "Lax" }]);
  return ctx;
}

async function shoot(ctx, urlPath, file, opts = {}) {
  const page = await ctx.newPage();
  try {
    await page.goto(WEB + urlPath, { waitUntil: "domcontentloaded", timeout: 30000 });
    try { await page.waitForLoadState("networkidle", { timeout: 9000 }); } catch {}
    if (opts.beforeShot) { try { await opts.beforeShot(page); } catch (e) { console.log(`   (beforeShot ${file}: ${e.message})`); } }
    if (opts.waitFor) { try { await page.waitForSelector(opts.waitFor, { timeout: 12000 }); } catch (e) { console.log(`   (waitFor ${file}: ${e.message})`); } }
    await page.addStyleTag({ content: HIDE }).catch(() => {});
    await page.waitForTimeout(opts.wait || 1800);
    await page.screenshot({ path: path.join(OUT, file), fullPage: false });
    console.log(`✓ ${file}  (${page.url()})`);
  } catch (e) {
    console.log(`✗ ${file}: ${e.message}`);
  } finally {
    await page.close();
  }
}

(async () => {
  // resolve a real test (name + category — the comparison page needs both) and a real lab id
  const tests = await (await fetch(`${API}/public/tests?limit=80`)).json();
  const items = tests.items || [];
  const t = ["Complete Blood Count", "CBC", "Lipid", "Vitamin D", "Glucose", "HbA1c", "Thyroid"]
    .map((k) => items.find((i) => i.name.includes(k))).find(Boolean) || items[0];
  const testPath = `/tests/${encodeURIComponent(t.name)}?category=${encodeURIComponent(t.category)}`;
  const labId = (await (await fetch(`${API}/public/labs?limit=1`)).json()).items[0].id;

  const browser = await chromium.launch();

  // public
  const pub = await browser.newContext({ viewport: { width: 1440, height: 900 }, deviceScaleFactor: 2 });
  await shoot(pub, "/", "screen-landing.png");
  await shoot(pub, "/labs", "screen-labs.png");
  await shoot(pub, testPath, "screen-test-comparison.png");
  await shoot(pub, "/labs/" + labId, "screen-lab-detail.png");
  await pub.close();

  // patient
  const patient = await authedContext(browser, "patient@testly.com", "patient");
  await shoot(patient, "/patient/dashboard", "screen-patient-dashboard.png");
  await shoot(patient, "/patient/assistant", "screen-ai-assistant.png");
  await shoot(patient, "/labs/" + labId, "screen-booking.png", {
    beforeShot: async (p) => { await p.getByRole("button", { name: /book/i }).first().click({ timeout: 8000 }); await p.waitForURL(/booking/, { timeout: 10000 }); },
    waitFor: "text=/visit lab|home collection|select a slot/i",
  });
  await patient.close();

  // patient trends (taller viewport so a chart is in frame; wait for the recharts svg)
  const patientTall = await authedContext(browser, "patient@testly.com", "patient", { width: 1440, height: 1040 });
  await shoot(patientTall, "/patient/dashboard", "screen-patient-trends.png", {
    beforeShot: async (p) => { await p.getByRole("button", { name: /trends/i }).first().click({ timeout: 6000 }); },
    waitFor: ".recharts-surface",
    wait: 2200,
  });
  await patientTall.close();

  // lab staff (active lab) + admin
  const lab = await authedContext(browser, "pharaohsmedicallab@testly.com", "lab");
  await shoot(lab, "/lab/dashboard", "screen-lab-dashboard.png");
  await lab.close();

  const admin = await authedContext(browser, "admin@testly.com", "admin");
  await shoot(admin, "/admin/dashboard", "screen-admin-dashboard.png");
  await admin.close();

  await browser.close();
  console.log("done.");
})().catch((e) => { console.error("CAPTURE FAILED:", e); process.exit(1); });
