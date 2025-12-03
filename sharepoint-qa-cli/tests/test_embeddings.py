import unittest
from src.embeddings.generator import generate_embeddings

class TestEmbeddings(unittest.TestCase):

    def test_generate_embeddings(self):
        text = "This is a test document."
        embeddings = generate_embeddings(text)
        self.assertIsNotNone(embeddings)
        self.assertIsInstance(embeddings, list)
        self.assertGreater(len(embeddings), 0)

if __name__ == '__main__':
    unittest.main()