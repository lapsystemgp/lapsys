/* Builds a single self-contained TesTly-Tech-Presentation.html
 * from presentation/app-template.html + presentation/decks/*.json + diagrams/png/*.png */
const fs = require("fs");
const path = require("path");
const DIR = __dirname;
const P = (...a) => path.join(DIR, ...a);

const ids = ["backend", "frontend", "mobile", "ai"];
const decks = {};
for (const id of ids) {
  try { decks[id] = JSON.parse(fs.readFileSync(P("presentation/decks", id + ".json"), "utf8")); }
  catch (e) { console.warn(`! ${id}.json missing/invalid`); decks[id] = []; }
}

// collect referenced diagram ids
const used = new Set();
for (const id of ids) for (const s of decks[id]) if (s && s.image) used.add(s.image);

const images = {};
let embedded = 0, bytes = 0;
for (const img of used) {
  const p = P("diagrams/png", img + ".png");
  if (fs.existsSync(p)) {
    images[img] = "data:image/png;base64," + fs.readFileSync(p).toString("base64");
    embedded++; bytes += fs.statSync(p).size;
  } else console.warn(`! diagram missing: ${img}`);
}

// only escape "</" so the JSON can't break out of the <script> tag
const safe = (obj) => JSON.stringify(obj).split("</").join("<\\/");

let html = fs.readFileSync(P("presentation/app-template.html"), "utf8");
html = html.replace('"@@DECKS@@"', safe(decks)).replace('"@@IMAGES@@"', safe(images));

const out = P("TesTly-Tech-Presentation.html");
fs.writeFileSync(out, html);
const total = ids.reduce((n, id) => n + decks[id].length, 0);
console.log(`OK ${path.basename(out)}  (${(html.length / 1024 / 1024).toFixed(2)} MB)`);
console.log(`   ${total} slides / ${ids.length} decks; ${embedded} diagrams embedded (${(bytes / 1024 / 1024).toFixed(2)} MB raw)`);
