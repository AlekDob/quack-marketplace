---
name: pdf-toolkit
description: Use this skill when working with PDF files - extracting text, merging, splitting, creating, filling forms, adding watermarks, or converting PDFs. Also use when the user asks to generate reports, invoices, or documents as PDF.
---

# PDF Toolkit

Complete guide for PDF manipulation using Python and JavaScript. Covers text extraction, creation, merging, splitting, form filling, OCR, and command-line tools.

## Tool Selection Guide

| Task | Recommended Tool | Language |
|------|-----------------|----------|
| Read/extract text | pdfplumber | Python |
| Extract tables | pdfplumber + pandas | Python |
| Merge/split/rotate | pypdf | Python |
| Create from scratch | reportlab (Python) or pdf-lib (JS) | Both |
| Fill form fields | pdf-lib (JS) or pypdf (Python) | Both |
| OCR scanned docs | pytesseract + pdf2image | Python |
| CLI quick operations | qpdf, pdftotext | Bash |
| Browser rendering | pdfjs-dist | JavaScript |

## Python: Text Extraction

### Basic text extraction with pdfplumber

```python
# pip install pdfplumber
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    for page in pdf.pages:
        text = page.extract_text()
        if text:
            print(text)
```

### Extract text from a specific region

```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    page = pdf.pages[0]
    # Crop region: (x0, top, x1, bottom) in points
    cropped = page.within_bbox((50, 100, 400, 300))
    print(cropped.extract_text())
```

### Extract tables as DataFrames

```python
import pdfplumber
import pandas as pd

with pdfplumber.open("report.pdf") as pdf:
    for page in pdf.pages:
        tables = page.extract_tables()
        for table in tables:
            df = pd.DataFrame(table[1:], columns=table[0])
            print(df.to_string())
```

### Custom table extraction settings

```python
import pdfplumber

settings = {
    "vertical_strategy": "lines",
    "horizontal_strategy": "lines",
    "snap_tolerance": 3,
    "intersection_tolerance": 15,
}

with pdfplumber.open("complex.pdf") as pdf:
    page = pdf.pages[0]
    tables = page.extract_tables(settings)
```

## Python: Merge, Split, Rotate (pypdf)

### Merge multiple PDFs

```python
# pip install pypdf
from pypdf import PdfWriter, PdfReader

writer = PdfWriter()
for path in ["part1.pdf", "part2.pdf", "part3.pdf"]:
    reader = PdfReader(path)
    for page in reader.pages:
        writer.add_page(page)

with open("merged.pdf", "wb") as f:
    writer.write(f)
```

### Split into individual pages

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("input.pdf")
for i, page in enumerate(reader.pages):
    writer = PdfWriter()
    writer.add_page(page)
    with open(f"page_{i + 1}.pdf", "wb") as f:
        writer.write(f)
```

### Extract a page range

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("input.pdf")
writer = PdfWriter()
for page in reader.pages[2:7]:  # pages 3-7 (0-indexed)
    writer.add_page(page)

with open("excerpt.pdf", "wb") as f:
    writer.write(f)
```

### Rotate pages

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("input.pdf")
writer = PdfWriter()

for page in reader.pages:
    page.rotate(90)  # clockwise degrees: 90, 180, 270
    writer.add_page(page)

with open("rotated.pdf", "wb") as f:
    writer.write(f)
```

### Read metadata

```python
from pypdf import PdfReader

reader = PdfReader("document.pdf")
info = reader.metadata
print(f"Title: {info.title}")
print(f"Author: {info.author}")
print(f"Pages: {len(reader.pages)}")
```

## Python: Create PDFs (reportlab)

### Simple document

```python
# pip install reportlab
from reportlab.lib.pagesizes import letter, A4
from reportlab.pdfgen import canvas

c = canvas.Canvas("output.pdf", pagesize=A4)
w, h = A4

c.setFont("Helvetica-Bold", 24)
c.drawString(72, h - 72, "Document Title")

c.setFont("Helvetica", 12)
c.drawString(72, h - 120, "Generated with reportlab.")

c.line(72, h - 130, w - 72, h - 130)
c.save()
```

### Multi-page report with Platypus

```python
from reportlab.lib.pagesizes import A4
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer,
    Table, TableStyle, PageBreak,
)
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib import colors

doc = SimpleDocTemplate("report.pdf", pagesize=A4)
styles = getSampleStyleSheet()
elements = []

# Title
elements.append(Paragraph("Quarterly Report", styles["Title"]))
elements.append(Spacer(1, 24))

# Body text
elements.append(Paragraph(
    "This report summarizes Q1 performance metrics.",
    styles["Normal"],
))
elements.append(Spacer(1, 12))

# Table
data = [
    ["Metric", "Q1", "Q2", "Change"],
    ["Revenue", "$120k", "$145k", "+21%"],
    ["Users", "1,200", "1,580", "+32%"],
]

table = Table(data, colWidths=[120, 80, 80, 80])
table.setStyle(TableStyle([
    ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#004E89")),
    ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
    ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
    ("ALIGN", (0, 0), (-1, -1), "CENTER"),
    ("GRID", (0, 0), (-1, -1), 0.5, colors.grey),
    ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F0F0F0")]),
]))
elements.append(table)

doc.build(elements)
```

## Python: OCR for Scanned PDFs

```python
# pip install pytesseract pdf2image Pillow
# Also requires: brew install tesseract poppler (macOS)
import pytesseract
from pdf2image import convert_from_path

images = convert_from_path("scanned.pdf", dpi=300)
full_text = ""

for i, img in enumerate(images):
    text = pytesseract.image_to_string(img, lang="eng")
    full_text += f"\n--- Page {i + 1} ---\n{text}"

print(full_text)
```

## Python: Password Protection

### Encrypt a PDF

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("input.pdf")
writer = PdfWriter()

for page in reader.pages:
    writer.add_page(page)

writer.encrypt(
    user_password="readpass",
    owner_password="ownerpass",
)

with open("protected.pdf", "wb") as f:
    writer.write(f)
```

### Decrypt a PDF

```python
from pypdf import PdfReader

reader = PdfReader("protected.pdf")
if reader.is_encrypted:
    reader.decrypt("readpass")

text = reader.pages[0].extract_text()
print(text)
```

## Python: Watermark

```python
from pypdf import PdfReader, PdfWriter

watermark_page = PdfReader("watermark.pdf").pages[0]
reader = PdfReader("document.pdf")
writer = PdfWriter()

for page in reader.pages:
    page.merge_page(watermark_page)
    writer.add_page(page)

with open("watermarked.pdf", "wb") as f:
    writer.write(f)
```

## Python: Crop Pages

```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("input.pdf")
writer = PdfWriter()

page = reader.pages[0]
# Coordinates in points (1 inch = 72 points)
page.mediabox.left = 72
page.mediabox.bottom = 72
page.mediabox.right = 540
page.mediabox.top = 720

writer.add_page(page)
with open("cropped.pdf", "wb") as f:
    writer.write(f)
```

## JavaScript: pdf-lib

### Create a PDF

```javascript
// npm install pdf-lib
import { PDFDocument, rgb, StandardFonts } from "pdf-lib";
import fs from "fs";

async function createPdf() {
  const doc = await PDFDocument.create();
  const font = await doc.embedFont(StandardFonts.Helvetica);
  const boldFont = await doc.embedFont(StandardFonts.HelveticaBold);

  const page = doc.addPage([595, 842]); // A4
  const { height } = page.getSize();

  page.drawText("Invoice #1234", {
    x: 50, y: height - 60, size: 20, font: boldFont,
    color: rgb(0.1, 0.3, 0.6),
  });

  page.drawText("Thank you for your purchase.", {
    x: 50, y: height - 100, size: 12, font,
  });

  const bytes = await doc.save();
  fs.writeFileSync("invoice.pdf", bytes);
}
```

### Merge PDFs

```javascript
import { PDFDocument } from "pdf-lib";
import fs from "fs";

async function mergePdfs(paths) {
  const merged = await PDFDocument.create();

  for (const path of paths) {
    const bytes = fs.readFileSync(path);
    const src = await PDFDocument.load(bytes);
    const pages = await merged.copyPages(src, src.getPageIndices());
    pages.forEach((p) => merged.addPage(p));
  }

  const result = await merged.save();
  fs.writeFileSync("merged.pdf", result);
}
```

### Fill form fields

```javascript
import { PDFDocument } from "pdf-lib";
import fs from "fs";

async function fillForm(inputPath, outputPath, values) {
  const bytes = fs.readFileSync(inputPath);
  const doc = await PDFDocument.load(bytes);
  const form = doc.getForm();

  for (const [fieldName, value] of Object.entries(values)) {
    const field = form.getTextField(fieldName);
    field.setText(value);
  }

  form.flatten(); // make fields read-only
  const filled = await doc.save();
  fs.writeFileSync(outputPath, filled);
}

// Usage
fillForm("template.pdf", "filled.pdf", {
  name: "John Doe",
  email: "john@example.com",
  date: "2026-01-15",
});
```

## Command-Line Tools

### qpdf (fast C++ tool)

```bash
# Merge
qpdf --empty --pages doc1.pdf doc2.pdf -- merged.pdf

# Split by page ranges
qpdf input.pdf --pages . 1-5 -- first5.pdf
qpdf input.pdf --pages . 6- -- rest.pdf

# Split every page
qpdf --split-pages input.pdf output_%02d.pdf

# Rotate page 1 by 90 degrees
qpdf input.pdf output.pdf --rotate=+90:1

# Decrypt
qpdf --password=secret --decrypt locked.pdf unlocked.pdf

# Linearize for web streaming
qpdf --linearize input.pdf web_optimized.pdf

# Check PDF integrity
qpdf --check input.pdf
```

### pdftotext (poppler-utils)

```bash
# Basic extraction
pdftotext input.pdf output.txt

# Preserve layout
pdftotext -layout input.pdf output.txt

# Specific pages
pdftotext -f 3 -l 8 input.pdf pages3to8.txt

# Extract with bounding boxes (XML)
pdftotext -bbox-layout input.pdf output.xml
```

### pdftoppm (poppler-utils) - PDF to images

```bash
# Convert to PNG at 300 DPI
pdftoppm -png -r 300 input.pdf output_prefix

# Specific pages as JPEG
pdftoppm -jpeg -jpegopt quality=90 -f 1 -l 3 input.pdf preview

# Single page at high res
pdftoppm -png -r 600 -f 1 -singlefile input.pdf cover
```

### pdfimages (poppler-utils) - extract embedded images

```bash
# Extract all images as JPEG
pdfimages -j input.pdf images/img

# List image info without extracting
pdfimages -list input.pdf
```

## Installation Quick Reference

### Python

```bash
pip install pypdf pdfplumber reportlab
# For OCR:
pip install pytesseract pdf2image Pillow
# macOS: brew install tesseract poppler
```

### JavaScript

```bash
npm install pdf-lib
# For browser rendering:
npm install pdfjs-dist
```

### CLI tools (macOS)

```bash
brew install qpdf poppler
```

### CLI tools (Ubuntu/Debian)

```bash
sudo apt install qpdf poppler-utils
```

## Performance Tips

1. **Large files**: Use `qpdf --split-pages` instead of Python for splitting 100+ page PDFs
2. **Text extraction**: `pdftotext` is faster than Python for plain text; use `pdfplumber` only when you need tables or coordinates
3. **Batch processing**: Process pages individually to avoid loading entire PDFs into memory
4. **Images**: Use `pdfimages` to extract embedded images (much faster than rendering pages)
5. **OCR**: Set DPI to 300 for good accuracy/speed balance; 600 DPI only when text is very small

## Common Patterns

### Check if PDF has fillable forms (Python)

```python
from pypdf import PdfReader

reader = PdfReader("document.pdf")
fields = reader.get_fields()
if fields:
    print(f"Found {len(fields)} form fields:")
    for name, field in fields.items():
        print(f"  {name}: {field.get('/FT', 'unknown')}")
else:
    print("No fillable fields found.")
```

### Convert PDF pages to images for AI analysis

```python
from pdf2image import convert_from_path

images = convert_from_path("document.pdf", dpi=200)
for i, img in enumerate(images):
    img.save(f"page_{i + 1}.png", "PNG")
```

## License Information

| Library | License |
|---------|---------|
| pypdf | BSD |
| pdfplumber | MIT |
| reportlab | BSD |
| pdf-lib | MIT |
| pdfjs-dist | Apache 2.0 |
| qpdf | Apache 2.0 |
| poppler-utils | GPL-2 |
| pytesseract | Apache 2.0 |
