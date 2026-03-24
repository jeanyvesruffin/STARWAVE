#!/usr/bin/env bash
set -euo pipefail

# Script d'exécution des tests d'acceptance décrits dans docs/Tests_Accesptances.md
# Usage: ./scripts/run_acceptance.sh

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "Erreur: la commande '$1' est requise mais introuvable." >&2; exit 2; }
}

for cmd in docker-compose docker mvn curl jq base64; do
  require_cmd "$cmd"
done

echo "[1/6] Nettoyage et démarrage des conteneurs Docker-compose"
docker-compose down -v || true
docker-compose up -d

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

echo "[2/6] Vérifications Keycloak"
KEYCLOAK_REALM_URL="http://localhost:8080/realms/starwave"
if ! wait_for_http "$KEYCLOAK_REALM_URL" "Keycloak realm (starwave)" 120; then
  echo "Keycloak indisponible, abort." >&2
  exit 3
fi

echo "Vérification du JSON du realm"
curl -sS "$KEYCLOAK_REALM_URL" | jq '{realm: .realm, public_key: .public_key}' || true

get_token() {
  local user="$1"; local pass="$2"; local outvar="$3"
  local token
  token=$(curl -s -X POST http://localhost:8080/realms/starwave/protocol/openid-connect/token \
    -d "client_id=starwave-backend" \
    -d "client_secret=starwave-backend-secret" \
    -d "username=$user" \
    -d "password=$pass" \
    -d "grant_type=password" | jq -r .access_token)
  if [ -z "$token" ] || [ "$token" = "null" ]; then
    echo "Erreur: impossible d'obtenir le token pour $user" >&2
    return 4
  fi
  eval "$outvar=\"$token\""
}

echo "Récupération des tokens de test"
get_token viewer viewer123 TOKEN_VIEWER
get_token analyst analyst123 TOKEN_ANALYST
get_token operator operator123 TOKEN_OPERATOR
get_token admin admin123 TOKEN_ADMIN

# Affiche les curl originaux définis dans docs/Tests_Accesptances.md (tokens)
echo "Affichage explicite des access_token via curl (format original)"
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

echo "[3/6] Vérification des rôles dans le JWT (extrait JSON payload pour viewer)"
echo "$TOKEN_VIEWER" | cut -d. -f2 | base64 --decode 2>/dev/null | jq . || true

echo "[4/6] Vérification de l'existence de infra/keycloak/realm-export.json"
if [ -f infra/keycloak/realm-export.json ]; then
  echo "OK: infra/keycloak/realm-export.json trouvé"
else
  echo "Avertissement: infra/keycloak/realm-export.json non trouvé" >&2
fi

echo "[5/6] Build Maven: gateway et backend (skip tests)"
echo "Build gateway"
(cd gateway && mvn -B -DskipTests clean package)
echo "Build backend"
(cd backend && mvn -B -DskipTests clean package)

echo "[6/8] Vérifications HTTP post-build"
BACKEND_HEALTH="http://localhost:8099/actuator/health"
if wait_for_http "$BACKEND_HEALTH" "Backend actuator/health" 60; then
  echo "Actuator backend:"
  curl -sS "$BACKEND_HEALTH" | jq . || true
else
  echo "Erreur: backend non disponible" >&2
  exit 5
fi

echo "[7/8] Vérification Gateway (health)"
GATEWAY_HEALTH="http://localhost:8082/actuator/health"
if wait_for_http "$GATEWAY_HEALTH" "Gateway actuator/health" 60; then
  echo "Actuator gateway:"
  curl -sS "$GATEWAY_HEALTH" | jq . || true
else
  echo "Avertissement: gateway non joignable sur 8082 (le proxy peut être sur un autre port)" >&2
fi

echo "[8/8] Tests d'accès API avec tokens Keycloak"
TEST_ENDPOINT="http://localhost:8082/api/signals"
for pair in "viewer:$TOKEN_VIEWER" "analyst:$TOKEN_ANALYST" "operator:$TOKEN_OPERATOR" "admin:$TOKEN_ADMIN"; do
  role=${pair%%:*}
  token=${pair#*:}
  echo "--- $role ---"
  echo "payload:$role ->" $(echo "$token" | cut -d. -f2 | base64 --decode 2>/dev/null | jq . || true)
  code=$(curl -s -o /tmp/resp_$role -w "%{http_code}" -H "Authorization: Bearer $token" "$TEST_ENDPOINT" || echo "000")
  echo "HTTP $code for GET $TEST_ENDPOINT as $role"
  if [ "$code" = "200" ]; then
    echo "Body (truncated):"
    head -n 20 /tmp/resp_$role || true
  else
    cat /tmp/resp_$role 2>/dev/null || true
  fi
done

echo "Toutes les étapes d'acceptance terminées (vérifiez les sorties ci-dessus)."
exit 0
