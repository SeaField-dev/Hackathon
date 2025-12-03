import os
from openai import OpenAI
from dotenv import load_dotenv

def main():
    # Load API key from .env
    load_dotenv()
    api_key = os.getenv("OPENAI_API_KEY")

    if not api_key:
        print("ERROR: OPENAI_API_KEY is missing in .env")
        return

    client = OpenAI(api_key=api_key)

    print("=== ChatGPT Streaming Console App ===")
    print("Type 'exit' to quit.\n")

    conversation = []

    while True:
        user_input = input("You: ").strip()
        if user_input.lower() == "exit":
            print("Goodbye!")
            break

        # Add user message to conversation
        conversation.append({"role": "user", "content": user_input})

        try:
            # STREAMING response
            stream = client.chat.completions.create(
                model="gpt-5.1",
                messages=conversation,
                stream=True
            )

            print("ChatGPT: ", end="", flush=True)
            assistant_reply = ""

            for chunk in stream:
                # Skip chunks without content
                if not chunk.choices or not chunk.choices[0].delta.content:
                    continue

                token = chunk.choices[0].delta.content
                assistant_reply += token
                print(token, end="", flush=True)

            print("\n")  # finish line

        except Exception as e:
            print("\nERROR calling OpenAI API:")
            print(e)
            print()
            continue

        # Add assistant streamed reply to conversation
        conversation.append({"role": "assistant", "content": assistant_reply})


if __name__ == "__main__":
    main()
