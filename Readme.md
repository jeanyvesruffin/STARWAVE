# 🌌 S.T.A.R.W.A.V.E

## CI Status

| Service     | Status |
|-------------|--------|
| Backend     | [![CI – Backend](https://github.com/jeanyvesruffin/STARWAVE/actions/workflows/ci-backend.yml/badge.svg)](https://github.com/jeanyvesruffin/STARWAVE/actions/workflows/ci-backend.yml) |
| Frontend    | [![CI – Frontend](https://github.com/jeanyvesruffin/STARWAVE/actions/workflows/ci-frontend.yml/badge.svg)](https://github.com/jeanyvesruffin/STARWAVE/actions/workflows/ci-frontend.yml) |
| Workers     | [![CI – Workers](https://github.com/jeanyvesruffin/STARWAVE/actions/workflows/ci-workers.yml/badge.svg)](https://github.com/jeanyvesruffin/STARWAVE/actions/workflows/ci-workers.yml) |
| Crossmatch  | [![CI – Crossmatch](https://github.com/jeanyvesruffin/STARWAVE/actions/workflows/ci-crossmatch.yml/badge.svg)](https://github.com/jeanyvesruffin/STARWAVE/actions/workflows/ci-crossmatch.yml) |
| Spectral    | [![CI – Spectral](https://github.com/jeanyvesruffin/STARWAVE/actions/workflows/ci-spectral.yml/badge.svg)](https://github.com/jeanyvesruffin/STARWAVE/actions/workflows/ci-spectral.yml) |

## Table des matières

- [1. Vision](#1-vision)
- [2. Architecture Fonctionnelle & Flux de Données](#2-architecture-fonctionnelle--flux-de-données)
- [3. Spécifications des Modules](#3-spécifications-des-modules)
  - [3.1 Mission Control — Pilotage Batch](#31-mission-control--pilotage-batch)
  - [3.2 Deep Space Explorer — IHM & War Room](#32-deep-space-explorer--ihm--war-room)
  - [3.3 Pointage Télescopes & Géolocalisation](#33-pointage-télescopes--géolocalisation)
  - [3.4 Catalogue d'Objets & Phénomènes Expliqués](#34-catalogue-dobjets--phénomènes-expliqués)
  - [3.5 Module Collaboratif — SETI @ Community](#35-module-collaboratif--seti--community)
  - [3.6 APIs Spectroscopiques et données radioastronomiques Externes](#36-apis-spectroscopiques-et-données-radioastronomiques-externes)
- [4. Gestion des Rôles — Matrice de Sécurité](#4-gestion-des-rôles--matrice-de-sécurité)
- [5. Règles Métier Critiques](#5-règles-métier-critiques)
- [6. Stack Technologique](#6-stack-technologique)
- [7. Indicateurs de Succès (KPI)](#7-indicateurs-de-succès-kpi)
- [8. Déploiement & IaC](#8-déploiement--iac)
  - [8.1 Docker / docker-compose (Dev)](#81-docker--docker-compose-dev)
  - [8.2 Kubernetes / K3s (Production)](#82-kubernetes--k3s-production)
  - [8.3 Optimisations IA & Signal](#83-optimisations-ia--signal)
  - [8.4 IaC](#84-iac)
  - [8.5 Sécurité](#85-sécurité)
- [9. User Stories — Catalogue Complet (US-01 → US-40)](#9-user-stories--catalogue-complet-us-01--us-40)
  - [9.1 Pipeline de traitement (US-01 → US-09)](#91-pipeline-de-traitement-us-01--us-09)
  - [9.2 IHM & Visualisation avancée (US-10 → US-22)](#92-ihm--visualisation-avancée-us-10--us-22)
  - [9.3 Pointage & Géolocalisation (US-23 → US-27)](#93-pointage--géolocalisation-us-23--us-27)
  - [9.4 Catalogue, Provenance & Trous Noirs (US-28 → US-32)](#94-catalogue-provenance--trous-noirs-us-28--us-32)
  - [9.5 Spectral Context — APIs radioastronomiques (US-33 → US-36)](#95-spectral-context--apis-radioastronomiques-us-33--us-36)
  - [9.6 Collaboration & Community (US-37 → US-38)](#96-collaboration--community-us-37--us-38)
  - [9.7 Sécurité, Observabilité & Résilience (US-39 → US-40)](#97-sécurité-observabilité--résilience-us-39--us-40)
- [Démarrage/arrêt rapide du projet](#démarragejarrêt-rapide-du-projet)
  - [Prérequis](#prérequis)
  - [1. Cloner et configurer](#1-cloner-et-configurer)
  - [2. Premier démarrage](#2-premier-démarrage)
  - [3. Arrêter l'environnement](#3-arrêter-lenvironnement)
  - [4. Vérifier que tout est healthy](#4-vérifier-que-tout-est-healthy)
  - [5. Accéder aux services](#5-accéder-aux-services)
  - [6. Commandes du quotidien](#6-commandes-du-quotidien)
  - [7. Structure du projet](#7-structure-du-projet)
  - [8. Dépannage rapide](#8-dépannage-rapide)
  - [9. Hot-reload (développement)](#9-hot-reload-développement)

---

**SETI Tracking & Analysis of Radio Waves for ESA**

Documentations :

[STARWAVE_DAT](Documentations/STARWAVE_DAT.md)

[STARWAVE_fonctionnel](Documentations/STARWAVE_fonctionnel.md)

[STARWAVE_technique](Documentations/STARWAVE_technique.md)

---

## 1. Vision

**S.T.A.R.W.A.V.E.** est une plateforme de *Mission Control* conçue pour les astrologue les cosmologue. Son but est d'automatiser l'analyse des signaux radio profonds afin de détecter des preuves de technologies non-humaines.

---

## 2. Architecture Fonctionnelle & Flux de Données

| # | Phase | Description |
|---|---|---|
| 1 | **Ingestion** | Collecte des données radio brutes (Télescopes ESA/SETI) via Apache Kafka |
| 2 | **Traitement (Spring Batch)** | Nettoyage, filtrage et transformation de Fourier (FFT) via moteur Python/GPU |
| 3 | **Analyse IA** | Calcul de l'Indice de Signature Technologique ($I_{st}$) et classification Alpha/Beta/Omega |
| 4 | **Restitution (Angular)** | Affichage dynamique Waterfall, carte du ciel et gestion des alertes |

---

## 3. Spécifications des Modules

### 3.1 Mission Control — Pilotage Batch

Centre de commande et d'orchestration de l'application.

- **Contrôle de flux :** démarrer, mettre en pause ou arrêter les jobs de traitement.
- **Reprise sur incident :** relancer un job exactement là où il s'est arrêté via le `JobOperator`.
- **Visualisation temps réel :** dashboard des secteurs célestes en cours d'analyse par les workers.
- **Partitioning & Scalabilité :** Spring Batch Partitioning (Master/Worker) pour distribuer les paquets de fréquences.
- **HATEOAS & Job Control API :** endpoints REST pour piloter les actions sur les signaux (`reanalyze`, `archive`, `view-on-sky-map`).
- **Gateway & Protection :** Spring Cloud Gateway pour routage, authentification centralisée et rate-limiting.

---

### 3.2 Deep Space Explorer — IHM & War Room

Interface Angular interactive basée sur WebSockets et WebGPU.

- **Spectrogramme Waterfall :** rendu GPU-accelerated, frames poussées en temps réel via WebSockets (STOMP).
- **Analyse de signal (Radar Chart) :** modal détaillant bande passante, dérive Doppler et régularité.
- **Mode War Room :** thème sombre + carte du ciel interactive (Leaflet + Aladin Lite v3) avec calques (Satellites, Candidates, Noise).
- **Logs interactifs :** flux stylisé Matrix/Terminal affichant l'analyse pas-à-pas.
- **Paradoxe de Fermi Score :** ratio signaux candidats / total analysés pour mesurer la probabilité statistique.
- **Replay & Time Travel :** lecture pas-à-pas des frames spectrogramme avec bookmarks et annotations.
- **Filtrage avancé :** filtres composables (fréquence, $I_{st}$, période, provenance) avec vues sauvegardables.
- **Workflows d'alerte :** acknowledgement, règles d'escalade (email/Slack/Push), timeline d'investigation par signal.
- **Collaboration temps réel :** annotations partagées, session live, votes et commentaires sur les candidates.
- **Explicabilité IA :** panneau "Pourquoi ce score ?" avec features clés et leurs poids.
- **Indicateurs de confiance visuels :** score $I_{st}$ avec intervalle de confiance et gradient coloré animé.
- **Fiches enrichies :** résultats cross-match + liens vers catalogues (ATNF, FRBCAT, SIMBAD) et export PDF/ZIP.
- **Notifications Push :** Service Workers + permission-based push pour les Alertes Premier Contact.
- **Mode Démo & Sandbox :** jeux de données d'exemple et scénarios préconfigurés (ex : "Premier Contact").
- **Accessibilité :** thèmes haute-contraste, navigation clavier, labels ARIA, compatibilité lecteurs d'écran.
- **Personnalisation UI :** layouts sauvegardables (War Room, Analyst, Mobile) et widgets repositionnables.
- **Simulations & Chaos Mode :** injections RFI et pannes simulées pour valider les procédures d'escalade.
- **Feedback utilisateur :** bouton "Noter cette détection" pour corriger les labels et alimenter le réentraînement.
- **Performances & offline :** cache local des frames récents, fallback UI en cas de déconnexion.
- **Spectral Context (localisation d'émission) :** au clic sur un signal (Waterfall ou carte céleste), panneau latéral affichant le spectre spectroscopique associé aux coordonnées RA/Dec d'émission — courbe d'intensité par longueur d'onde, identification automatique des raies connues, lien vers la fiche catalogue et export FITS.
- **Sécurité & audit UX :** journal exportable des actions par rôle (Explorer / Analyst / Commander).

---

### 3.3 Pointage Télescopes & Géolocalisation

**UX / UI**

- Bouton `Use my location` (permission navigateur) + picker map / saisie lat-lon / observatoires préconfigurés.
- Filtres : `Only visible from my location`, `Max distance (km)`, `Min elevation (°)`, `Time window`.
- Indicateurs carte : badge vert (visible maintenant), orange (bientôt), gris (non visible).
- Fiche signal : champ "Visible from you" + ETA prochaine fenêtre + bouton `Point telescope`.
- Mobile : GPS avec permission fine et notifications pour les fenêtres d'observation.

**Backend / Calculs**

- Endpoint : `GET /signals?lat={}&lon={}&radius_km={}&visible=true&min_elev={}&start={}&end={}`
- Conversion RA/Dec → Alt/Az (lat/lon + UTC) avec correction atmosphérique optionnelle.
- Indexation HEALPix pour requêtes rapides et cache des fenêtres de visibilité.

**Intégration Télescope**

- Bouton `Slew to target` envoyant RA/Dec/Alt-Az au driver (ASCOM / INDI / REST WebSocket).
- Workflow : `Slew → Plate-solve → Center` pour valider et corriger la position.
- Télémétrie temps réel (az, alt, pier side, erreur en arcsec) et notification à l'acquisition.
- Safety checks : vérification soleil / élévation / vent / obstructions avant autorisation de slew.

**Privacy & Sécurité**

- Opt-in géolocalisation : `session-only`, `save in profile`, `anonymous/hashed`.
- Conformité GDPR sur conservation, export et suppression des positions.
- TLS + token-based auth pour emplacements sauvegardés et télécommande.

---

### 3.4 Catalogue d'Objets & Phénomènes Expliqués

**Phénomènes couverts**

| Type | Signature | Données affichées |
|---|---|---|
| Pulsars | Émissions périodiques, polarisations | RA/Dec, période, catalogue ATNF, distance |
| Magnétars | Transitoires énergétiques, haute polarisation | RA/Dec, historique d'activité, association SGR/AXP |
| FRB | Transitoires ms avec dispersion (DM) | RA/Dec, DM, largeur temporelle, FRBCAT |
| Quasars / AGN | Émissions continues ou variables | RA/Dec, redshift, SIMBAD/VizieR |
| Sources solaires | Éruptions, ionosphère | Marquage phénomène terrestre/solaire |
| RFI & Satellites | Interférences connues | TLE match / signature RFI |

**Fonctionnalités opérationnelles**

- **Cross-match automatique :** croisement avec ATNF, FRBcat, SIMBAD, VizieR, TLE feeds et calcul de distance angulaire minimale.
- **Labeling & Provenance :** étiquetage `Explained: <type>` avec stockage catalogue source, identifiant, séparation angulaire.
- **Seuils de confiance :** règles par type (séparation angulaire, DM, période concordante) → certaine / probable / possible.
- **Visualisation :** calque interactif sur carte et Waterfall ; fiche objet au clic (catalog id, RA/Dec, références).
- **Provenance temporelle :** heure d'arrivée, fenêtre temporelle, version d'index catalogue utilisée.
- **Audit & Revue :** journalisation de toutes les correspondances et révision manuelle possible.

**Intégration Batch & IA**

Le pipeline Batch appelle le service de cross-match après détection initiale. Les signaux "Explained" passent dans une voie allégée ou sont archivés. Les attributs de provenance (catalog match score, DM concordant, période) servent de features pour le calcul de $I_{st}$.

**Exemple d'usage**

> Un pic transitoire est détecté → DM et position calculés → cross-match retourne une correspondance pulsar (séparation 0.02°) → étiquetage `Explained: Pulsar (ATNF Jxxxx)`.
> Un FRB montre un DM incompatible → étiquetage `Unexplained` → priorisation pour inspection humaine.

**APIs externes :** SkyView / Astrometry.net, NASA/ESA pour enrichissement contextuel.

**Détection des Trous Noirs — Signatures Multi-domaines**

Indicateurs et règles métier pour identifier des signatures compatibles avec des trous noirs et les distinguer des technosignatures.

- **Ondes gravitationnelles — le "Chirp" :** fréquence croissant rapidement en amplitude lors de la fusion de deux trous noirs. Corrélation radio ↔ ondes gravitationnelles via IGWN API + `astropy`. Action : $I_{st} \approx 0$ + archivage scientifique si corrélation GW externe confirmée.
- **Spectre radio et jets :** émission synchrotron large-bande + oscillations quasi-périodiques (QPO) du disque d'accrétion. Extraction slope, flux, QPO peaks → confiance astrophysique élevée, $I_{st}$ bas.
- **Raies d'émission X (Doppler extrême) :** raie du fer (≈ 6.4 keV) déformée par effets relativistes près de l'horizon. Si raie X déformée + profil synchrotron → classer `Explained: BlackHoleCandidate`, $I_{st} \approx 0$.

> **Règle discriminante :** un trou noir produit un signal large-bande non structuré (compressibilité élevée, absence de motif binaire), à l'inverse d'une technosignature (bande étroite, régularité mathématique).

---

### 3.5 Module Collaboratif — SETI @ Community

- **Hall of Fame :** publication automatique des signaux avec $I_{st} > 0.8$.
- **Système de Naming :** vote communautaire pour nommer les sources d'intérêt.
- **Rapport d'Expertise :** génération de PDF certifiés pour l'ESA via ressources HATEOAS.

---

### 3.6 APIs Spectroscopiques et données radioastronomiques Externes

Cette section recense toutes les sources de données externes exploitées par S.T.A.R.W.A.V.E., couvrant à la fois la spectroscopie multi-longueurs d'onde et les données radioastronomiques brutes.

**Expérience utilisateur — Spectre lié à la localisation d'émission**

Lorsqu'un utilisateur clique sur un signal dans le Waterfall ou sur la carte céleste, l'IHM permet de récupérer et d'afficher le spectre spectroscopique associé à la localisation d'émission de l'onde radio (coordonnées RA/Dec). Cette fonctionnalité repose sur une requête croisée aux APIs ci-dessous (MAST, HEASARC, SDSS, Gaia) filtrée sur la position angulaire du signal. Le spectre est rendu dans un panneau latéral dédié ("Spectral Context") avec : courbe d'intensité par longueur d'onde, identification automatique des raies connues, lien vers la fiche catalogue de la source correspondante et export FITS.

| Type Ressource | Source | Format | Module S.T.A.R.W.A.V.E. |
|---|---|---|---|
| **Radio** | Breakthrough Listen / Setigen | `.h5` / I/Q | Ingestion & IA |
| **Objets** | SIMBAD / ATNF / Space-Track | JSON / XML | Catalogue & Provenance |
| **Visuel** | Aladin Lite / SkyView| JavaScript / FITS | Deep Space Explorer |
| **Pointage** | Astrometry.net | REST | Télescope Integration |
| **Optique / UV / IR** | MAST (Hubble, JWST) | FITS / `astroquery.mast` / SSAP | Spectral Context (UX) |
| **Rayons X & Gamma** | HEASARC (NuSTAR, Chandra) | FITS / `PyHEASARC` / HAPI | Spectral Context (UX) |
| **Étoiles (spectres BP/RP)** | Gaia ESA Archive | TAP/ADQL / `GaiaXPy` | Spectral Context (UX) |
| **Galaxies / Quasars** | SDSS (4M+ spectres) | `astroquery.sdss` / CasJobs SQL | Spectral Context (UX) |

---

## 4. Gestion des Rôles — Matrice de Sécurité

| Fonctionnalité | Explorer | Analyst | Commander |
|:---|:---:|:---:|:---:|
| Lecture Waterfall & Map | ✅ | ✅ | ✅ |
| Vote & Naming | ✅ | ✅ | ✅ |
| Annotation & Rapport PDF | ❌ | ✅ | ✅ |
| Contrôle du Batch (Start/Stop) | ❌ | ❌ | ✅ |
| Reset & Configuration IA | ❌ | ❌ | ✅ |

---

## 5. Règles Métier Critiques

| ID | Règle |
|---|---|
| **RG-01** | $I_{st} > 0.95$ → déclenchement **"Alerte Premier Contact"** (Push + Email prioritaire) |
| **RG-02** | L'analyse de sentiment n'est activée que si le signal est classé "Technologique" |
| **RG-03** | Le **Chaos Monkey** provoque des pannes simulées pour tester la réactivité des Commanders |
| **RG-04** | L'accès aux données sensibles nécessite un jeton JWT valide émis par **Keycloak** |

---

## 6. Stack Technologique

| Module | Technologie | Rôle |
|---|---|---|
| Ingestion | Apache Kafka | Streaming des signaux bruts |
| Traitement | Spring Batch 5.x + Java 25 (Virtual Threads) | Parallélisation Master/Worker |
| IA / Inférence | ONNX Runtime (Spring AI) + PyTorch CNN-Transformer | Classification & calcul $I_{st}$ |
| Calcul GPU | FastAPI + CuPy | FFT, Deep-Drift sur GPU NVIDIA |
| IHM | Angular 21 + WebGPU | Waterfall haute performance |
| Carte du ciel | Leaflet + Aladin Lite v3 | Overlays astronomiques réels |
| Auth & Gateway | Spring Cloud Gateway + Keycloak | Rate-limiting, sécurisation |
| Catalogues | Astroquery / PostGIS + MOC | Cross-matching SIMBAD, ATNF, TLE |
| Observabilité | Micrometer → Prometheus & Grafana | Monitoring & dashboards |

---

## 7. Indicateurs de Succès (KPI)

1. **Temps de traitement :** analyser 1 To de données radio en moins de 60 minutes.
2. **Précision IA :** moins de 5 % de faux positifs sur la classification des Pulsars.
3. **Disponibilité :** 99,9 % d'uptime pour le système de monitoring.

---

## 8. Déploiement & IaC

### 8.1 Docker / docker-compose (Dev)

Services : Spring Boot, Angular, MariaDB, Keycloak, Prometheus, Grafana, worker FastAPI (GPU).  
GPU : NVIDIA Container Toolkit + `--gpus=all`. Volumes NVMe hostPath pour les To de données brutes.

### 8.2 Kubernetes / K3s (Production)

- **K3s** pour edge / stations légères ; Kubernetes standard pour la production centrale.
- Kafka en StatefulSet avec PVC NVMe ; workers FastAPI GPU en DaemonSet avec `nodeAffinity`.
- Spring Batch Master en Deployment, Workers en Jobs/CronJobs selon le besoin.
- Helm charts + Kustomize overlays (dev / staging / prod) ; GitOps via ArgoCD / Flux.

### 8.3 Optimisations IA & Signal

- Device plugin NVIDIA en Kubernetes (`limits.nvidia.com/gpu: 1`).
- SR-IOV ou CNI performant pour réduire la latence d'ingestion.
- Colocation CPU/GPU pour les pods FastAPI + CuPy.

### 8.4 IaC

```bash
terraform apply -var="site=orion-station-01" \
  && helm upgrade --install starwave ./charts/starwave -f values-orion.yaml
```

### 8.5 Sécurité

- Secrets : Kubernetes Secrets ou HashiCorp Vault (clés NASA/ESA, tokens Keycloak, credentials DB).
- RBAC Keycloak + Kubernetes RBAC pour les actions sensibles (relance batch, seuils IA).

---

## 9. User Stories — Catalogue Complet (US-01 → US-40)

### 9.1 Pipeline de traitement (US-01 → US-09)

| ID | En tant que | Je veux | Afin de |
|---|---|---|---|
| US-01 | Système | Recevoir et stocker les paquets bruts des télescopes | Alimenter le pipeline |
| US-02 | Pipeline | Nettoyer, normaliser et marquer la qualité des trames | Filtrer la RFI et préparer l'IA |
| US-03 | Traitement Batch | Identifier pics, transitoires et anomalies sur spectrogramme | Créer des candidats pour analyse |
| US-04 | IA | Agréger features (SNR, Doppler, compressibilité) et calculer $I_{st}$ | Prioriser les candidats |
| US-05 | Service de provenance | Croiser un candidat avec les catalogues (ATNF, FRBcat, SIMBAD) | Annoter "Explained" ou non |
| US-06 | Commander | Être notifié et lancer workflows (email, Slack, Push) | Organiser l'investigation |
| US-07 | Explorer | Voir les frames en temps réel via WebSockets | Surveiller le spectre |
| US-08 | Explorer | Exécuter `reanalyze`, `archive`, `view-on-sky-map` depuis l'IHM | Agir sans connaître les endpoints |
| US-09 | Admin / Commander | Démarrer / stopper / reprendre des jobs via API sécurisée | Piloter les traitements |

### 9.2 IHM & Visualisation avancée (US-10 → US-22)

| ID | En tant que | Je veux | Afin de |
|---|---|---|---|
| US-10 | Visiteur / Analyst | Voir un `Fermi Paradox Score` sur le dashboard | Mesurer la probabilité de technosignatures |
| US-11 | Analyst | Annotation automatique Alpha / Beta / Omega par l'IA | Prioriser le traitement humain |
| US-12 | Visiteur | Message cryptique si $I_{st} > 0.95$ (opt-in) | Expérience ludique + repérage cas extrêmes |
| US-13 | Explorer | Frames spectrogramme en WebSocket | Waterfall en quasi-temps réel |
| US-14 | Commander | Thème sombre + carte du ciel interactive | Superviser une session de crise |
| US-15 | Analyst | Flux de logs stylisé montrant l'analyse pas-à-pas | Tracer les décisions IA |
| US-16 | Admin Infra | Partitionner le job pour workers en parallèle | Démontrer l'échelle ESA-like |
| US-17 | Explorer | Liens `reanalyze`, `archive`, `view-on-sky-map` sur `GET /signals/{id}` | Actions depuis l'IHM sans connaître les endpoints |
| US-18 | Admin | Protéger les endpoints critiques via Spring Cloud Gateway | Éviter les relances massives |
| US-19 | Explorer | Récupérer une image réelle de la zone depuis un signal | Confronter la détection aux données réelles |
| US-20 | Commander | Email prioritaire + Slack/Discord + Push pour alertes critiques | Alerter l'équipe via plusieurs canaux |
| US-21 | Data Engineer | Schéma de table standard (freq, power, source_probable, indice_techno, action) | Alimenter l'IA et faciliter les exports |
| US-22 | Système | Ne valider un candidat qu'après 3 détections répétées au même profil | Réduire les faux positifs |

### 9.3 Pointage & Géolocalisation (US-23 → US-27)

| ID | En tant que | Je veux | Afin de |
|---|---|---|---|
| US-23 | Explorer | Activer ma géolocalisation GPS (opt-in) pour filtrer les signaux visibles depuis ma position | Observer uniquement les sources accessibles depuis mon site |
| US-24 | Explorer | Voir un badge de visibilité (vert / orange / gris) sur chaque signal de la carte | Identifier d'un coup d'œil les cibles observables maintenant |
| US-25 | Explorer | Cliquer sur `Slew to target` pour envoyer les coordonnées RA/Dec à mon mount ASCOM/INDI | Pointer automatiquement mon télescope sur un candidat sans saisie manuelle |
| US-26 | Explorer | Lancer un workflow `Plate-solve → Center` après le slew | Valider et corriger la mise en station avec précision arcsec |
| US-27 | Admin | Configurer les safety checks (soleil, élévation min, vent) avant toute autorisation de slew | Protéger le matériel et éviter les pointages dangereux |

### 9.4 Catalogue, Provenance & Trous Noirs (US-28 → US-32)

| ID | En tant que | Je veux | Afin de |
|---|---|---|---|
| US-28 | Analyst | Consulter la fiche catalogue d'un objet connu (Pulsar, FRB, AGN) au clic sur la carte | Comprendre immédiatement la nature probable du signal |
| US-29 | Système | Étiqueter automatiquement un événement `Explained: <type>` lorsque la séparation angulaire est sous le seuil de confiance | Réduire la charge de traitement sur les signaux d'origine connue |
| US-30 | Analyst | Réviser manuellement une étiquette de provenance erronée et journaliser la correction | Garantir la qualité du dataset d'entraînement de l'IA |
| US-31 | Système | Corréler un signal radio avec une alerte IGWN (ondes gravitationnelles) et le classer `Explained: BlackHoleCandidate` | Distinguer les signatures de trous noirs des technosignatures |
| US-32 | Analyst | Visualiser les QPO et le profil synchrotron d'un signal sur un graphique dédié | Confirmer ou infirmer une origine astrophysique de type trou noir / jet relativiste |

### 9.5 Spectral Context — APIs radioastronomiques (US-33 → US-36)

| ID | En tant que | Je veux | Afin de |
|---|---|---|---|
| US-33 | Explorer | Au clic sur un signal, voir le spectre spectroscopique multi-longueur d'onde associé à ses coordonnées RA/Dec | Contextualiser radialement l'émission de l'onde dans son environnement astrophysique |
| US-34 | Analyst | Charger des données brutes radio Breakthrough Listen (`.h5` / I/Q) et les injecter dans le pipeline IA | Entraîner et valider les modèles sur un jeu de données SETI réel |
| US-35 | Explorer | Identifier automatiquement les raies spectrales connues (Hα, OH, raie HI 21 cm) dans le panneau Spectral Context | Repérer les signatures moléculaires associées à la source émettrice |
| US-36 | Analyst | Exporter le spectre affiché au format FITS depuis le panneau Spectral Context | Réutiliser les données dans des outils externes (DS9, Aladin Desktop) |

### 9.6 Collaboration & Community (US-37 → US-38)

| ID | En tant que | Je veux | Afin de |
|---|---|---|---|
| US-37 | Explorer | Voter pour nommer une source candidate publiée dans le Hall of Fame | Contribuer à la reconnaissance collective d'une découverte potentielle |
| US-38 | Analyst | Générer un rapport PDF certifié d'un signal via l'action HATEOAS `generate-report` | Soumettre une preuve formelle à l'ESA ou à la communauté scientifique |

### 9.7 Sécurité, Observabilité & Résilience (US-39 → US-40)

| ID | En tant que | Je veux | Afin de |
|---|---|---|---|
| US-39 | Admin | Consulter les dashboards Prometheus/Grafana (latence batch, taux d'erreur IA, jobs en cours) depuis l'IHM Mission Control | Surveiller la santé du système en temps réel sans accès direct aux logs |
| US-40 | Commander | Déclencher manuellement un scénario Chaos Monkey (injection de pannes RFI) en environnement sandbox | Tester les procédures d'escalade et la robustesse des workers avant une campagne d'observation réelle |

---

# Démarrage/arrêt rapide du projet

## Prérequis

| Outil | Version minimale |
|---|---|
| Docker | 24.x |
| Docker Compose | v2.x (`docker compose` ou `docker-compose`) |
| Git | 2.x |

---

## 1. Cloner et configurer

```bash
git clone https://github.com/jeanyvesruffin/STARWAVE.git
cd starwave

# Créer le fichier de variables d'environnement
cp .env.example .env
```

> ⚠️ **Ne jamais committer le fichier `.env`** — il contient les mots de passe locaux.

Les valeurs par défaut du `.env` fonctionnent telles quelles en local. Tu peux les modifier si un port est déjà occupé sur ta machine.

---

## 2. Premier démarrage

```bash
# Build des images locales + démarrage de tous les services
docker-compose up
```

**⚠️EXECUTER LE SCRIPT `check.sh` POUR VERIFIER QUE TOUS FONCTIONNE⚠️**

Le premier build télécharge les dépendances Maven et npm (~500 Mo). Les démarrages suivants sont rapides.

**Suivi en temps réel :**

```bash
docker-compose logs -f
# ou service par service :
docker-compose logs -f backend
docker-compose logs -f kafka
docker-compose logs -f keycloak
```

---

## 3. Arrêter l'environnement

```bash
# Arrêter tous les services sans supprimer les données
docker-compose down
```

| Commande | Effet |
|---|---|
| `docker-compose down` | Arrête et supprime les conteneurs — **données préservées** |
| `docker-compose stop` | Arrête les conteneurs sans les supprimer |
| `docker-compose down -v` | ⚠️ Arrête + supprime les **volumes** (perte des données MariaDB/Kafka) |

> 💡 Pour un simple redémarrage d'un service : `docker-compose restart backend`

---

## 4. Vérifier que tout est healthy

```bash
docker-compose ps
```

Tu dois voir tous les services en `healthy`. Keycloak est le plus lent (~90 secondes au démarrage).

| Service | Délai typique |
|---|---|
| MariaDB, Redis | ~15 s |
| Kafka | ~40 s |
| Keycloak | ~90 s |
| Backend / Gateway | ~60 s (attend Keycloak) |
| Frontend | ~60 s |

---

## 5. Accéder aux services

| Service | URL | Identifiants |
|---|---|---|
| **Frontend Angular** | <http://localhost:4200> | — |
| **Gateway API** | <http://localhost:8082/api> | requièrent un token Keycloak (Bearer) |
| **Backend Actuator** | <http://localhost:8099/actuator> | — |
| **Keycloak Admin** | <http://localhost:8080> | `admin` / `root` |
| **Kafka UI** | <http://localhost:8090> | — |
| **Prometheus** | <http://localhost:9090> | — |
| **Grafana** | <http://localhost:3000> | `admin` / `grafana_secret` |
| **Worker Crossmatch** | <http://localhost:8001/docs> | — |
| **Worker Spectral** | <http://localhost:8002/docs> | — |
| **Worker GPU** | <http://localhost:8003/docs> | — |

**Comptes de test Keycloak (realm `starwave`) :**

| Utilisateur | Mot de passe | Rôle |
|---|---|---|
| `admin` | `admin123` | ROLE_ADMIN |
| `operator` | `operator123` | ROLE_OPERATOR |
| `analyst` | `analyst123` | ROLE_ANALYST |
| `viewer` | `viewer123` | ROLE_VIEWER |

---

## 6. Structure du projet

```
starwave/
├── backend/        → Spring Boot (API REST, Batch, WebSocket)
├── gateway/        → Spring Cloud Gateway (reverse proxy, JWT)
├── frontend/       → Angular 21 (dashboard Mission Control)
├── crossmatch/     → FastAPI worker (cross-match stellaire)
├── spectral/       → FastAPI worker (analyse spectrale)
├── workers/        → FastAPI worker (traitement générique)
└── infra/
    └── docker/
        ├── mariadb/     → init.sql (schéma + données de démo)
        ├── keycloak/    → realm-starwave.json
        ├── prometheus/  → prometheus.yml + règles d'alerte
        └── grafana/     → dashboards + provisioning
```

---

## 7. Dépannage rapide

**Variables d'environnement vides au démarrage**

```bash
# Le fichier .env est manquant
cp .env.example .env
```

**Port déjà utilisé**

```bash
# Modifier le port dans .env, par exemple :
BACKEND_PORT=18081
```

**Kafka ne démarre pas**

```bash
docker-compose logs kafka
# Si le volume est corrompu :
docker-compose down -v   # supprime les volumes
docker-compose up -d --build
```

**Keycloak en boucle au démarrage**

```bash
# Keycloak attend MariaDB — vérifier que MariaDB est healthy
docker-compose ps mariadb
docker-compose logs mariadb
```

**Rebuild d'un seul service**

```bash
docker-compose up -d --build backend
docker-compose up -d --build worker-crossmatch
```

---

## 8. Hot-reload (développement)

Le fichier `docker-compose.override.yml` est chargé automatiquement et active le rechargement automatique du code source sans rebuild d'image :

- **Workers Python** : `uvicorn --reload` — toute modification de `.py` est prise en compte immédiatement
- **Frontend Angular** : `ng serve` avec live-reload natif
- **Backend / Gateway** : Spring DevTools — redémarre l'appli à chaque modification de classe

---
