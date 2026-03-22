"""
STARWAVE – Workers (generic)
FastAPI app – point d'entrée (stub dev)
"""
import os
from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI(
    title="STARWAVE Workers",
    description="Workers génériques de traitement de signaux (mode CPU simulé en dev)",
    version="0.0.1-SNAPSHOT",
)

Instrumentator().instrument(app).expose(app)

@app.get("/health")
async def health():
    return {"status": "UP", "worker": "gpu", "mode": os.getenv("WORKER_MODE", "cpu")}

@app.get("/info")
async def info():
    return {
        "kafka":  os.getenv("KAFKA_BOOTSTRAP_SERVERS"),
        "redis":  os.getenv("REDIS_URL"),
        "worker": "gpu",
    }
