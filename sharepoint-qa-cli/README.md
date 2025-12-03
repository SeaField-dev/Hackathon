# SharePoint QA CLI

## Overview
The SharePoint QA CLI is a console application designed to extract documents from SharePoint Online, store them in SQL Server, generate embeddings for search, and perform fast retrieval using a local vector database (Qdrant). The application leverages OpenAI to provide contextual answers based on user queries.

## Features
- Extract documents from SharePoint Online.
- Store and manage documents in SQL Server.
- Generate embeddings for efficient search and retrieval.
- Utilize Qdrant for fast vector-based retrieval.
- Integrate with OpenAI for contextual question answering.

## Project Structure
```
sharepoint-qa-cli
├── src
│   ├── cli.py                # Command-line interface for user interaction
│   ├── main.py               # Entry point of the application
│   ├── config.py             # Configuration settings
│   ├── sharepoint            # Module for SharePoint interactions
│   │   ├── auth.py           # Authentication with SharePoint Online
│   │   └── extractor.py      # Document extraction logic
│   ├── db                    # Module for database interactions
│   │   ├── client.py         # SQL Server connection management
│   │   └── models.py         # Data models for SQL Server
│   ├── embeddings            # Module for embedding generation
│   │   ├── generator.py      # Functions for generating embeddings
│   ├── vectorstore           # Module for vector database interactions
│   │   ├── qdrant_client.py   # Qdrant client for storing/retrieving embeddings
│   ├── retriever             # Module for retrieval logic
│   │   ├── retriever.py      # Logic for retrieving relevant embeddings
│   ├── openai_client.py      # Communication with OpenAI API
│   └── utils.py              # Utility functions
├── tests                     # Directory for unit tests
│   ├── test_sharepoint.py    # Tests for SharePoint extraction
│   ├── test_db.py            # Tests for database interactions
│   └── test_embeddings.py     # Tests for embedding generation
├── pyproject.toml            # Project configuration file
├── requirements.txt          # Required Python packages
├── .env.example              # Example environment variables
├── docker-compose.yml        # Docker configuration
├── .gitignore                # Files to ignore in version control
└── README.md                 # Project documentation
```

## Installation
1. Clone the repository:
   ```
   git clone <repository-url>
   cd sharepoint-qa-cli
   ```

2. Install the required packages:
   ```
   pip install -r requirements.txt
   ```

3. Set up environment variables by copying `.env.example` to `.env` and filling in the necessary values.

## Usage
To run the application, use the following command:
```
python src/main.py
```

Follow the prompts in the console to extract documents, generate embeddings, and ask questions.

## Contributing
Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for more details.