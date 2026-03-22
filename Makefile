# =============================================================================
# STARWAVE – Makefile
# Usage : make <target>
# =============================================================================

.DEFAULT_GOAL := help
COMPOSE        = docker compose
ENV_FILE       = .env

# ---------------------------------------------------------------------------
# Couleurs
# ---------------------------------------------------------------------------
CYAN  = \033[0;36m
RESET = \033[0m

.PHONY: help init up down restart logs ps build clean nuke \
        backend-logs gateway-logs kafka-logs keycloak-logs \
        mariadb-shell kafka-topics kafka-consume \
        test-backend

## ─── Aide ───────────────────────────────────────────────────────────────────

help: ## Affiche cette aide
	@echo ""
	@echo "  STARWAVE – commandes disponibles"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-25s$(RESET) %s\n", $$1, $$2}'
	@echo ""

## ─── Setup ───────────────────────────────────────────────────────────────────

init: ## Initialise l'environnement (copie .env.example → .env)
	@if [ ! -f $(ENV_FILE) ]; then \
	  cp .env.example $(ENV_FILE); \
	  echo "  ✅  .env créé depuis .env.example – pense à changer les mots de passe !"; \
	else \
	  echo "  ℹ️   .env existe déjà, rien à faire."; \
	fi

## ─── Cycle de vie ────────────────────────────────────────────────────────────

up: ## Démarre tous les services en arrière-plan
	$(COMPOSE) up -d

up-build: ## Rebuild les images et démarre tous les services
	$(COMPOSE) up -d --build

down: ## Arrête et supprime les conteneurs (volumes préservés)
	$(COMPOSE) down

restart: ## Redémarre tous les services
	$(COMPOSE) restart

ps: ## Affiche l'état des services
	$(COMPOSE) ps

## ─── Build ───────────────────────────────────────────────────────────────────

build: ## Construit toutes les images Docker
	$(COMPOSE) build

build-backend: ## Construit uniquement l'image backend
	$(COMPOSE) build backend

build-gateway: ## Construit uniquement l'image gateway
	$(COMPOSE) build gateway

build-frontend: ## Construit uniquement l'image frontend
	$(COMPOSE) build frontend

build-workers: ## Construit les images workers Python
	$(COMPOSE) build worker-crossmatch worker-spectral worker-gpu

## ─── Logs ────────────────────────────────────────────────────────────────────

logs: ## Suit les logs de tous les services
	$(COMPOSE) logs -f

backend-logs: ## Suit les logs du backend
	$(COMPOSE) logs -f backend

gateway-logs: ## Suit les logs de la gateway
	$(COMPOSE) logs -f gateway

kafka-logs: ## Suit les logs de Kafka
	$(COMPOSE) logs -f kafka

keycloak-logs: ## Suit les logs de Keycloak
	$(COMPOSE) logs -f keycloak

frontend-logs: ## Suit les logs du frontend
	$(COMPOSE) logs -f frontend

## ─── Kafka ───────────────────────────────────────────────────────────────────

kafka-topics: ## Liste les topics Kafka
	$(COMPOSE) exec kafka kafka-topics.sh \
	  --bootstrap-server localhost:9092 --list

kafka-create-topics: ## Crée les topics STARWAVE
	$(COMPOSE) exec kafka bash -c "\
	  kafka-topics.sh --bootstrap-server localhost:9092 --create --if-not-exists --topic starwave.signals.raw       --partitions 3 --replication-factor 1; \
	  kafka-topics.sh --bootstrap-server localhost:9092 --create --if-not-exists --topic starwave.signals.processed  --partitions 3 --replication-factor 1; \
	  kafka-topics.sh --bootstrap-server localhost:9092 --create --if-not-exists --topic starwave.crossmatch.request --partitions 3 --replication-factor 1; \
	  kafka-topics.sh --bootstrap-server localhost:9092 --create --if-not-exists --topic starwave.crossmatch.result  --partitions 3 --replication-factor 1; \
	  kafka-topics.sh --bootstrap-server localhost:9092 --create --if-not-exists --topic starwave.spectral.request   --partitions 3 --replication-factor 1; \
	  kafka-topics.sh --bootstrap-server localhost:9092 --create --if-not-exists --topic starwave.spectral.result    --partitions 3 --replication-factor 1; \
	  echo '✅  Topics créés.'"

kafka-consume: ## Consomme le topic starwave.signals.raw (CTRL+C pour quitter)
	$(COMPOSE) exec kafka kafka-console-consumer.sh \
	  --bootstrap-server localhost:9092 \
	  --topic starwave.signals.raw \
	  --from-beginning \
	  --property print.key=true

## ─── Base de données ─────────────────────────────────────────────────────────

mariadb-shell: ## Ouvre un shell MySQL dans le conteneur MariaDB
	$(COMPOSE) exec mariadb mariadb \
	  -u $$(grep MARIADB_USER $(ENV_FILE) | cut -d= -f2) \
	  -p$$(grep MARIADB_PASSWORD $(ENV_FILE) | cut -d= -f2) \
	  $$(grep MARIADB_DATABASE $(ENV_FILE) | cut -d= -f2)

mariadb-dump: ## Exporte la base de données vers ./backup.sql
	$(COMPOSE) exec mariadb mariadb-dump \
	  -u root -p$$(grep MARIADB_ROOT_PASSWORD $(ENV_FILE) | cut -d= -f2) \
	  --all-databases > backup.sql
	@echo "  ✅  Dump sauvegardé dans backup.sql"

## ─── Tests ───────────────────────────────────────────────────────────────────

test-backend: ## Lance les tests unitaires du backend (Maven)
	cd backend && mvn test

health-check: ## Vérifie le healthcheck de tous les services
	@echo "\n  Services health:"
	@$(COMPOSE) ps --format "table {{.Name}}\t{{.Status}}" | \
	  awk 'NR==1 {print} NR>1 {status=$$NF; if (status~/healthy/) color="\033[32m"; else if (status~/unhealthy/) color="\033[31m"; else color="\033[33m"; printf "%s%-50s\033[0m\n", color, $$0}'

## ─── Nettoyage ───────────────────────────────────────────────────────────────

clean: ## Supprime les conteneurs et les images STARWAVE
	$(COMPOSE) down --rmi local

nuke: ## ⚠️  DANGER – Supprime TOUT (conteneurs, images, volumes)
	@echo "  ⚠️  Cette commande va supprimer TOUTES les données persistantes !"
	@read -p "  Confirmer ? (yes/N) : " confirm && [ "$$confirm" = "yes" ] || exit 1
	$(COMPOSE) down -v --rmi all --remove-orphans
	@echo "  🧹  Environnement nettoyé."

## ─── URLs utiles ─────────────────────────────────────────────────────────────

urls: ## Affiche les URLs des services
	@echo ""
	@echo "  ┌─────────────────────────────────────────────────────────┐"
	@echo "  │  STARWAVE – Accès locaux                                │"
	@echo "  ├──────────────────────┬──────────────────────────────────┤"
	@echo "  │  Frontend Angular    │  http://localhost:4200           │"
	@echo "  │  Gateway API         │  http://localhost:8082/api       │"
	@echo "  │  Backend Actuator    │  http://localhost:8081/actuator  │"
	@echo "  │  Keycloak Admin      │  http://localhost:8080           │"
	@echo "  │  Kafka UI            │  http://localhost:8090           │"
	@echo "  │  Prometheus          │  http://localhost:9090           │"
	@echo "  │  Grafana             │  http://localhost:3000           │"
	@echo "  │  Worker Crossmatch   │  http://localhost:8001/docs      │"
	@echo "  │  Worker Spectral     │  http://localhost:8002/docs      │"
	@echo "  │  Worker GPU          │  http://localhost:8003/docs      │"
	@echo "  └──────────────────────┴──────────────────────────────────┘"
	@echo ""
