import PyPDF2
import pandas as pd

pdf_file = "example.pdf"
reader = PyPDF2.PdfReader(pdf_file)

lines = []

for page in reader.pages:
    text = page.extract_text()
    if text:
        lines.extend(text.splitlines())

df = pd.DataFrame(lines, columns=["Text"])
df.to_excel("output.xlsx", index=False)
