# TesTly — Graduation Project Book

Generates **`TesTly-Project-Book.docx`** — the graduation thesis for *TesTly* (a medical
lab-testing marketplace), formatted to the Suez Canal University · Faculty of Computers and
Informatics template.

## ⚠️ Do this first when you open the .docx in Word

The Table of Contents, List of Figures, List of Tables, and their page numbers are **Word
fields** — they appear empty until you update them once:

1. Open `TesTly-Project-Book.docx` in **Microsoft Word**.
2. Select all: **Cmd + A** (Mac) / **Ctrl + A** (Windows).
3. Press **F9** → choose **“Update entire table”** (do it twice if prompted).

That populates the TOC, the figure/table lists, and every page number. To export a PDF:
**File → Save As / Export → PDF**.

## Things to review / replace before submission

These were filled with sensible defaults — change them to your real values (in `build-book.js`):

- **Department & degree:** *Information Systems* (template originally said Computer Science).
- **Supervisor:** `Dr. Mohamed Ibrahim` — **dummy**, replace with the real supervisor.
- **Team:** 8 **dummy** names (`TEAM` array in `build-book.js`, and Arabic in `content/arabic.json`).
- **Year:** 2026. University / faculty / logos are kept exactly from the template.

## Regenerate

```bash
cd docs/project-book
node build-book.js        # assembles the .docx from content/ + diagrams/
python3 fix-bookmarks.py  # makes bookmark ids unique (docx-js stamps them all "1")
```

Optional content proof (no Word/LibreOffice needed):
```bash
node proof.js             # docx -> proof.html via mammoth (content check only, not true layout)
```

## How it’s built

| Folder / file | What it is |
|---|---|
| `build-book.js` | The generator (docx-js). Title pages, TOC, themed headings, tables, figures, footers, Arabic pages. |
| `fix-bookmarks.py` | Post-processor that renumbers caption bookmark ids uniquely. |
| `content/*.json` | The book text as structured blocks — one file per chapter (`ch1`…`ch6`, `ch4a`+`ch4b`), plus `frontmatter.json` (abstract, acknowledgement, abbreviations, references) and `arabic.json`. Edit these to change wording. |
| `diagrams/src/*.svg` | Hand-authored diagram sources. |
| `diagrams/png/*.png` | Rendered diagrams (headless Chrome @2x) embedded in the book. |
| `assets/*.jpeg` | University + faculty logos (from the template). |
| `research/*.md` | Deep-dive engineering notes on the TesTly codebase used to ground the writing. |
| `template.docx` | The original faculty template (reference). |

### Editing a diagram
Edit the SVG in `diagrams/src/`, then re-render:
```bash
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
"$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=2 \
  --window-size=W,H --default-background-color=FFFFFFFF \
  --screenshot="diagrams/png/<id>.png" "file://$PWD/diagrams/src/<id>.svg"
```
(substitute the SVG’s width/height for `W,H`), then rerun `node build-book.js`.

### Structure
EN title page → 2nd title page + team table → Abstract → Acknowledgement → Table of Contents →
List of Figures / Tables / Abbreviations → Ch.1 Introduction → Ch.2 Related Work →
Ch.3 Methodologies & Tools → Ch.4 Design & Implementation → Ch.5 Testing & Evaluation →
Ch.6 Conclusions & Future Work → References → Arabic abstract + Arabic title page.

---

# Interactive tech presentation

**`TesTly-Tech-Presentation.html`** — a self-contained, shareable web presentation. Open it by
double-clicking (any modern browser). The first screen lets you pick **Backend / Frontend /
Mobile / AI**; each opens a slide deck that explains, in plain English: the **tech stack and why**,
the **key libraries and why**, **how it works** (with the project diagrams), and the **clever
algorithms** (the how *and* the why). Navigate with **← →**, **Esc** returns home, click any
diagram to **zoom**.

Regenerate:
```bash
node build-presentation.js   # injects presentation/decks/*.json + embeds the diagrams it uses
```

- Edit the slide wording in **`presentation/decks/*.json`** (one file per topic).
- Tweak the look / layout in **`presentation/app-template.html`** (all CSS + JS lives there).
- Then rerun `node build-presentation.js`.

Fonts load from Google Fonts (needs internet for the exact typefaces; it falls back gracefully
offline). The diagrams are embedded as data URIs, so the single `.html` works anywhere.

