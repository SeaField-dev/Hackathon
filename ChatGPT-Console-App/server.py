import os
import json
from datetime import datetime
from fastapi import FastAPI
from fastapi.responses import StreamingResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from openai import OpenAI
from fastapi.responses import FileResponse
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

HISTORY_DIR = "history"
os.makedirs(HISTORY_DIR, exist_ok=True)

conversation_history = []
current_chat_filename = None
current_chat_title = None

# Context thresholds for saving chat
MIN_MESSAGES_FOR_TITLE = 1
MIN_USER_CHARS = 40


def title_path(base_filename):
    return os.path.join(HISTORY_DIR, base_filename + ".title.txt")


def generate_chat_title():
    preview = conversation_history[:4]
    resp = client.chat.completions.create(
        model="gpt-5.1",
        messages=[
            {"role": "system", "content": "Generate a short descriptive chat title (max 6 words). No quotes."},
            {"role": "user", "content": json.dumps(preview)}
        ]
    )
    return resp.choices[0].message.content.strip()


def ensure_chat_title(base_filename):
    global current_chat_title
    path = title_path(base_filename)

    if os.path.exists(path):
        with open(path, "r", encoding="utf8") as f:
            current_chat_title = f.read().strip()
    else:
        current_chat_title = generate_chat_title()
        with open(path, "w", encoding="utf8") as f:
            f.write(current_chat_title)

    return current_chat_title


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
    return current_chat_filename


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
            if os.path.exists(title_file):
                with open(title_file, "r", encoding="utf8") as f:
                    title = f.read().strip()
            else:
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
    title_file = os.path.join(HISTORY_DIR, base + ".title.txt")
    with open(title_file, "w", encoding="utf8") as f:
        f.write(title)
    return {"renamed": base, "title": title}


def stream_chat_response(message: str):
    global conversation_history

    conversation_history.append({"role": "user", "content": message})

    stream = client.chat.completions.create(
        model="gpt-5.1",
        messages=conversation_history,
        stream=True
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

    # save only when enough context exists
    user_messages = [m for m in conversation_history if m["role"] == "user"]

    should_save = (
        len(user_messages) >= MIN_MESSAGES_FOR_TITLE or
        len(user_messages[-1]["content"]) >= MIN_USER_CHARS
    )

    if should_save:
        save_current_chat()


@app.get("/chat")
async def chat(message: str):
    return StreamingResponse(stream_chat_response(message), media_type="text/plain")

@app.get("/")
def serve_frontend():
    return FileResponse("index-react.html")
