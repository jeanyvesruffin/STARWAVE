#!/usr/bin/env bash
# =============================================================================
# STARWAVE – Vérification complète
# Usage : bash check.sh
# =============================================================================

if [ -f .env ]; then
  set -a; source .env; set +a
fi

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
RESET='\033[0m'

pass()    { echo -e "${GREEN}  ✅  $1${RESET}"; }
warn()    { echo -e "${YELLOW}  ⚠️   $1${RESET}"; }
fail()    { echo -e "${RED}  ❌  $1${RESET}"; }
section() { echo -e "\n${YELLOW}▶ $1${RESET}"; }

TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

# check_http <label> <url> [expected_body_keyword]
# 2xx      → ✅
# 401/403  → ⚠️  (service UP mais protégé – normal)
# 000/5xx  → ❌
check_http() {
  local label="$1" url="$2" expected="$3"
  local code body
  code=$(curl -s -o "$TMPFILE" -w "%{http_code}" --max-time 5 "$url" 2>/dev/null)
  body=$(cat "$TMPFILE" 2>/dev/null || echo "")

  if [[ "$code" =~ ^2 ]]; then
    if [[ -n "$expected" && "$body" != *"$expected"* ]]; then
      fail "$label → HTTP $code (body sans '$expected')"
    else
      pass "$label → HTTP $code"
    fi
  elif [[ "$code" =~ ^(401|403)$ ]]; then
    warn "$label → HTTP $code (service UP, endpoint protégé)"
  else
    fail "$label → HTTP $code  ←  $url"
  fi
}

# check_docker <label> <container_name>
# Vérifie l'état Docker directement
check_docker() {
  local label="$1" name="$2"
  local status
  status=$(docker inspect --format='{{.State.Health.Status}}' "$name" 2>/dev/null || echo "absent")
  case "$status" in
    healthy)   pass "$label → healthy" ;;
    starting)  warn "$label → starting (en cours)" ;;
    unhealthy) fail "$label → unhealthy" ;;
    absent)    fail "$label → conteneur absent" ;;
    *)         warn "$label → $status" ;;
  esac
}

# =============================================================================

section "ÉTAT DOCKER (source de vérité)"
check_docker "MariaDB         " "starwave-mariadb"
check_docker "Kafka           " "starwave-kafka"
check_docker "Redis           " "starwave-redis"
check_docker "Keycloak        " "starwave-keycloak"
check_docker "Backend         " "starwave-backend"
check_docker "Gateway         " "starwave-gateway"
check_docker "Frontend        " "starwave-frontend"
check_docker "Worker crossmatch" "starwave-worker-crossmatch"
check_docker "Worker spectral " "starwave-worker-spectral"
check_docker "Workers GPU     " "starwave-workers"
check_docker "Prometheus      " "starwave-prometheus"
check_docker "Grafana         " "starwave-grafana"

section "FRONTEND & GATEWAY"
check_http "Frontend Angular          " "http://localhost:${FRONTEND_PORT:-4200}"
check_http "Gateway API (8082)        " "http://localhost:${GATEWAY_PORT:-8082}/actuator/health"  "UP"

section "BACKEND Spring Boot"
check_http "Backend API (8081)        " "http://localhost:${BACKEND_PORT:-8081}/api/actuator/health" "UP"
# Prioritise management port on host for health/prometheus (stable for scraping)
check_http "Backend mgmt (8099)       " "http://localhost:8099/actuator/health"                      "UP"
check_http "Backend Prometheus (8099) " "http://localhost:8099/actuator/prometheus"                  "jvm_memory"

# fallback: when a host HTTP check fails, show recent container logs for diagnosis
fallback_logs_if_unhealthy() {
  local label="$1" url="$2" container="$3"
  # run the check again but capture code
  local code
  code=$(curl -s -o "$TMPFILE" -w "%{http_code}" --max-time 5 "$url" 2>/dev/null || echo "000")
  if [[ ! "$code" =~ ^2 ]]; then
    echo -e "\n${YELLOW}▶ Fallback for $label: host check failed (HTTP $code). Showing last 50 logs from container '$container'${RESET}"
    docker logs --tail=50 "$container" 2>/dev/null || echo "(impossible de lire les logs du conteneur $container)"
  fi
}

# Use fallback for critical backend checks
fallback_logs_if_unhealthy "Backend mgmt" "http://localhost:8099/actuator/health" "starwave-backend"
fallback_logs_if_unhealthy "Backend Prometheus" "http://localhost:8099/actuator/prometheus" "starwave-backend"

section "KEYCLOAK"
check_http "Keycloak readiness (9000) " "http://localhost:9000/health/ready"                                                   "UP"
check_http "Realm starwave            " "http://localhost:${KEYCLOAK_PORT:-8080}/realms/starwave"                              "starwave"
check_http "JWKS                      " "http://localhost:${KEYCLOAK_PORT:-8080}/realms/starwave/protocol/openid-connect/certs" "keys"

section "WORKERS Python (FastAPI)"
check_http "Crossmatch health         " "http://localhost:${WORKER_CROSSMATCH_PORT:-8001}/health"       "UP"
check_http "Spectral health           " "http://localhost:${WORKER_SPECTRAL_PORT:-8002}/health"         "UP"
check_http "Workers GPU health        " "http://localhost:${WORKER_GPU_PORT:-8003}/health"              "UP"

section "OBSERVABILITÉ"
check_http "Prometheus                " "http://localhost:${PROMETHEUS_PORT:-9090}/-/healthy"           "Prometheus"
check_http "Prometheus targets        " "http://localhost:${PROMETHEUS_PORT:-9090}/api/v1/targets"      "activeTargets"
check_http "Grafana                   " "http://localhost:${GRAFANA_PORT:-3000}/api/health"             "ok"
check_http "Grafana datasources       " "http://${GRAFANA_ADMIN_USER:-admin}:${GRAFANA_ADMIN_PASSWORD:-admin}@localhost:${GRAFANA_PORT:-3000}/api/datasources" "Prometheus"
check_http "Kafka UI                  " "http://localhost:${KAFKA_UI_PORT:-8090}"

echo -e "\n${CYAN}  Vérification terminée.${RESET}"
echo -e "${GRAY}  ⚠️  = service UP mais accès protégé (normal pour endpoints sécurisés)${RESET}\n"
