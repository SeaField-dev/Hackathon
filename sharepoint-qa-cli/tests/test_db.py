import unittest
from src.db.client import DatabaseClient
from src.db.models import Document

class TestDatabaseClient(unittest.TestCase):

    def setUp(self):
        self.db_client = DatabaseClient()
        self.test_document = Document(title="Test Document", content="This is a test document.")

    def test_insert_document(self):
        result = self.db_client.insert_document(self.test_document)
        self.assertTrue(result)

    def test_retrieve_document(self):
        self.db_client.insert_document(self.test_document)
        retrieved_document = self.db_client.retrieve_document(self.test_document.title)
        self.assertEqual(retrieved_document.title, self.test_document.title)
        self.assertEqual(retrieved_document.content, self.test_document.content)

    def tearDown(self):
        self.db_client.delete_document(self.test_document.title)

if __name__ == '__main__':
    unittest.main()