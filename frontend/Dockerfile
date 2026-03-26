# =============================================================================
# STARWAVE Frontend – Angular 21 dev server
# =============================================================================

FROM node:24-bookworm-slim

LABEL org.opencontainers.image.title="STARWAVE Frontend - dev"

RUN addgroup --system starwave && adduser --system --ingroup starwave starwave
WORKDIR /app
COPY package*.json ./
RUN npm ci --prefer-offline
COPY . .
RUN chown -R starwave:starwave /app || true

# Install wget and procps (pgrep) so the HEALTHCHECK command can run inside the image
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    procps \
  && rm -rf /var/lib/apt/lists/*
USER starwave

# Ensure ng CLI is available (installed as devDependency by npm ci)
EXPOSE 4200

HEALTHCHECK --interval=20s --timeout=10s --retries=5 --start-period=10s \
  CMD wget -q -O /dev/null http://localhost:4200 || exit 1

USER starwave
CMD ["npm", "start"]
