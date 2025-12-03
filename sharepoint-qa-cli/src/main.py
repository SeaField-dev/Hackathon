# main.py

import os
import sys
from src.config import Config
from src.sharepoint.extractor import SharePointExtractor
from src.db.client import DatabaseClient
from src.embeddings.generator import EmbeddingGenerator
from src.vectorstore.qdrant_client import QdrantClient
from src.retriever.retriever import Retriever
from src.openai_client import OpenAIClient

def main():
    # Load configuration
    config = Config()

    # Initialize components
    sharepoint_extractor = SharePointExtractor(config.sharepoint_credentials)
    db_client = DatabaseClient(config.database_connection_string)
    embedding_generator = EmbeddingGenerator(config.embedding_model)
    qdrant_client = QdrantClient(config.qdrant_url)
    retriever = Retriever(qdrant_client)
    openai_client = OpenAIClient(config.openai_api_key)

    # Extract documents from SharePoint
    documents = sharepoint_extractor.extract_documents()

    # Save documents to SQL Server
    for document in documents:
        db_client.save_document(document)

    # Generate embeddings and store in Qdrant
    for document in documents:
        embedding = embedding_generator.generate_embedding(document.text)
        qdrant_client.store_embedding(document.id, embedding)

    # User query for retrieval
    user_query = input("Enter your query: ")
    relevant_embeddings = retriever.retrieve(user_query)

    # Send context to OpenAI and get answers
    answers = []
    for embedding in relevant_embeddings:
        context = embedding['context']
        answer = openai_client.get_answer(context, user_query)
        answers.append(answer)

    # Present answers to the console
    for answer in answers:
        print(answer)

if __name__ == "__main__":
    main()