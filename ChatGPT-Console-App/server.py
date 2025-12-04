import os
import json
from datetime import datetime
from typing import List, Dict

import numpy as np
from fastapi import FastAPI
from fastapi.responses import StreamingResponse, JSONResponse, FileResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/favicon.ico")
async def favicon():
    favicon_path = os.path.join(os.path.dirname(__file__), "favicon.ico")
    return FileResponse(favicon_path)

app.mount("/icons", StaticFiles(directory="icons"), name="icons")
    
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
HISTORY_DIR = "history"
os.makedirs(HISTORY_DIR, exist_ok=True)

# --- RAG globals ---
EMBEDDINGS_PATH = "rag_embeddings.json"
EMBEDDING_MODEL = "text-embedding-3-small"
RAG_MIN_SIMILARITY = 0.32   # tweak as needed
RAG_TOP_K = 6
rag_index: List[Dict] = []

# --- Chat globals ---
conversation_history: List[Dict] = []
current_chat_filename = None
current_chat_title = None

MIN_MESSAGES_FOR_TITLE = 1
MIN_USER_CHARS = 40


# ============ RAG LOADING & RETRIEVAL ============

def load_rag_index():
    global rag_index
    if os.path.exists(EMBEDDINGS_PATH):
        with open(EMBEDDINGS_PATH, "r", encoding="utf8") as f:
            rag_index = json.load(f)
        print(f"Loaded {len(rag_index)} RAG chunks.")
    else:
        rag_index = []
        print("No rag_embeddings.json found. RAG disabled until you run ingest_rag.py.")


def cosine_similarity(a: List[float], b: List[float]) -> float:
    a_arr = np.array(a)
    b_arr = np.array(b)
    denom = (np.linalg.norm(a_arr) * np.linalg.norm(b_arr))
    if denom == 0:
        return 0.0
    return float(np.dot(a_arr, b_arr) / denom)


def retrieve_relevant_chunks(query: str, k: int = RAG_TOP_K) -> List[Dict]:
    """Return top-k most similar chunks for a query, or [] if nothing relevant."""
    if not rag_index:
        return []

    q_emb = client.embeddings.create(
        model=EMBEDDING_MODEL,
        input=query
    ).data[0].embedding

    scored = []
    for rec in rag_index:
        score = cosine_similarity(q_emb, rec["embedding"])
        scored.append((score, rec))

    scored.sort(key=lambda x: x[0], reverse=True)
    top = scored[:k]

    if not top or top[0][0] < RAG_MIN_SIMILARITY:
        return []

    return [rec for _, rec in top]


def build_rag_context(chunks: List[Dict]) -> str:
    """Build a text block to send as system context."""
    parts = []
    for c in chunks:
        parts.append(
            f"Source file: {c.get('file','unknown')}\n"
            f"Content:\n{c['text']}"
        )
    return "\n\n---\n\n".join(parts)


# ============ TITLE FILE HELPERS ============

def title_path(base_filename):
    return os.path.join(HISTORY_DIR, base_filename + ".title.txt")


def read_title_file(path):
    if not os.path.exists(path):
        return None, True  # no title yet → treat as auto

    try:
        data = json.load(open(path, "r", encoding="utf8"))
        return data.get("title"), data.get("auto", True)
    except Exception:
        text = open(path, "r", encoding="utf8").read().strip()
        return text, True


def write_title_file(path, title, auto=True):
    with open(path, "w", encoding="utf8") as f:
        json.dump({"title": title, "auto": auto}, f)


def generate_chat_title():
    preview = conversation_history[:4]
    resp = client.chat.completions.create(
        model="gpt-5.1",
        messages=[
            {
                "role": "system",
                "content": "Generate a short descriptive chat title (max 6 words). No quotes."
            },
            {"role": "user", "content": json.dumps(preview)},
        ],
    )
    return resp.choices[0].message.content.strip()


def ensure_chat_title(base_filename):
    global current_chat_title
    path = title_path(base_filename)

    title, is_auto = read_title_file(path)
    if title is not None:
        current_chat_title = title
        return current_chat_title

    current_chat_title = generate_chat_title()
    write_title_file(path, current_chat_title, auto=True)
    return current_chat_title


def improve_chat_title(base_filename):
    """Try to regenerate a better title if current one is auto-generated."""
    path = title_path(base_filename)
    title, is_auto = read_title_file(path)
    if not is_auto:
        return

    new_title = generate_chat_title()
    if not new_title:
        return

    if new_title.lower().strip() != str(title).lower().strip():
        write_title_file(path, new_title, auto=True)


def save_current_chat():
    global current_chat_filename
    if not conversation_history:
        return None

    if current_chat_filename is None:
        current_chat_filename = f"chat_{datetime.now().strftime('%Y%m%d-%H%M%S')}"

    json_path = os.path.join(HISTORY_DIR, current_chat_filename + ".json")
    with open(json_path, "w", encoding="utf8") as f:
        json.dump(conversation_history, f, indent=2)

    ensure_chat_title(current_chat_filename)
    improve_chat_title(current_chat_filename)

    return current_chat_filename


# ============ ENDPOINTS ============

@app.post("/new_chat")
def new_chat():
    global conversation_history, current_chat_filename, current_chat_title

    save_current_chat()
    conversation_history = []
    current_chat_filename = None
    current_chat_title = None

    return {"status": "new chat started"}


@app.get("/history")
def history_list():
    items = []
    for file in sorted(os.listdir(HISTORY_DIR)):
        if file.endswith(".json"):
            base = file[:-5]
            title_file = title_path(base)

            title, _ = read_title_file(title_file)
            if title is None:
                title = base

            items.append({"base": base, "title": title})
    return items


@app.get("/load")
def load_chat(base: str):
    p = os.path.join(HISTORY_DIR, base + ".json")
    if not os.path.exists(p):
        return JSONResponse({"error": "Chat not found"}, status_code=404)

    with open(p, "r", encoding="utf8") as f:
        return json.load(f)


@app.delete("/delete_chat")
def delete_chat(base: str):
    json_path = os.path.join(HISTORY_DIR, base + ".json")
    title_file = os.path.join(HISTORY_DIR, base + ".title.txt")

    if os.path.exists(json_path):
        os.remove(json_path)
    if os.path.exists(title_file):
        os.remove(title_file)

    return {"deleted": base}


@app.put("/rename_chat")
def rename_chat(base: str, title: str):
    title_file = title_path(base)
    write_title_file(title_file, title, auto=False)
    return {"renamed": base, "title": title}


def stream_chat_response(message: str):
    """
    RAG-only CRE analyst:
    - Retrieve relevant chunks
    - If none: refuse
    - Else: answer strictly from those chunks
    """
    global conversation_history

    # Add user message to history first
    conversation_history.append({"role": "user", "content": message})

    # RAG retrieval
    relevant_chunks = retrieve_relevant_chunks(message)
    if not relevant_chunks:
        reply = (
            "I am restricted to the commercial real-estate (CRE) documents you have provided, "
            "and I cannot find any relevant information to answer this question. "
            "Please ask a question that relates directly to the CRE client data or documents."
        )

        # stream refusal
        for i in range(0, len(reply), 64):
            yield reply[i:i+64]

        conversation_history.append({"role": "assistant", "content": reply})

        # save if enough context
        user_messages = [m for m in conversation_history if m["role"] == "user"]
        if user_messages and (
            len(user_messages) >= MIN_MESSAGES_FOR_TITLE
            or len(user_messages[-1]["content"]) >= MIN_USER_CHARS
        ):
            save_current_chat()
        return

    rag_context = build_rag_context(relevant_chunks)

    system_prompt = (
        "You are a highly competent commercial real estate (CRE) data analyst working at Open Box Software. "
        "You answer questions ONLY using the information contained in the provided CRE documents and data. "
        "These documents may include lease details, property information, rent rolls, capital expenditure data, "
        "client structures, and other CRE-related information.\n\n"
        "Rules:\n"
        "- Do NOT use any outside knowledge beyond these documents.\n"
        "- If the answer is not clearly supported by the documents, say explicitly: "
        "\"The information you are asking for is not available in the provided CRE documents.\"\n"
        "- Be precise, numeric and analytical whenever possible.\n"
        "- Clearly distinguish between different clients, properties, assets and time periods.\n"
        "- If a question is off-topic or not CRE-related, say that you are restricted to the CRE documents."
    )

    messages_for_gpt = [
        {"role": "system", "content": system_prompt},
        {
            "role": "system",
            "content": "Here is the relevant CRE context from the documents:\n\n" + rag_context,
        },
    ] + conversation_history

    stream = client.chat.completions.create(
        model="gpt-5.1",
        messages=messages_for_gpt,
        stream=True,
    )

    assistant_reply = ""
    buffer = ""

    for chunk in stream:
        if chunk.choices and chunk.choices[0].delta and chunk.choices[0].delta.content:
            token = chunk.choices[0].delta.content
            assistant_reply += token
            buffer += token

            if len(buffer) > 8:
                yield buffer
                buffer = ""

    if buffer:
        yield buffer

    conversation_history.append({"role": "assistant", "content": assistant_reply})

    user_messages = [m for m in conversation_history if m["role"] == "user"]
    should_save = (
        len(user_messages) >= MIN_MESSAGES_FOR_TITLE
        or len(user_messages[-1]["content"]) >= MIN_USER_CHARS
    )
    if should_save:
        save_current_chat()


@app.get("/chat")
async def chat(message: str):
    return StreamingResponse(stream_chat_response(message), media_type="text/plain")


@app.get("/")
def serve_frontend():
    return FileResponse("index-react.html")


# Load RAG index at startup
load_rag_index()
