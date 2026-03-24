# Tests_Accesptances

Prerequis demarrer docker Desktop

```bash
docker-compose down -v
docker system prune -a --volumes -f
docker-compose up -d
```

## KeyCloak

### Critère 1 — Keycloak démarre avec realm pré-chargé

```bash
curl http://localhost:8080/realms/starwave
```

✅ Réponse attendue : un JSON avec "realm": "starwave" et "public_key": "...".

### Critère 2 — Token JWT obtenu pour chaque rôle de test

```bash
# ROLE_VIEWER
curl -s -X POST http://localhost:8080/realms/starwave/protocol/openid-connect/token \
  -d "client_id=starwave-backend" \
  -d "client_secret=starwave-backend-secret" \
  -d "username=viewer" \
  -d "password=viewer123" \
  -d "grant_type=password" | jq .access_token

# ROLE_ANALYST
curl -s -X POST http://localhost:8080/realms/starwave/protocol/openid-connect/token \
  -d "client_id=starwave-backend" \
  -d "client_secret=starwave-backend-secret" \
  -d "username=analyst" \
  -d "password=analyst123" \
  -d "grant_type=password" | jq .access_token

# ROLE_OPERATOR
curl -s -X POST http://localhost:8080/realms/starwave/protocol/openid-connect/token \
  -d "client_id=starwave-backend" \
  -d "client_secret=starwave-backend-secret" \
  -d "username=operator" \
  -d "password=operator123" \
  -d "grant_type=password" | jq .access_token

# ROLE_ADMIN
curl -s -X POST http://localhost:8080/realms/starwave/protocol/openid-connect/token \
  -d "client_id=starwave-backend" \
  -d "client_secret=starwave-backend-secret" \
  -d "username=admin" \
  -d "password=admin123" \
  -d "grant_type=password" | jq .access_token
```

✅ Réponse attendue : un token JWT (eyJ...) pour chacun.

Via IHM Keycloak

Users → cherche viewer → onglet Role mappings → vérifie ROLE_VIEWER assigné
Répète pour analyst, operator, admin

### Critère 3 — Attributs rôles présents dans le JWT

```bash
# Récupère le token et décode le payload en une seule commande
TOKEN=$(curl -s -X POST http://localhost:8080/realms/starwave/protocol/openid-connect/token \
  -d "client_id=starwave-backend" \
  -d "client_secret=starwave-backend-secret" \
  -d "username=viewer" \
  -d "password=viewer123" \
  -d "grant_type=password" | jq -r .access_token)

# Décode le payload du JWT (partie centrale entre les deux points)
echo $TOKEN | cut -d. -f2 | base64 -d 2>/dev/null | jq .
```

✅ Réponse attendue pour viewer :

```json
{
  "sub": "...",
  "preferred_username": "viewer",
  "roles": ["ROLE_VIEWER"],
  "realm_access": {
    "roles": ["ROLE_VIEWER"]
  }
}
```

Via IHM Keycloak — outil intégré

Clients → starwave-backend → onglet Client scopes
Clique sur Evaluate (ou "Évaluer")
Dans User tape viewer → clique Generate access token
Inspecte le token affiché → vérifie la présence de roles: ["ROLE_VIEWER"]

### Critère 4 — Fichier realm-export.json versionné

```bash
# Vérifie que le fichier est bien présent dans le repo
ls -la infra/keycloak/realm-export.json

# Vérifie qu'il est tracké par git
git status infra/keycloak/realm-export.json
git log --oneline infra/keycloak/realm-export.json
```

✅ Réponse attendue : le fichier apparaît dans git log

## Spring-boot

### Backend

```bash
curl -sS http://localhost:8099/actuator/health | jq .
```

```json
{
  "status": "UP",
  "groups": [
    "liveness",
    "readiness"
  ],
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "MariaDB",
        "validationQuery": "isValid()"
      }
    },
    "diskSpace": {
      "status": "UP",
      "details": {
        "total": 1081101176832,
        "free": 1003410743296,
        "threshold": 10485760,
        "path": "/app/.",
        "exists": true
      }
    },
    "livenessState": {
      "status": "UP"
    },
    "ping": {
      }
    },
    "diskSpace": {
      "status": "UP",
      "details": {
        "total": 1081101176832,
        "free": 1003410743296,
        "threshold": 10485760,
        "path": "/app/.",
        "exists": true
      }
    },
    "livenessState": {
      "status": "UP"
    },
    "ping": {
    "diskSpace": {
      "status": "UP",
      "details": {
        "total": 1081101176832,
        "free": 1003410743296,
        "threshold": 10485760,
        "path": "/app/.",
        "exists": true
      }
    },
    "livenessState": {
      "status": "UP"
    },
    "ping": {
        "total": 1081101176832,
        "free": 1003410743296,
        "threshold": 10485760,
        "path": "/app/.",
        "exists": true
      }
    },
    "livenessState": {
      "status": "UP"
    },
    "ping": {
      "status": "UP"
    },
    "readinessState": {
      "status": "UP"
    },
    "livenessState": {
      "status": "UP"
    },
    "ping": {
      "status": "UP"
    },
    "readinessState": {
      "status": "UP"
    },
    "ssl": {
      "status": "UP"
    },
    "readinessState": {
      "status": "UP"
    },
    "ssl": {
      "status": "UP",
      "details": {
    },
    "ssl": {
      "status": "UP",
      "details": {
      "status": "UP",
      "details": {
        "validChains": [],
        "validChains": [],
        "invalidChains": []
        "invalidChains": []
      }
    }
  }
}
```

### Gateway

```bash
curl -sS http://localhost:8098/actuator/health | jq .
```

```json
{
  "components": {
    "discoveryComposite": {
      "components": {
        "discoveryClient": {
          "description": "Discovery Client not initialized",
          "status": "UNKNOWN"
        }
      },
      "description": "Discovery Client not initialized",
      "status": "UNKNOWN"
    },
    "diskSpace": {
      "details": {
        "total": 1081101176832,
        "free": 1009970860032,
        "threshold": 10485760,
        "path": "/app/.",
        "exists": true
      },
      "status": "UP"
    },
    "livenessState": {
      "status": "UP"
    },
    "ping": {
      "status": "UP"
    },
    "reactiveDiscoveryClients": {
    "reactiveDiscoveryClients": {
    "reactiveDiscoveryClients": {
    "reactiveDiscoveryClients": {
      "components": {
    "reactiveDiscoveryClients": {
      "components": {
        "Simple Reactive Discovery Client": {
      "components": {
      "components": {
        "Simple Reactive Discovery Client": {
          "description": "Discovery Client not initialized",                              
          "status": "UNKNOWN"
        }
      },
      "description": "Discovery Client not initialized",
      "status": "UNKNOWN"
    },
    "readinessState": {
      "status": "UP"
    },
    "refreshScope": {
      "status": "UP"
    },
    "ssl": {
      "details": {
        "expiringChains": [],
        "invalidChains": [],
        "validChains": []
      },
      "status": "UP"
    }
  },
  "groups": [
    "liveness",
    "readiness"
  ],
  "status": "UP"
}
```
