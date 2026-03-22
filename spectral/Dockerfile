# =============================================================================
# STARWAVE Worker – spectral (FastAPI, mode CPU dev)
# =============================================================================

FROM python:3.12-slim AS base

LABEL org.opencontainers.image.title="STARWAVE Worker – Spectral"

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 worker
USER worker
WORKDIR /app

COPY --chown=worker:worker requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

COPY --chown=worker:worker . .

EXPOSE 8002

ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    WORKER_PORT=8002

HEALTHCHECK --interval=15s --timeout=5s --retries=5 \
  CMD curl -f http://localhost:8002/health || exit 1

CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8002"]
