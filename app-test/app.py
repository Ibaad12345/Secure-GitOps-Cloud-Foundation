from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI(
    title="Cloud Foundation Service",
    version="0.1.0",
)

# Initialize and expose Prometheus metrics at /metrics
Instrumentator().instrument(app).expose(app)


@app.get("/")
def read_root():
    return {"message": "Cloud Foundation Service is running"}


@app.get("/health")
def health_check():
    return {"status": "healthy"}
