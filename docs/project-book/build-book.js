/* TesTly — Graduation Project Book generator
 * Suez Canal University · Faculty of Computers and Informatics · Dept. of Information Systems
 * Produces TesTly-Project-Book.docx from content/*.json + diagrams/png/*.png
 */
const fs = require("fs");
const path = require("path");
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell, ImageRun,
  Header, Footer, AlignmentType, LevelFormat, TableOfContents, HeadingLevel,
  BorderStyle, WidthType, ShadingType, PageNumber, PageBreak, Bookmark,
  InternalHyperlink, ExternalHyperlink, SimpleField, TabStopType, TabStopPosition,
  VerticalAlign, NumberFormat,
} = require("docx");

const DIR = __dirname;
const C = (p) => path.join(DIR, p);

/* ---------- palette / metrics ---------- */
const COL = { title: "03485B", h1: "0B5294", h2: "0F6FC6", h3: "0F6FC6", text: "1A1A1A", muted: "555555", rule: "0F6FC6", tableHead: "0B5294", tableHeadText: "FFFFFF", zebra: "EAF1FB", border: "B9CDE8" };
const FONT = "Times New Roman";
const MONO = "Consolas";
const CONTENT_W = 12240 - 1800 - 1440; // = 9000 dxa
const FIG_MAX_PX = 600; // ~ content width at 96dpi
const FIG_MAX_H = 760;

/* ---------- meta ---------- */
const TEAM = [
  "Youssef Ahmed Mahmoud", "Mariam Hassan Ali", "Omar Khaled Ibrahim", "Nourhan Mohamed Saad",
  "Ahmed Sami Fathy", "Salma Tarek Abdelrahman", "Mostafa Adel Hosny", "Habiba Walid Mansour",
];
const SUPERVISOR = "Dr. Mohamed Ibrahim";
const TITLE = "TesTly";
const SUBTITLE = "A Smart Marketplace for Medical Laboratory Testing";
const DEPT = "Department of Information Systems";
const DEGREE = "Bachelor of Science in Information Systems";
const YEAR = "2026";

/* ---------- helpers: load ---------- */
function loadJSON(rel, fb) {
  try { return JSON.parse(fs.readFileSync(C(rel), "utf8")); }
  catch (e) { console.warn(`! missing/invalid ${rel} — using fallback`); return fb; }
}
function pngSize(rel) {
  try {
    const b = fs.readFileSync(C(rel));
    if (b.length > 24 && b[0] === 0x89 && b[1] === 0x50) {
      return { w: b.readUInt32BE(16), h: b.readUInt32BE(20) };
    }
  } catch (e) {}
  return null;
}

/* ---------- helpers: inline markdown (**bold**, `code`) ---------- */
function parseInline(text, base = {}) {
  const runs = [];
  const re = /(\*\*([^*]+)\*\*|`([^`]+)`)/g;
  let last = 0, m;
  const push = (t, extra) => { if (t) runs.push(new TextRun({ text: t, font: FONT, size: 24, color: COL.text, ...base, ...extra })); };
  while ((m = re.exec(text)) !== null) {
    push(text.slice(last, m.index));
    if (m[2] !== undefined) push(m[2], { bold: true });
    else if (m[3] !== undefined) runs.push(new TextRun({ text: m[3], font: MONO, size: 21, color: "B03A2E", ...base }));
    last = re.lastIndex;
  }
  push(text.slice(last));
  return runs.length ? runs : [new TextRun({ text: "", font: FONT, size: 24 })];
}

/* ---------- helpers: building blocks ---------- */
const body = (text, opts = {}) => new Paragraph({
  children: parseInline(text), alignment: AlignmentType.JUSTIFIED,
  spacing: { line: 360, after: 140 }, ...opts,
});
const center = (children, opts = {}) => new Paragraph({ children, alignment: AlignmentType.CENTER, ...opts });
const spacer = (after = 120) => new Paragraph({ children: [new TextRun("")], spacing: { after } });

function bullets(items, ref = "bul") {
  return items.map((it) => new Paragraph({
    children: parseInline(it), numbering: { reference: ref, level: 0 },
    alignment: AlignmentType.JUSTIFIED, spacing: { line: 320, after: 60 },
  }));
}
function numbered(items, ref = "num") {
  return items.map((it) => new Paragraph({
    children: parseInline(it), numbering: { reference: ref, level: 0 },
    alignment: AlignmentType.JUSTIFIED, spacing: { line: 320, after: 60 },
  }));
}

function codeBlock(text) {
  const lines = String(text).split("\n");
  return new Table({
    width: { size: CONTENT_W, type: WidthType.DXA }, columnWidths: [CONTENT_W],
    rows: [new TableRow({
      children: [new TableCell({
        width: { size: CONTENT_W, type: WidthType.DXA },
        shading: { fill: "F4F6F8", type: ShadingType.CLEAR },
        borders: allBorders("D6DCE4"),
        margins: { top: 80, bottom: 80, left: 140, right: 140 },
        children: lines.map((ln) => new Paragraph({
          children: [new TextRun({ text: ln || " ", font: MONO, size: 19, color: "263238" })],
          spacing: { line: 240, after: 0 },
        })),
      })],
    })],
  });
}

const border1 = (color) => ({ style: BorderStyle.SINGLE, size: 4, color });
const allBorders = (color = COL.border) => ({ top: border1(color), bottom: border1(color), left: border1(color), right: border1(color) });

function dataTable(headers, rows, widths) {
  const n = headers.length;
  const colW = widths || Array(n).fill(Math.floor(CONTENT_W / n));
  const sum = colW.reduce((a, b) => a + b, 0);
  colW[colW.length - 1] += CONTENT_W - sum; // fix rounding
  const headRow = new TableRow({
    tableHeader: true,
    children: headers.map((h, i) => new TableCell({
      width: { size: colW[i], type: WidthType.DXA },
      shading: { fill: COL.tableHead, type: ShadingType.CLEAR },
      margins: { top: 60, bottom: 60, left: 110, right: 110 },
      verticalAlign: VerticalAlign.CENTER, borders: allBorders(COL.tableHead),
      children: [new Paragraph({ children: [new TextRun({ text: String(h), bold: true, color: COL.tableHeadText, font: FONT, size: 21 })], alignment: AlignmentType.LEFT, spacing: { line: 260, after: 0 } })],
    })),
  });
  const dataRows = rows.map((r, ri) => new TableRow({
    children: r.map((cell, i) => new TableCell({
      width: { size: colW[i], type: WidthType.DXA },
      shading: { fill: ri % 2 ? COL.zebra : "FFFFFF", type: ShadingType.CLEAR },
      margins: { top: 50, bottom: 50, left: 110, right: 110 },
      verticalAlign: VerticalAlign.CENTER, borders: allBorders(),
      children: [new Paragraph({ children: parseInline(String(cell == null ? "" : cell)).map((t) => { t.options && (t.options.size = 21); return t; }), spacing: { line: 260, after: 0 } })],
    })),
  }));
  return new Table({ width: { size: CONTENT_W, type: WidthType.DXA }, columnWidths: colW, rows: [headRow, ...dataRows] });
}

/* caption (bookmarked) + list entry with PAGEREF */
function caption(kind, num, text, bm) {
  return new Paragraph({
    alignment: AlignmentType.CENTER, spacing: { before: 80, after: 200 },
    children: [new Bookmark({ id: bm, children: [
      new TextRun({ text: `${kind} ${num}: `, bold: true, italics: true, font: FONT, size: 20, color: COL.muted }),
      new TextRun({ text, italics: true, font: FONT, size: 20, color: COL.muted }),
    ] })],
  });
}
function listEntry(label, text, bm) {
  return new Paragraph({
    tabStops: [{ type: TabStopType.RIGHT, position: 9000, leader: "dot" }],
    spacing: { line: 300, after: 40 },
    children: [
      new InternalHyperlink({ anchor: bm, children: [new TextRun({ text: `${label}  ${text}`, font: FONT, size: 22, color: COL.text })] }),
      new TextRun({ text: "\t", font: FONT, size: 22 }),
      new SimpleField(`PAGEREF ${bm} \\h`),
    ],
  });
}

function figureBlock(ref, num, cap, bm) {
  const rel = `diagrams/png/${ref}.png`;
  const size = pngSize(rel);
  if (!size) {
    return [new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 120, after: 60 },
      children: [new TextRun({ text: `[ figure: ${ref} — pending ]`, italics: true, color: COL.muted, font: FONT, size: 22 })] }),
      caption("Figure", num, cap, bm)];
  }
  let w = size.w / 2, h = size.h / 2; // rendered @2x
  if (w > FIG_MAX_PX) { h = h * (FIG_MAX_PX / w); w = FIG_MAX_PX; }
  if (h > FIG_MAX_H) { w = w * (FIG_MAX_H / h); h = FIG_MAX_H; }
  return [
    new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 160, after: 40 },
      children: [new ImageRun({ type: "png", data: fs.readFileSync(C(rel)), transformation: { width: Math.round(w), height: Math.round(h) },
        altText: { title: cap, description: cap, name: ref } })] }),
    caption("Figure", num, cap, bm),
  ];
}

/* ---------- heading helpers ---------- */
const chapterHeading = (num, title) => new Paragraph({
  heading: HeadingLevel.HEADING_1, pageBreakBefore: true, alignment: AlignmentType.CENTER,
  spacing: { before: 240, after: 260 },
  children: [new TextRun({ text: `Chapter ${num}`, break: 0 })],
});
function chapterTitlePara(num, title) {
  // two-line chapter opener; H1 carries the TOC entry
  return [
    new Paragraph({ alignment: AlignmentType.CENTER, pageBreakBefore: true, spacing: { before: 1200, after: 0 },
      children: [new TextRun({ text: `Chapter ${num}`, bold: true, font: FONT, size: 36, color: COL.h2 })] }),
    new Paragraph({ heading: HeadingLevel.HEADING_1, alignment: AlignmentType.CENTER, spacing: { before: 120, after: 80 },
      children: [new TextRun({ text: title })] }),
    new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 320 },
      border: { bottom: { style: BorderStyle.SINGLE, size: 12, color: COL.rule, space: 8 } }, children: [new TextRun("")] }),
  ];
}
const h2 = (num, text) => new Paragraph({ heading: HeadingLevel.HEADING_2, spacing: { before: 220, after: 110 },
  children: [new TextRun({ text: `${num}  ${text}` })] });
const h3 = (num, text) => new Paragraph({ heading: HeadingLevel.HEADING_3, spacing: { before: 160, after: 80 },
  children: [new TextRun({ text: `${num}  ${text}` })] });

/* ---------- pre-pass: assign figure/table numbers ---------- */
function preprocess(chapters) {
  const figs = [], tabs = [];
  for (const ch of chapters) {
    let f = 0, t = 0;
    for (const b of ch.blocks) {
      if (b.t === "figure") { f++; b.__num = `${ch.num}.${f}`; b.__bm = `fig_${ch.num}_${f}`; figs.push({ label: `Figure ${b.__num}`, text: b.caption || b.ref, bm: b.__bm }); }
      if (b.t === "table") { t++; b.__num = `${ch.num}.${t}`; b.__bm = `tab_${ch.num}_${t}`; tabs.push({ label: `Table ${b.__num}`, text: b.caption || "", bm: b.__bm }); }
    }
  }
  return { figs, tabs };
}

/* ---------- render a block ---------- */
function renderBlock(b) {
  switch (b.t) {
    case "h2": return [h2(b.num, b.text)];
    case "h3": return [h3(b.num, b.text)];
    case "h4": return [new Paragraph({ heading: HeadingLevel.HEADING_4, spacing: { before: 120, after: 60 }, children: [new TextRun({ text: `${b.num ? b.num + "  " : ""}${b.text}` })] })];
    case "p": return [body(b.text)];
    case "b": return bullets(b.items);
    case "n": return numbered(b.items);
    case "code": return [codeBlock(b.text), spacer(80)];
    case "callout": return [new Table({ width: { size: CONTENT_W, type: WidthType.DXA }, columnWidths: [CONTENT_W], rows: [new TableRow({ children: [new TableCell({
      width: { size: CONTENT_W, type: WidthType.DXA }, shading: { fill: "EAF1FB", type: ShadingType.CLEAR },
      borders: { left: { style: BorderStyle.SINGLE, size: 18, color: COL.h2 }, top: border1("D6E2F2"), bottom: border1("D6E2F2"), right: border1("D6E2F2") },
      margins: { top: 80, bottom: 80, left: 160, right: 140 },
      children: [new Paragraph({ children: [new TextRun({ text: (b.title || "Note") + ": ", bold: true, font: FONT, size: 22, color: COL.h1 }), ...parseInline(b.text)], spacing: { line: 300 } })],
    })] })] }), spacer(80)];
    case "table": return [dataTable(b.headers, b.rows, b.widths), caption("Table", b.__num || "", b.caption || "", b.__bm || "tab_x"), spacer(60)];
    case "figure": return figureBlock(b.ref, b.__num || "", b.caption || b.ref, b.__bm || `fig_${b.ref}`);
    default: return [];
  }
}

/* ---------- title pages ---------- */
function logoRow() {
  const uni = C("assets/logo-university.jpeg"), fac = C("assets/logo-faculty.jpeg");
  const imgs = [];
  if (fs.existsSync(uni)) imgs.push(new ImageRun({ type: "jpg", data: fs.readFileSync(uni), transformation: { width: 96, height: 96 }, altText: { title: "Suez Canal University", description: "logo", name: "uni" } }));
  imgs.push(new TextRun({ text: "      " }));
  if (fs.existsSync(fac)) imgs.push(new ImageRun({ type: "jpg", data: fs.readFileSync(fac), transformation: { width: 96, height: 92 }, altText: { title: "Faculty of Computers and Informatics", description: "logo", name: "fac" } }));
  return center(imgs, { spacing: { after: 160 } });
}
const tline = (text, opts) => center([new TextRun({ text, font: FONT, ...opts })]);

function titlePage1() {
  return [
    logoRow(),
    tline("Suez Canal University", { size: 28, bold: true, color: COL.title }),
    tline("Faculty of Computers and Informatics", { size: 26, bold: true, color: COL.title }),
    tline(DEPT, { size: 24, bold: true, color: COL.h1 }),
    spacer(700),
    tline(TITLE, { size: 76, bold: true, color: COL.title }),
    center([new TextRun({ text: SUBTITLE, font: FONT, size: 30, italics: true, color: COL.h1 })], { spacing: { before: 120, after: 700 } }),
    tline("A Graduation Project Submitted to the Faculty of Computers and Informatics,", { size: 22 }),
    tline("in Partial Fulfillment of the Requirements for the", { size: 22 }),
    tline(`Degree of ${DEGREE}`, { size: 22 }),
    spacer(420),
    tline("Supervised by", { size: 22, italics: true }),
    tline(SUPERVISOR, { size: 26, bold: true, color: COL.h1 }),
    spacer(520),
    tline(`Ismailia, Egypt`, { size: 22 }),
    tline(YEAR, { size: 22, bold: true }),
  ];
}
function titlePage2() {
  const rows = [new TableRow({ tableHeader: true, children: ["#", "Full Name"].map((h, i) => new TableCell({
    width: { size: i ? 6400 : 900, type: WidthType.DXA }, shading: { fill: COL.tableHead, type: ShadingType.CLEAR },
    margins: { top: 70, bottom: 70, left: 120, right: 120 }, verticalAlign: VerticalAlign.CENTER, borders: allBorders(COL.tableHead),
    children: [new Paragraph({ alignment: i ? AlignmentType.LEFT : AlignmentType.CENTER, children: [new TextRun({ text: h, bold: true, color: "FFFFFF", font: FONT, size: 24 })] })],
  })) })];
  TEAM.forEach((name, idx) => rows.push(new TableRow({ children: [
    new TableCell({ width: { size: 900, type: WidthType.DXA }, verticalAlign: VerticalAlign.CENTER, borders: allBorders(), shading: { fill: idx % 2 ? COL.zebra : "FFFFFF", type: ShadingType.CLEAR }, margins: { top: 60, bottom: 60, left: 120, right: 120 }, children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: String(idx + 1), font: FONT, size: 24 })] })] }),
    new TableCell({ width: { size: 6400, type: WidthType.DXA }, verticalAlign: VerticalAlign.CENTER, borders: allBorders(), shading: { fill: idx % 2 ? COL.zebra : "FFFFFF", type: ShadingType.CLEAR }, margins: { top: 60, bottom: 60, left: 120, right: 120 }, children: [new Paragraph({ children: [new TextRun({ text: name, font: FONT, size: 24 })] })] }),
  ] })));
  const table = new Table({ width: { size: 7300, type: WidthType.DXA }, columnWidths: [900, 6400], alignment: AlignmentType.CENTER, rows });
  return [
    new Paragraph({ pageBreakBefore: true, alignment: AlignmentType.CENTER, spacing: { before: 600, after: 80 }, children: [new TextRun({ text: TITLE, font: FONT, size: 64, bold: true, color: COL.title })] }),
    center([new TextRun({ text: SUBTITLE, font: FONT, size: 28, italics: true, color: COL.h1 })], { spacing: { after: 600 } }),
    tline("Under the Supervision of", { size: 24, italics: true }),
    tline(SUPERVISOR, { size: 28, bold: true, color: COL.h1 }),
    spacer(500),
    tline("Team Members", { size: 26, bold: true, color: COL.title }),
    spacer(120),
    table,
  ];
}

/* ---------- front-matter sections ---------- */
function sectionTitle(text, opts = {}) {
  return new Paragraph({ heading: HeadingLevel.HEADING_1, alignment: AlignmentType.CENTER, spacing: { before: 200, after: 200 }, pageBreakBefore: true, children: [new TextRun({ text })], ...opts });
}
function plainSectionTitle(text) {
  // not in TOC
  return new Paragraph({ alignment: AlignmentType.CENTER, pageBreakBefore: true, spacing: { before: 200, after: 220 }, children: [new TextRun({ text, bold: true, font: FONT, size: 34, color: COL.h1 })] });
}

/* ---------- MAIN ---------- */
function build() {
  const fm = loadJSON("content/frontmatter.json", { abstract: ["[Abstract pending.]"], acknowledgement: ["[Acknowledgement pending.]"], abbreviations: [["API", "Application Programming Interface"]], references: ["[1] Reference pending."] });
  const ar = loadJSON("content/arabic.json", { abstract_ar: ["[الملخص قيد الإعداد]"], title_ar: TITLE, supervisor_ar: "د.", team_ar: TEAM });
  const ch = (f) => loadJSON(`content/${f}.json`, [{ t: "p", text: `[${f} content pending.]` }]);
  const chapters = [
    { num: 1, title: "Introduction", blocks: ch("ch1") },
    { num: 2, title: "Related Work", blocks: ch("ch2") },
    { num: 3, title: "Methodologies and Tools", blocks: ch("ch3") },
    { num: 4, title: "Design and Implementation", blocks: [].concat(ch("ch4a"), ch("ch4b")) },
    { num: 5, title: "Testing and Evaluation", blocks: ch("ch5") },
    { num: 6, title: "Conclusions and Future Work", blocks: ch("ch6") },
  ];
  const { figs, tabs } = preprocess(chapters);

  /* front matter children */
  const front = [];
  front.push(sectionTitle("Abstract"));
  fm.abstract.forEach((p) => front.push(body(p)));
  front.push(sectionTitle("Acknowledgement"));
  fm.acknowledgement.forEach((p) => front.push(body(p)));

  front.push(new Paragraph({ pageBreakBefore: true, alignment: AlignmentType.CENTER, spacing: { before: 120, after: 200 }, children: [new TextRun({ text: "Table of Contents", bold: true, font: FONT, size: 34, color: COL.h1 })] }));
  front.push(new TableOfContents("Table of Contents", { hyperlink: true, headingStyleRange: "1-3" }));

  front.push(plainSectionTitle("List of Figures"));
  if (figs.length) figs.forEach((f) => front.push(listEntry(f.label, f.text, f.bm)));
  else front.push(body("[ no figures ]"));

  front.push(plainSectionTitle("List of Tables"));
  if (tabs.length) tabs.forEach((t) => front.push(listEntry(t.label, t.text, t.bm)));
  else front.push(body("[ no tables ]"));

  front.push(plainSectionTitle("List of Abbreviations"));
  front.push(dataTable(["Abbreviation", "Meaning"], fm.abbreviations, [2600, CONTENT_W - 2600]));

  /* chapters */
  const bodyChildren = [];
  for (const c of chapters) {
    chapterTitlePara(c.num, c.title).forEach((p) => bodyChildren.push(p));
    for (const b of c.blocks) renderBlock(b).forEach((el) => bodyChildren.push(el));
  }

  /* references */
  bodyChildren.push(sectionTitle("References"));
  (fm.references || []).forEach((r) => bodyChildren.push(new Paragraph({ children: parseInline(r), spacing: { line: 300, after: 100 }, indent: { left: 360, hanging: 360 } })));

  /* arabic abstract + title (RTL) */
  const rtl = (text, opts = {}) => new Paragraph({ bidirectional: true, alignment: AlignmentType.RIGHT, spacing: { line: 360, after: 140 }, children: [new TextRun({ text, font: "Arial", size: 24, rightToLeft: true, ...opts })], ...opts.p });
  const rtlCenter = (text, o = {}) => new Paragraph({ bidirectional: true, alignment: AlignmentType.CENTER, spacing: { after: o.after || 160 }, children: [new TextRun({ text, font: "Arial", rightToLeft: true, ...o })] });
  bodyChildren.push(new Paragraph({ pageBreakBefore: true, bidirectional: true, alignment: AlignmentType.CENTER, spacing: { before: 120, after: 220 }, children: [new TextRun({ text: "ملخص المشروع", bold: true, font: "Arial", size: 34, color: COL.h1, rightToLeft: true })] }));
  (ar.abstract_ar || []).forEach((p) => bodyChildren.push(rtl(p)));

  // arabic title page
  bodyChildren.push(rtlCenter(ar.university_ar || "جامعة قناة السويس - كلية الحاسبات والمعلوماتية", { size: 28, bold: true, color: COL.title, after: 80 }));
  bodyChildren.push(rtlCenter(ar.subtitle_ar || "", { size: 24, bold: true, color: COL.h1, after: 600 }));
  bodyChildren.push(rtlCenter(ar.title_ar || TITLE, { size: 52, bold: true, color: COL.title, after: 160 }));
  bodyChildren.push(rtlCenter(ar.degree_ar || "", { size: 24, after: 400 }));
  bodyChildren.push(rtlCenter(ar.supervisor_label_ar || "تحت إشراف:", { size: 24, italics: true, after: 60 }));
  bodyChildren.push(rtlCenter(ar.supervisor_ar || "", { size: 28, bold: true, color: COL.h1, after: 360 }));
  bodyChildren.push(rtlCenter(ar.team_label_ar || "فريق العمل:", { size: 26, bold: true, color: COL.title, after: 120 }));
  (ar.team_ar || TEAM).forEach((n) => bodyChildren.push(rtlCenter(n, { size: 24, after: 40 })));
  bodyChildren.push(rtlCenter(ar.place_year_ar || `الإسماعيلية، مصر - ${YEAR}`, { size: 22, after: 0 }));

  /* ---------- document ---------- */
  const pageProps = { size: { width: 12240, height: 15840 }, margin: { top: 1440, right: 1440, bottom: 1440, left: 1800, header: 720, footer: 600 } };
  const numberFooter = new Footer({ children: [new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: "", font: FONT, size: 20 }), new TextRun({ children: [PageNumber.CURRENT], font: FONT, size: 20, color: COL.muted })] })] });
  const emptyFooter = new Footer({ children: [new Paragraph({ children: [new TextRun("")] })] });

  const doc = new Document({
    creator: "TesTly Team", title: "TesTly — Graduation Project Book", description: "Graduation Project Book",
    styles: {
      default: { document: { run: { font: FONT, size: 24, color: COL.text } } },
      paragraphStyles: [
        { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true, run: { font: FONT, size: 36, bold: true, color: COL.h1 }, paragraph: { spacing: { before: 240, after: 200 }, outlineLevel: 0, keepNext: true } },
        { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true, run: { font: FONT, size: 28, bold: true, color: COL.h2 }, paragraph: { spacing: { before: 200, after: 100 }, outlineLevel: 1, keepNext: true } },
        { id: "Heading3", name: "Heading 3", basedOn: "Normal", next: "Normal", quickFormat: true, run: { font: FONT, size: 26, bold: true, color: COL.h3 }, paragraph: { spacing: { before: 160, after: 80 }, outlineLevel: 2, keepNext: true } },
        { id: "Heading4", name: "Heading 4", basedOn: "Normal", next: "Normal", quickFormat: true, run: { font: FONT, size: 24, bold: true, color: COL.text }, paragraph: { spacing: { before: 120, after: 60 }, outlineLevel: 3, keepNext: true } },
      ],
    },
    numbering: {
      config: [
        { reference: "bul", levels: [{ level: 0, format: LevelFormat.BULLET, text: "•", alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 620, hanging: 320 } } } }] },
        { reference: "num", levels: [{ level: 0, format: LevelFormat.DECIMAL, text: "%1.", alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 620, hanging: 320 } } } }] },
      ],
    },
    sections: [
      { properties: { page: pageProps, titlePage: true }, footers: { default: emptyFooter, first: emptyFooter }, children: [...titlePage1(), ...titlePage2()] },
      { properties: { page: pageProps, type: "nextPage" }, footers: { default: numberFooter }, children: [...front, ...bodyChildren] },
    ],
  });

  return Packer.toBuffer(doc).then((buf) => {
    const out = C("TesTly-Project-Book.docx");
    fs.writeFileSync(out, buf);
    console.log(`✓ wrote ${out} (${(buf.length / 1024).toFixed(0)} KB)`);
    console.log(`  figures: ${figs.length}, tables: ${tabs.length}, chapters: ${chapters.length}`);
  });
}

build().catch((e) => { console.error("BUILD FAILED:", e); process.exit(1); });
