class Retriever:
    def __init__(self, vector_store_client, openai_client):
        self.vector_store_client = vector_store_client
        self.openai_client = openai_client

    def retrieve_embeddings(self, query, top_k=5):
        embeddings = self.vector_store_client.query_embeddings(query, top_k)
        return embeddings

    def get_answer(self, query):
        embeddings = self.retrieve_embeddings(query)
        context = self.prepare_context(embeddings)
        answer = self.openai_client.get_answer(context, query)
        return answer

    def prepare_context(self, embeddings):
        context = " ".join([embedding['text'] for embedding in embeddings])
        return context