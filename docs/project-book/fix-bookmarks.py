#!/usr/bin/env python3
"""Renumber bookmark w:id values uniquely in a .docx (docx-js stamps them all '1').
Bookmarks are non-nested here, so a single left-to-right pass with a stack pairs
start/end correctly. PAGEREF fields reference the bookmark *name*, which we leave intact."""
import re, sys, zipfile, os

src = sys.argv[1] if len(sys.argv) > 1 else "TesTly-Project-Book.docx"
zin = zipfile.ZipFile(src, "r")
items = [(i, zin.read(i.filename)) for i in zin.infolist()]
zin.close()

counter = [0]
stack = []
def repl(m):
    s = m.group(0)
    if s.startswith("<w:bookmarkStart"):
        counter[0] += 1
        nid = counter[0]
        stack.append(nid)
    else:
        nid = stack.pop() if stack else (counter[0] + 1)
    return re.sub(r'w:id="[^"]*"', f'w:id="{nid}"', s, count=1)

changed = 0
for idx, (info, data) in enumerate(items):
    if info.filename == "word/document.xml":
        xml = data.decode("utf-8")
        xml, n = re.subn(r'<w:bookmark(?:Start\b[^>]*|End\b[^>]*)>', repl, xml)
        items[idx] = (info, xml.encode("utf-8"))
        changed = n

tmp = src + ".tmp"
with zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
    for info, data in items:
        zout.writestr(info, data)
os.replace(tmp, src)
print(f"renumbered {changed} bookmark elements ({counter[0]} unique pairs) in {src}")
