#!/usr/bin/env bash
set -euo pipefail

# Script d'exécution des tests d'acceptance décrits dans docs/Tests_Accesptances.md
# Ce script exécute strictement les commandes listées dans le document d'acceptance

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

wait_for_http() {
  local url="$1"; local desc="$2"; local max_wait=${3:-120}
  echo "Attente $desc → $url"
  local waited=0
  while true; do
    if curl -sS "$url" >/dev/null 2>&1; then
      echo "OK: $desc est joignable"
      return 0
    fi
    sleep 2
    waited=$((waited+2))
    if [ "$waited" -ge "$max_wait" ]; then
      echo "Erreur: timeout en attendant $desc ($url)" >&2
      return 1
    fi
  done
}

echo "\n2) KeyCloak — Critère 1: realm pré-chargé"
KEYCLOAK_REALM_URL="http://localhost:8080/realms/starwave"
if ! wait_for_http "$KEYCLOAK_REALM_URL" "Keycloak realm (starwave)" 120; then
  echo "Keycloak indisponible, abort." >&2
  exit 3
fi

echo "Réponse (raw) pour $KEYCLOAK_REALM_URL"
curl -sS "$KEYCLOAK_REALM_URL" || true

echo "\n3) KeyCloak — Critère 2: récupérer tokens JWT pour chaque rôle"
echo "# ROLE_VIEWER"
curl -s -X POST http://localhost:8080/realms/starwave/protocol/openid-connect/token \
  -d "client_id=starwave-backend" \
  -d "client_secret=starwave-backend-secret" \
  -d "username=viewer" \
  -d "password=viewer123" \
  -d "grant_type=password" | jq .access_token || true

echo "# ROLE_ANALYST"
curl -s -X POST http://localhost:8080/realms/starwave/protocol/openid-connect/token \
  -d "client_id=starwave-backend" \
  -d "client_secret=starwave-backend-secret" \
  -d "username=analyst" \
  -d "password=analyst123" \
  -d "grant_type=password" | jq .access_token || true

echo "# ROLE_OPERATOR"
curl -s -X POST http://localhost:8080/realms/starwave/protocol/openid-connect/token \
  -d "client_id=starwave-backend" \
  -d "client_secret=starwave-backend-secret" \
  -d "username=operator" \
  -d "password=operator123" \
  -d "grant_type=password" | jq .access_token || true

echo "# ROLE_ADMIN"
curl -s -X POST http://localhost:8080/realms/starwave/protocol/openid-connect/token \
  -d "client_id=starwave-backend" \
  -d "client_secret=starwave-backend-secret" \
  -d "username=admin" \
  -d "password=admin123" \
  -d "grant_type=password" | jq .access_token || true

echo "\n4) KeyCloak — Critère 3: attributs rôles présents dans le JWT (viewer)"
TOKEN=$(curl -s -X POST http://localhost:8080/realms/starwave/protocol/openid-connect/token \
  -d "client_id=starwave-backend" \
  -d "client_secret=starwave-backend-secret" \
  -d "username=viewer" \
  -d "password=viewer123" \
  -d "grant_type=password" | jq -r .access_token)

if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
  echo "$TOKEN" | cut -d. -f2 | base64 -d 2>/dev/null | jq . || true
else
  echo "Impossible de récupérer le token viewer" >&2
fi

echo "\n5) KeyCloak — Critère 4: vérifier infra/keycloak/realm-export.json versionné"
ls -la infra/keycloak/realm-export.json || true
git status -- infra/keycloak/realm-export.json || true
git log --oneline -- infra/keycloak/realm-export.json || true

echo "\n6) Spring-boot — Backend: health"
curl -sS http://localhost:8099/actuator/health | jq . || true

echo "\n7) Spring-boot — Gateway: health"
curl -sS http://localhost:8098/actuator/health | jq . || true

echo "\nTests d'acceptance terminés (exécutés selon docs/Tests_Accesptances.md)."
exit 0
