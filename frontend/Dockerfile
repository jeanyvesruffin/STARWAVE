# =============================================================================
# STARWAVE Frontend – Angular 21 dev server
# =============================================================================

FROM node:22-alpine

LABEL org.opencontainers.image.title="STARWAVE Frontend"

# Dépendances système
RUN apk add --no-cache curl

# Utilisateur non-root
RUN addgroup -S starwave && adduser -S starwave -G starwave

WORKDIR /app

# Copier package.json et installer les dépendances (cache layer)
COPY --chown=starwave:starwave package*.json ./

# Utiliser npm avec le packageManager défini dans package.json
RUN npm ci --prefer-offline

# Copier les sources
COPY --chown=starwave:starwave . .

USER starwave

EXPOSE 4200

ENV NODE_ENV=development

HEALTHCHECK --interval=20s --timeout=10s --retries=5 --start-period=60s \
  CMD curl -f http://localhost:4200 || exit 1

# --host 0.0.0.0 requis pour être accessible hors du conteneur
# --disable-host-check pour éviter les erreurs de host binding en dev
CMD ["npx", "ng", "serve", "--host", "0.0.0.0", "--port", "4200", "--disable-host-check"]
