# Configuration settings for the application

import os

class Config:
    # SharePoint credentials
    SHAREPOINT_SITE_URL = os.getenv('SHAREPOINT_SITE_URL')
    SHAREPOINT_CLIENT_ID = os.getenv('SHAREPOINT_CLIENT_ID')
    SHAREPOINT_CLIENT_SECRET = os.getenv('SHAREPOINT_CLIENT_SECRET')
    
    # SQL Server connection settings
    SQL_SERVER_HOST = os.getenv('SQL_SERVER_HOST')
    SQL_SERVER_DATABASE = os.getenv('SQL_SERVER_DATABASE')
    SQL_SERVER_USER = os.getenv('SQL_SERVER_USER')
    SQL_SERVER_PASSWORD = os.getenv('SQL_SERVER_PASSWORD')
    
    # OpenAI API key
    OPENAI_API_KEY = os.getenv('OPENAI_API_KEY')
    
    # Qdrant configuration
    QDRANT_URL = os.getenv('QDRANT_URL')
    QDRANT_API_KEY = os.getenv('QDRANT_API_KEY')