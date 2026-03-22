# =============================================================================
# STARWAVE Worker – crossmatch (FastAPI, mode CPU dev)
# =============================================================================

FROM python:3.12-slim AS base

LABEL org.opencontainers.image.title="STARWAVE Worker – Crossmatch"

# Dépendances système minimales
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
  && rm -rf /var/lib/apt/lists/*

# Utilisateur non-root
RUN useradd -m -u 1000 worker
USER worker
WORKDIR /app

# Dépendances Python
COPY --chown=worker:worker requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Sources
COPY --chown=worker:worker . .

EXPOSE 8001

ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    WORKER_PORT=8001

HEALTHCHECK --interval=15s --timeout=5s --retries=5 \
  CMD curl -f http://localhost:8001/health || exit 1

CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001"]
