@echo off
echo ============================================
echo      Starting Local CRE RAG Chat System
echo ============================================

REM --------------------------------------------
REM 1. Activate virtual environment if it exists
REM --------------------------------------------
if exist venv\Scripts\activate (
    echo Activating virtual environment...
    call venv\Scripts\activate
) else (
    echo No virtual environment found. Consider creating one with:
    echo python -m venv venv
)

REM --------------------------------------------
REM 2. Load environment variables from .env
REM --------------------------------------------
echo Loading environment variables...
for /f "usebackq tokens=* delims=" %%a in (".env") do set %%a

if "%OPENAI_API_KEY%"=="" (
    echo ERROR: OPENAI_API_KEY not detected in .env
    echo Make sure your .env file contains:
    echo   OPENAI_API_KEY=sk-xxxx
    pause
    exit /b
)

echo OPENAI_API_KEY loaded.

REM --------------------------------------------
REM 3. Detect if RAG docs changed
REM    (rebuild embeddings only when necessary)
REM --------------------------------------------
set RAG_HASH_FILE=rag_hash.txt
set RAG_DIR=rag_docs

echo Checking if RAG docs changed...

REM Compute a quick hash of all filenames+modified times
dir /b /od "%RAG_DIR%" > current_hash.tmp

REM If no previous hash exists, force rebuild
if not exist %RAG_HASH_FILE% goto rebuild_rag

REM Compare hashes
fc /b current_hash.tmp %RAG_HASH_FILE% > nul
if errorlevel 1 (
    echo RAG documents changed — rebuilding embeddings...
    goto rebuild_rag
) else (
    echo No changes in RAG docs. Skipping embedding rebuild.
    goto start_server
)

:rebuild_rag
echo Running document ingestion...
python ingest_rag.py

echo Updating RAG hash...
copy /y current_hash.tmp %RAG_HASH_FILE% > nul

goto start_server


REM --------------------------------------------
REM 4. Start FastAPI server
REM --------------------------------------------
:start_server
echo Starting FastAPI backend on http://localhost:8000
start "" http://localhost:8000

python -m uvicorn server:app --reload --port 8000

echo Server stopped.
pause
