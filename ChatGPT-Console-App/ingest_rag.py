# ingest_rag.py

import os
import json
from typing import List, Dict

from dotenv import load_dotenv
from openai import OpenAI
from pypdf import PdfReader
from docx import Document
import pandas as pd

load_dotenv()
client = OpenAI()

RAG_DIR = "rag_docs"
EMBEDDINGS_PATH = "rag_embeddings.json"
EMBEDDING_MODEL = "text-embedding-3-small"

CHUNK_SIZE_WORDS = 220
CHUNK_OVERLAP_WORDS = 40


# -----------------------------
# FILE EXTRACTION HELPERS
# -----------------------------

def load_pdf(path: str) -> str:
    try:
        reader = PdfReader(path)
        pages = [page.extract_text() or "" for page in reader.pages]
        return "\n".join(pages)
    except:
        print(f"PDF read error: {path}")
        return ""


def load_docx(path: str) -> str:
    try:
        doc = Document(path)
        paragraphs = [p.text for p in doc.paragraphs]
        return "\n".join(paragraphs)
    except:
        print(f"DOCX read error: {path}")
        return ""


def load_excel(path: str) -> str:
    try:
        df = pd.read_excel(path, sheet_name=None)
        parts = []
        for sheet_name, sheet_df in df.items():
            parts.append(f"--- Sheet: {sheet_name} ---")
            parts.append(sheet_df.to_string())
        return "\n".join(parts)
    except:
        print(f"Excel read error: {path}")
        return ""


def load_csv(path: str) -> str:
    try:
        df = pd.read_csv(path)
        return df.to_string()
    except:
        print(f"CSV read error: {path}")
        return ""


def load_text(path: str) -> str:
    try:
        with open(path, "r", encoding="utf8", errors="ignore") as f:
            return f.read()
    except:
        print(f"Text read error: {path}")
        return ""


def load_file_text(path: str) -> str:
    ext = os.path.splitext(path)[1].lower()

    if ext == ".pdf":
        return load_pdf(path)
    if ext == ".docx":
        return load_docx(path)
    if ext in [".xlsx", ".xls"]:
        return load_excel(path)
    if ext == ".csv":
        return load_csv(path)
    if ext in [".txt", ".md"]:
        return load_text(path)

    print(f"Skipping unsupported file type: {path}")
    return ""


# -----------------------------
# CHUNKING
# -----------------------------

def chunk_text(text: str) -> List[str]:
    words = text.split()
    chunks = []
    i = 0
    while i < len(words):
        chunk = words[i : i + CHUNK_SIZE_WORDS]
        chunks.append(" ".join(chunk))
        i += CHUNK_SIZE_WORDS - CHUNK_OVERLAP_WORDS
    return chunks


# -----------------------------
# EMBEDDINGS
# -----------------------------

def embed_batch(texts: List[str]) -> List[List[float]]:
    resp = client.embeddings.create(
        model=EMBEDDING_MODEL,
        input=texts,
    )
    return [d.embedding for d in resp.data]


# -----------------------------
# MAIN INGESTION
# -----------------------------

def main():
    os.makedirs(RAG_DIR, exist_ok=True)
    records: List[Dict] = []

    for filename in os.listdir(RAG_DIR):
        full_path = os.path.join(RAG_DIR, filename)
        if not os.path.isfile(full_path):
            continue

        print(f"Processing {filename}...")
        raw_text = load_file_text(full_path)

        if not raw_text.strip():
            print(f"  -> No readable text. Skipped.")
            continue

        chunks = chunk_text(raw_text)
        print(f"  -> {len(chunks)} chunks")

        # Embed in batches
        batch_size = 40
        for start in range(0, len(chunks), batch_size):
            batch = chunks[start : start + batch_size]
            embeddings = embed_batch(batch)

            for i, (chunk_text_val, emb) in enumerate(zip(batch, embeddings)):
                records.append(
                    {
                        "id": f"{filename}-{start+i}",
                        "file": filename,
                        "text": chunk_text_val,
                        "embedding": emb,
                    }
                )

    with open(EMBEDDINGS_PATH, "w", encoding="utf8") as f:
        json.dump(records, f)

    print(f"\n✅ Complete! {len(records)} chunks saved to {EMBEDDINGS_PATH}")


if __name__ == "__main__":
    main()
