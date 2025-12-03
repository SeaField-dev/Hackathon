from office365.runtime.auth.authentication_context import AuthenticationContext
from office365.sharepoint.client_context import ClientContext
import os

class SharePointExtractor:
    def __init__(self, site_url, client_id, client_secret):
        self.site_url = site_url
        self.client_id = client_id
        self.client_secret = client_secret
        self.context = self.authenticate()

    def authenticate(self):
        ctx_auth = AuthenticationContext(self.site_url)
        if ctx_auth.acquire_token_for_client(client_id=self.client_id, client_secret=self.client_secret):
            return ClientContext(self.site_url, ctx_auth)
        else:
            raise Exception("Authentication failed")

    def fetch_documents(self, library_name):
        library = self.context.web.lists.get_by_title(library_name)
        items = library.items
        self.context.load(items)
        self.context.execute_query()
        documents = []
        for item in items:
            documents.append({
                'title': item.properties.get('Title'),
                'url': item.properties.get('FileRef'),
                'content': self.download_file(item.properties.get('FileRef'))
            })
        return documents

    def download_file(self, file_url):
        response = self.context.web.get_file_by_server_relative_url(file_url).download()
        self.context.execute_query()
        return response.content.decode('utf-8')  # Assuming the file is text-based

    def process_documents(self, library_name):
        documents = self.fetch_documents(library_name)
        # Additional processing can be done here
        return documents