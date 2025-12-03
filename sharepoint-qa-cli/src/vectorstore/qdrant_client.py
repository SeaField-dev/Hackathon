from qdrant_client import QdrantClient
from qdrant_client.http.models import PointStruct, VectorParams, Distance

class QdrantDatabase:
    def __init__(self, host: str, port: int, collection_name: str):
        self.client = QdrantClient(host=host, port=port)
        self.collection_name = collection_name
        self._create_collection()

    def _create_collection(self):
        if not self.client.collection_exists(self.collection_name):
            self.client.create_collection(
                collection_name=self.collection_name,
                vector_params=VectorParams(size=768, distance=Distance.Euclidean)
            )

    def add_embedding(self, id: str, vector: list):
        point = PointStruct(id=id, vector=vector)
        self.client.upsert(collection_name=self.collection_name, points=[point])

    def search(self, vector: list, limit: int = 5):
        results = self.client.search(
            collection_name=self.collection_name,
            query_vector=vector,
            limit=limit
        )
        return results

    def delete_embedding(self, id: str):
        self.client.delete(collection_name=self.collection_name, ids=[id])