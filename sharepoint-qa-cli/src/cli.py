import argparse
from src.main import run_application

def main():
    parser = argparse.ArgumentParser(description="SharePoint Document QA CLI")
    parser.add_argument('--query', type=str, required=True, help='The query to search for in the documents.')
    
    args = parser.parse_args()
    
    response = run_application(args.query)
    print(response)

if __name__ == "__main__":
    main()