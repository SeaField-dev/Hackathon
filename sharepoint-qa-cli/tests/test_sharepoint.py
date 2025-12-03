import unittest
from src.sharepoint.extractor import SharePointExtractor

class TestSharePointExtractor(unittest.TestCase):

    def setUp(self):
        self.extractor = SharePointExtractor()

    def test_extract_documents(self):
        documents = self.extractor.extract_documents()
        self.assertIsInstance(documents, list)
        self.assertGreater(len(documents), 0)

    def test_process_document(self):
        sample_doc = {"title": "Test Document", "content": "This is a test."}
        processed_doc = self.extractor.process_document(sample_doc)
        self.assertIn("title", processed_doc)
        self.assertIn("content", processed_doc)

if __name__ == '__main__':
    unittest.main()