from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

class DatabaseClient:
    def __init__(self, db_url):
        self.engine = create_engine(db_url)
        self.Session = sessionmaker(bind=self.engine)

    def insert_document(self, document):
        session = self.Session()
        try:
            session.add(document)
            session.commit()
        except Exception as e:
            session.rollback()
            raise e
        finally:
            session.close()

    def retrieve_documents(self, query):
        session = self.Session()
        try:
            results = session.query(query).all()
            return results
        finally:
            session.close()