from office365.runtime.auth.authentication_context import AuthenticationContext
from office365.sharepoint.client_context import ClientContext
import os

class SharePointAuth:
    def __init__(self, site_url, client_id, client_secret):
        self.site_url = site_url
        self.client_id = client_id
        self.client_secret = client_secret
        self.context = None

    def authenticate(self):
        auth_context = AuthenticationContext(self.site_url)
        if auth_context.acquire_token_for_client(client_id=self.client_id, client_secret=self.client_secret):
            self.context = ClientContext(self.site_url, auth_context)
            return True
        return False

    def get_context(self):
        if self.context is None:
            raise Exception("Authentication has not been performed. Call authenticate() first.")
        return self.context