def process_text(text):
    # Function to process text for embedding generation
    return text.strip()

def log_message(message):
    # Function to log messages to the console or a file
    print(message)

def validate_input(data):
    # Function to validate input data
    if not data:
        raise ValueError("Input data cannot be empty.")
    return True