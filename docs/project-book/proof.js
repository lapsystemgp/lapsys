/* Content proof: docx -> HTML (mammoth) with inline images, for visual QA via Chrome. */
const mammoth = require("mammoth");
const fs = require("fs");
const path = require("path");
const DIR = __dirname;
const src = path.join(DIR, "TesTly-Project-Book.docx");

mammoth.convertToHtml({ path: src }, {
  convertImage: mammoth.images.imgElement((image) =>
    image.read("base64").then((b) => ({ src: `data:${image.contentType};base64,${b}` }))),
}).then((r) => {
  const css = `
  @page { size: Letter; margin: 18mm 16mm; }
  body { font-family: 'Times New Roman', serif; font-size: 12pt; color: #1A1A1A; line-height: 1.5; }
  h1 { color: #0B5294; font-size: 18pt; }
  h2 { color: #0F6FC6; font-size: 14pt; }
  h3 { color: #0F6FC6; font-size: 13pt; }
  img { max-width: 92%; display:block; margin: 8px auto; }
  table { border-collapse: collapse; width: 100%; margin: 8px 0; font-size: 10.5pt; }
  td, th { border: 1px solid #B9CDE8; padding: 4px 8px; }
  p { text-align: justify; margin: 4px 0; }`;
  const html = `<!doctype html><html><head><meta charset="utf-8"><style>${css}</style></head><body>${r.value}</body></html>`;
  fs.writeFileSync(path.join(DIR, "proof.html"), html);
  const warns = r.messages.filter((m) => m.type === "warning").length;
  console.log(`✓ proof.html written (${(html.length / 1024).toFixed(0)} KB, ${warns} mammoth warnings)`);
}).catch((e) => { console.error("PROOF FAILED:", e); process.exit(1); });
