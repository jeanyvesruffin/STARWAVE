# 🌌 S.T.A.R.W.A.V.E. — Copilot Instructions

> **SETI Tracking & Analysis of Radio Waves for ESA**  
> Ces instructions définissent le contexte, les conventions et les contraintes que GitHub Copilot doit respecter pour assister le développement de ce projet.

---

## 1. Vision & Contexte Projet

S.T.A.R.W.A.V.E. est une plateforme de **Mission Control** pour l'ESA destinée à l'analyse automatisée de signaux radio profonds. Son objectif est de détecter des technosignatures non-humaines via un pipeline de traitement intensif, une IA hybride CNN-Transformer, et une IHM temps réel orientée War Room.

L'architecture suit un pattern **event-driven + batch hybride** :

1. **Ingestion** : Apache Kafka absorbe les flux bruts des télescopes ESA/SETI et les fichiers Breakthrough Listen (.h5 / I-Q).
2. **Traitement** : Spring Batch 5.x (Master/Worker) orchestre la normalisation, le filtrage RFI et la FFT via des workers GPU FastAPI/CuPy.
3. **Analyse IA** : Un modèle CNN-Transformer exporté en ONNX calcule l'**Indice de Signature Technologique** (`I_st`) et classe les signaux en Alpha / Beta / Omega.
4. **Restitution** : Angular 21 affiche le Waterfall WebGPU, la carte du ciel et les alertes en temps réel via WebSocket STOMP.

---

## 2. Stack Technique de Référence

### Backend (Java)
- **Java 25** avec Virtual Threads (`spring.threads.virtual.enabled=true`)
- **Spring Boot 4.0.4** — modules actifs :
  - `spring-batch` (orchestration pipeline, partitioning, JobRepository)
  - `spring-messaging` + `spring-websocket` (push STOMP frames Waterfall)
  - `spring-hateoas` (toutes les ressources REST sont auto-descriptives)
  - `spring-security` OAuth2 Resource Server (validation JWT Keycloak)
  - `spring-ai` (ONNX Runtime embarqué en JVM, inférence < 2 ms)
  - `spring-cloud-gateway` (rate-limiting, routage, auth centralisée)
  - `micrometer-registry-prometheus` (export métriques)
- **MariaDB** (InnoDB) : stockage principal signaux, alertes, jobs, poids `I_st`
- **Redis** : cache fenêtres de visibilité (TTL 1h), résultats cross-match récurrents
- **Resilience4j** : Circuit Breakers sur toutes les APIs externes (MAST, SIMBAD, etc.)
- **HashiCorp Vault** : gestion de tous les secrets (clés API, credentials DB, clé signature PDF)

### Backend (Python)
- **FastAPI / Python 3.15.0a7** : workers GPU (FFT CuPy, Deep-Drift Hough, extraction features)
- **CuPy / NumPy / SciPy** : calculs GPU (CUDA 12.x)
- **Astroquery / PostGIS** : service de cross-match (ATNF, FRBcat, SIMBAD, TLE)
- **asyncio** : requêtes parallèles du Spectral Context Service (MAST, HEASARC, Gaia, SDSS)

### Frontend
- **Angular 21** avec Signals (réactivité fine)
- **WebGPU** (compute shaders WGSL) pour le rendu Waterfall 60 fps ; fallback WebGL 2
- **WebSocket STOMP** pour la réception des frames en temps réel
- **Leaflet + Aladin Lite v3** pour la carte du ciel interactive
- **Service Workers** pour les notifications Push et le mode offline

### Infrastructure
- **Kubernetes / K3s** (production/edge), **Docker Compose** (dev)
- **Apache Kafka** (StatefulSet, partitions par plage de fréquences)
- **Keycloak** : RBAC (Visiteur / Explorer / Analyst / Commander / Admin Infra)
- **Prometheus + Grafana + Loki** : observabilité complète
- **GitOps** : ArgoCD / Flux avec overlays Kustomize (dev / staging / prod)
- **Terraform + Helm** : IaC pour provisioning sites d'écoute

---

## 3. Structure du Dépôt

```
starwave-platform/
├── infrastructure/
│   ├── terraform/
│   │   ├── modules/       # k8s-cluster, gpu-nodes, storage
│   │   └── envs/          # dev, staging, prod
│   ├── ansible/
│   │   └── playbooks/     # nvidia-toolkit.yml, post-provisioning.yml
│   └── helm/
│       ├── starwave-app/  # Chart principal
│       ├── starwave-data/ # Kafka, MariaDB, Redis, PostGIS, MinIO
│       └── starwave-infra/# Keycloak, Vault, Prometheus, Grafana, Loki
├── apps/
│   ├── backend/           # Spring Boot multi-module Maven
│   ├── gpu-worker/        # FastAPI + CuPy
│   ├── frontend/          # Angular 21
│   ├── crossmatch-service/# Python Astroquery + PostGIS
│   └── spectral-context/  # Python Astroquery async
└── gitops/
    ├── argocd/
    └── kustomize/
        ├── base/
        ├── overlays/dev/
        ├── overlays/staging/
        └── overlays/prod/
```

---

## 4. Conventions de Code

### 4.1 Java / Spring Boot

- Utiliser **Virtual Threads** pour tout traitement I/O dans les steps Batch ; ne pas créer de pool de threads OS manuellement.
- Tous les endpoints REST exposent des ressources **HATEOAS** (`EntityModel`, `CollectionModel`). Chaque réponse `GET /signals/{id}` inclut les liens : `self`, `reanalyze`, `archive`, `view-on-sky-map`, `spectrum`, `explain`, `generate-report`.
- Les **jobs Spring Batch** doivent toujours être idempotents et reprendre depuis le dernier `stepId` en échec via `JobOperator`. Utiliser `@StepScope` pour les beans partitionnés.
- Les **poids `I_st`** (`w_snr`, `w_narrow_band`, `w_doppler`, `w_compress`, `w_repetition`, `w_crossmatch`) sont lus depuis la table `ist_weights` (version active). Ne jamais les coder en dur.
- Les **règles de gestion** (RG-01 à RG-10) sont implémentées dans un `RulesEngine` dédié, déclenché post-INSERT en base. Ne pas les disperser dans les services métier.
- Toute action sensible (relance batch, modification seuils IA, acquittement alerte) vérifie le rôle JWT Keycloak via `@PreAuthorize("hasRole('ROLE_COMMANDER')")` ou équivalent.
- Préfixer toutes les métriques Micrometer avec `starwave.` (ex : `starwave.batch.job.duration`, `starwave.signal.ist.histogram`).
- Les logs utilisent SLF4J en JSON structuré avec les champs : `traceId`, `spanId`, `jobId`, `signalId`, `userId`, `role`.

### 4.2 Python (FastAPI GPU Worker & Services)

- Les endpoints GPU exposent exclusivement : `POST /compute/fft`, `POST /compute/drift`, `POST /compute/features`, `GET /health`.
- Le service Spectral Context effectue les quatre requêtes (MAST, HEASARC, Gaia, SDSS) en **`asyncio.gather`** — ne jamais les séquentialiser.
- Les requêtes spatiales PostGIS utilisent `ST_DWithin` avec index GIST ; ne jamais faire de cone-search en Python pur.
- Tous les appels aux APIs externes (MAST, SIMBAD, ATNF, IGWN) sont enveloppés dans un **Circuit Breaker Resilience4j** côté Java ou un équivalent `tenacity` côté Python, avec retry x3 et backoff exponentiel.
- Le cache Redis est systématique pour les cross-match redondants (TTL 1h) et les fenêtres de visibilité (TTL configuré selon la période orbitale).

### 4.3 Angular (Frontend)

- Utiliser les **Signals Angular** pour toute réactivité locale ; éviter les `BehaviorSubject` RxJS sauf pour les flux WebSocket STOMP.
- Le rendu Waterfall passe impérativement par **WebGPU** (compute shader WGSL) ; prévoir le fallback WebGL 2 dans un service dédié `WaterfallRendererService`.
- Les actions HATEOAS (`reanalyze`, `archive`, `view-on-sky-map`, `generate-report`) sont lues depuis les liens `_links` de la réponse API ; ne jamais construire les URLs à la main.
- Le modal signal expose toujours le **Radar Chart** (bande passante, Doppler, régularité) et l'accès au panneau **Spectral Context**.
- La géolocalisation est **opt-in** (`session-only` | `save-in-profile` | `anonymous/hashed`) ; ne jamais appeler `navigator.geolocation` sans consentement explicite.
- Les badges de visibilité sur la carte sont : vert (visible maintenant), orange (bientôt — ETA HH:MM), gris (non visible). Ce code couleur est normalisé.
- Respecter les labels ARIA et la navigation clavier pour l'accessibilité ; les thèmes haute-contraste sont disponibles.

---

## 5. Modèle de Données — Rappel des Tables Clés

| Table | Usage |
|---|---|
| `signal` | Signaux candidats avec `i_st`, `classification` (Alpha/Beta/Omega), `status` (CANDIDATE/CONFIRMED/ARCHIVED/EXPLAINED) |
| `signal_provenance` | Résultats cross-match avec catalogue source, `separation_deg`, `confidence` (CERTAIN/PROBABLE/POSSIBLE) |
| `signal_detection` | Historique des détections répétées (règle RG-05 : 3 détections → statut CONFIRMED) |
| `alert` | Alertes avec `type` (PREMIER_CONTACT/CANDIDATE/CHAOS_TEST) et cycle de vie OPEN → ACKNOWLEDGED → CLOSED |
| `job_run` | Suivi des exécutions batch (complète les tables natives Spring Batch) |
| `ist_weights` | Poids versionnés de la formule `I_st` ; une seule version `active=TRUE` à la fois |
| `catalogue_object` | Objets connus (PostGIS) avec indexation spatiale GIST pour cone-search |

**Points d'attention :**
- `i_st` est un `FLOAT` entre 0 et 1. Seuil alerte : > 0.95 (RG-01). Seuil Hall of Fame : > 0.8 (RG-07).
- `detection_count` dans `signal` est incrémenté à chaque nouvelle détection ; passage à `CONFIRMED` à 3 (RG-05).
- La `spatial index` sur `signal` utilise une colonne géométrique générée depuis `ra`/`dec`.

---

## 6. Règles de Gestion — Implémentation Obligatoire

| ID | Déclencheur | Action attendue |
|---|---|---|
| **RG-01** | `I_st > 0.95` post-classification | Alerte PREMIER_CONTACT → Email SMTP TLS + Slack webhook + Push Service Workers |
| **RG-02** | Signal classé "Technologique" | Activation du module d'analyse de sentiment |
| **RG-03** | Chaos Monkey activé (sandbox) | Injection panne simulée (RFI / worker crash) — environnement sandbox uniquement |
| **RG-04** | Tout endpoint API | Vérification JWT Keycloak obligatoire ; retourner 401 sinon |
| **RG-05** | 3 détections répétées même profil | Passage statut candidat → `CONFIRMED` |
| **RG-06** | Séparation angulaire < seuil par type | Étiquetage `Explained: <type>` avec provenance complète |
| **RG-07** | `I_st > 0.8` + statut CONFIRMED | Publication automatique Hall of Fame + notification communautaire |
| **RG-08** | Slew avec soleil < 15° | Blocage immédiat + proposition fenêtre d'observation alternative |
| **RG-09** | Erreur plate-solve > 30″ | Re-centrage automatique (max 3 tentatives) |
| **RG-10** | Job batch en échec > 3 retries | Notification Commander + statut `FAILED` persisté dans `JobRepository` |

---

## 7. APIs Externes — Intégrations

| Service | Usage | Pattern de résilience |
|---|---|---|
| **Breakthrough Listen** (.h5 / I-Q) | Import batch de données radio réelles | Retry x3 |
| **MAST** (SSAP) | Spectral Context — spectres Hubble/JWST | Circuit Breaker + cache Redis 24h |
| **HEASARC** (HAPI REST) | Spectral Context — NuSTAR/Chandra | Circuit Breaker + cache Redis 24h |
| **Gaia Archive** (TAP ADQL) | Spectral Context — données astrométriques | Circuit Breaker + cache Redis 24h |
| **SDSS CasJobs** | Spectral Context — spectres optiques | Circuit Breaker + cache Redis 24h |
| **SIMBAD / VizieR** | Cross-match objets connus | Circuit Breaker + catalogue local PostGIS (refresh J-1) |
| **ATNF Pulsar Catalog** | Cross-match pulsars (période ± 5 ms) | Circuit Breaker + catalogue local PostGIS |
| **FRBcat** | Cross-match FRBs (DM ± 10 pc/cm³) | Circuit Breaker + catalogue local PostGIS |
| **Space-Track TLE** | Cross-match satellites / RFI | Scheduled refresh 6h + TLE précédent en cache |
| **IGWN API** | Corrélation ondes gravitationnelles → BlackHoleCandidate | Retry x3, timeout 5s ; sans corrélation le label n'est pas modifié |
| **ASCOM / INDI** | Commande mount télescope (Slew) | Timeout 10s + safety checks + notification si annulé |
| **Astrometry.net** | Plate-solve post-slew | Timeout 30s ; fallback position estimée si indisponible |

---

## 8. Sécurité — Règles Absolues

- **Aucun secret** dans le code ou les fichiers de configuration commités. Tous les secrets transitent par HashiCorp Vault (Vault Agent Injector K8s).
- Les rôles Keycloak suivent strictement cette hiérarchie : `ROLE_VISITOR` < `ROLE_EXPLORER` < `ROLE_ANALYST` < `ROLE_COMMANDER` < `ROLE_ADMIN`.
- Les endpoints `/v1/jobs/**` sont soumis au rate-limiting Spring Cloud Gateway (5 req/s, burst 10).
- Le **Chaos Mode** (RG-03) est exclusivement réservé à l'environnement sandbox ; toute injection de panne en production est interdite.
- La géolocalisation respecte le RGPD : opt-in explicite, purge automatique 30 jours, audit trail complet, export et suppression sur demande.
- La clé privée de signature des rapports PDF est stockée dans Vault ; ne jamais l'exposer dans les logs ou les réponses API.
- Toute action par rôle est journalisée dans un **audit trail** exportable (US-39 / US-40).

---

## 9. Observabilité — Métriques à Instrumenter

Toute nouvelle fonctionnalité doit exposer les métriques Micrometer associées. Exemples de métriques existantes à ne pas casser :

```
starwave.batch.job.duration        (Histogram) — durée job complet
starwave.batch.step.errors         (Counter)   — échecs par step
starwave.signal.candidates.total   (Counter)   — candidats créés
starwave.signal.ist.histogram      (Histogram) — distribution I_st
starwave.ai.inference.latency      (Histogram) — latence ONNX (ms)
starwave.crossmatch.duration       (Histogram) — durée cross-match
starwave.alerts.fired              (Counter)   — alertes Premier Contact
starwave.websocket.connections     (Gauge)     — clients WS connectés
starwave.gpu.utilization           (Gauge)     — utilisation GPU (DCGM)
```

Les dashboards Grafana prédéfinis sont : **Operations**, **Science**, **Alertes**. Ne pas modifier leur structure sans validation de l'équipe Lead Architect.

---

## 10. Contraintes Non-Fonctionnelles — Cibles à Respecter

| Contrainte | Valeur cible |
|---|---|
| Traitement 1 To données radio | < 60 minutes |
| Latence inférence ONNX | < 2 ms par signal |
| Faux positifs IA (Pulsars) | < 5 % |
| Disponibilité système monitoring | 99,9 % |
| Délai alerte Premier Contact | < 5 secondes post-INSERT |
| Débit Waterfall WebGPU | 60 fps |
| Latence Spectral Context | < 3 secondes (requêtes parallèles) |
| Confirmation slew télescope | < 30 secondes |
| Reprise sur incident batch | < 2 minutes depuis `stepId` |
| Taille modèle ONNX | < 500 Mo (prévenir pression heap JVM) |

---

## 11. Tests — Stratégie Attendue

- **Unit tests** : couvrir le `RulesEngine` (RG-01 à RG-10), la formule `I_st`, les seuils de cross-match.
- **Integration tests** : Spring Batch avec `JobLauncherTestUtils`, MariaDB embarquée (Testcontainers).
- **GPU Worker** : tests FastAPI avec des spectrogrammes synthétiques Setigen.
- **E2E** : Playwright pour les flux critiques (connexion, Waterfall, Slew to target, génération rapport PDF).
- **Load tests** : k6 pour valider les SLAs batch (1 To / 60 min) et la latence WebSocket.
- **Chaos tests** : scénarios Chaos Monkey (RG-03) en sandbox uniquement, validés par un Commander.
- Les **safety checks** slew (RG-08) doivent être testés avec des cas limites : soleil à 14°, 15°, 16° ; élévation au minimum configuré.

---

## 12. Patterns & Anti-Patterns

### ✅ À faire

- Toujours utiliser `@StepScope` pour les beans Spring Batch qui dépendent de paramètres de partition.
- Envelopper les appels WebSocket STOMP dans un service Angular avec reconnexion automatique (SockJS fallback + retry).
- Lors d'un nouveau type d'objet catalogue : ajouter l'entrée dans `catalogue_object.object_type`, créer la règle de seuil dans `RulesEngine`, et documenter dans `STARWAVE_fonctionnel.md`.
- Versionner les poids `I_st` à chaque modification (nouvelle entrée `ist_weights`, `active=TRUE`, ancienne `active=FALSE`).
- Implémenter le **fallback WebGL 2** avant tout usage de WebGPU en production.

### ❌ À éviter

- Coder en dur des URLs d'APIs externes ou des seuils `I_st` — tout passe par la configuration ou la base de données.
- Appeler directement les APIs externes depuis le frontend Angular — toujours passer par le backend (Spectral Context Service).
- Lancer un slew sans exécuter les safety checks (soleil, élévation, vent) définis dans `TelecopeService`.
- Déployer le Chaos Mode (RG-03) en dehors de l'environnement sandbox.
- Créer un modèle ONNX > 500 Mo sans validation de l'équipe MLOps.
- Utiliser des logs non structurés (plain text) dans les composants Java ou Python.
- Modifier les dashboards Grafana prédéfinis (Operations / Science / Alertes) sans validation.

---

## 13. Glossaire

| Terme | Définition |
|---|---|
| `I_st` | Indice de Signature Technologique (0–1). Agrège SNR, bande étroite, régularité Doppler, compressibilité LZMA2, répétition et pénalité cross-match. |
| **Alpha** | Classe IA : signal de faible intérêt (bruit probable) |
| **Beta** | Classe IA : signal ambigu, nécessite analyse humaine |
| **Omega** | Classe IA : signal à haute priorité technologique |
| **Premier Contact** | Alerte déclenchée quand `I_st > 0.95` (RG-01) |
| **War Room** | Mode d'affichage IHM sombre avec carte du ciel interactive, dédié à la supervision de crise |
| **Spectral Context** | Panneau affichant le spectre multi-longueur d'onde d'une source (RA/Dec) en agrégeant MAST, HEASARC, Gaia, SDSS |
| **Plate-solve** | Identification de la position réelle du télescope par reconnaissance d'étoiles (Astrometry.net) |
| **Slew** | Déplacement motorisé du télescope vers des coordonnées RA/Dec |
| **HEALPix** | Pixelisation sphérique utilisée pour l'indexation spatiale rapide des coordonnées célestes |
| **DM** | Dispersion Measure — paramètre clé pour identifier les FRBs (pc/cm³) |
| **QPO** | Quasi-Periodic Oscillations — signature spectrale des trous noirs et jets relativistes |
| **RFI** | Radio Frequency Interference — interférences terrestres à filtrer |
| **FITS** | Flexible Image Transport System — format standard en astronomie pour les données spectrales |
| **TLE** | Two-Line Element — données orbitales des satellites pour le cross-match RFI |

---

*Instructions maintenues par le Lead Solution Architect — S.T.A.R.W.A.V.E. v1.1*  
*Mettre à jour ce fichier à chaque ADR validé ou évolution majeure de la stack.*
