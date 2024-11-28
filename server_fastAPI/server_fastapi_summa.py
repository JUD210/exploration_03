import uvicorn  # pip install uvicorn
from fastapi import FastAPI, HTTPException, Request  # pip install fastapi
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import logging
from summa.summarizer import summarize  # pip install summa

# Create the FastAPI application
app = FastAPI()

# CORS configuration
origins = ["*"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Request body schema
class TextRequest(BaseModel):
    text: str
    ratio: float = 0.2  # Default ratio for summarization (20% of the original text)

# Root endpoint
@app.get("/")
async def read_root():
    logger.info("Root URL was requested")
    return {"message": "Welcome to the Text Summarization API using Summa!"}


# Prediction endpoint
@app.post("/sample")
async def sample(request: TextRequest):
    try:
        # Extract text and ratio from the request
        input_text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged."
        ratio = request.ratio

        if not input_text.strip():
            raise HTTPException(status_code=400, detail="Input text is empty")

        # Perform summarization using Summa
        summary = summarize(input_text, ratio=ratio)

        if not summary:
            raise HTTPException(status_code=500, detail="Summarization failed. The input text might be too short.")

        logger.info("Summarization successful")
        return {
            "original_text": input_text,
            "summary": summary,
            "summary_ratio": ratio
        }
    except Exception as e:
        logger.error("Prediction failed: %s", e)
        raise HTTPException(status_code=500, detail=str(e))



# Prediction endpoint
@app.post("/predict")
async def prediction(request: TextRequest):
    try:
        # Extract text and ratio from the request
        input_text = request.text
        ratio = request.ratio

        if not input_text.strip():
            raise HTTPException(status_code=400, detail="Input text is empty")

        # Perform summarization using Summa
        summary = summarize(input_text, ratio=ratio)

        if not summary:
            raise HTTPException(status_code=500, detail="Summarization failed. The input text might be too short.")

        logger.info("Summarization successful")
        return {
            "original_text": input_text,
            "summary": summary,
            "summary_ratio": ratio
        }
    except Exception as e:
        logger.error("Prediction failed: %s", e)
        raise HTTPException(status_code=500, detail=str(e))


# Run the server
if __name__ == "__main__":
    uvicorn.run(
        "server_fastapi_summa:app",
        reload=True,  # Reload the server when code changes
        host="127.0.0.1",  # Listen on localhost
        port=12530,  # Listen on port 12530
        log_level="info"  # Log level
    )
