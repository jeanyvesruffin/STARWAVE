# =============================================================================
# STARWAVE Frontend – Angular 21 dev server
# =============================================================================

FROM node:22-bullseye-slim

LABEL org.opencontainers.image.title="STARWAVE Frontend - dev"

RUN addgroup --system starwave && adduser --system --ingroup starwave starwave
WORKDIR /app
COPY package*.json ./
RUN npm ci --prefer-offline
COPY . .
RUN chown -R starwave:starwave /app || true

# Ensure ng CLI is available (installed as devDependency by npm ci)
EXPOSE 4200

HEALTHCHECK --interval=20s --timeout=10s --retries=5 --start-period=10s \
  CMD wget -q -O /dev/null http://localhost:4200 || exit 1

USER starwave
CMD ["npm", "start"]
