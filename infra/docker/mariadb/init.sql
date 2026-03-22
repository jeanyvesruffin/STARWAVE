-- =============================================================================
-- STARWAVE – Initialisation base de données MariaDB
-- Exécuté automatiquement au premier démarrage du conteneur
-- =============================================================================

SET NAMES utf8mb4;
SET time_zone = '+00:00';

-- Créer la base si elle n'existe pas (sécurité)
CREATE DATABASE IF NOT EXISTS `starwave`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `starwave`;

-- ---------------------------------------------------------------------------
-- Table : telescopes – registre des capteurs
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `telescopes` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(128) NOT NULL,
  `location`    VARCHAR(255),
  `latitude`    DOUBLE,
  `longitude`   DOUBLE,
  `status`      ENUM('ONLINE','OFFLINE','MAINTENANCE') NOT NULL DEFAULT 'OFFLINE',
  `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_telescope_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Table : signals – signaux radio détectés
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `signals` (
  `id`              BIGINT        NOT NULL AUTO_INCREMENT,
  `telescope_id`    BIGINT        NOT NULL,
  `frequency_mhz`   DOUBLE        NOT NULL COMMENT 'Fréquence en MHz',
  `bandwidth_khz`   DOUBLE,
  `snr_db`          DOUBLE        COMMENT 'Signal/Noise Ratio en dB',
  `duration_ms`     BIGINT,
  `raw_data_path`   VARCHAR(512)  COMMENT 'Chemin S3 vers les données brutes',
  `status`          ENUM('RAW','PROCESSING','CROSSMATCHED','FLAGGED','REJECTED') NOT NULL DEFAULT 'RAW',
  `detected_at`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `processed_at`    DATETIME,
  PRIMARY KEY (`id`),
  KEY `idx_signal_telescope` (`telescope_id`),
  KEY `idx_signal_status`    (`status`),
  KEY `idx_signal_detected`  (`detected_at`),
  CONSTRAINT `fk_signal_telescope` FOREIGN KEY (`telescope_id`) REFERENCES `telescopes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Table : crossmatch_results – résultats de cross-match stellar
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `crossmatch_results` (
  `id`              BIGINT       NOT NULL AUTO_INCREMENT,
  `signal_id`       BIGINT       NOT NULL,
  `catalog_name`    VARCHAR(64)  NOT NULL COMMENT 'Ex: SIMBAD, NED, Gaia DR3',
  `source_id`       VARCHAR(128) COMMENT 'Identifiant dans le catalogue',
  `object_type`     VARCHAR(64),
  `angular_dist_as` DOUBLE       COMMENT 'Distance angulaire en arcsec',
  `confidence`      DOUBLE       COMMENT 'Score de confiance [0-1]',
  `metadata`        JSON,
  `matched_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_cm_signal` (`signal_id`),
  CONSTRAINT `fk_cm_signal` FOREIGN KEY (`signal_id`) REFERENCES `signals` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Table : spectral_analyses – résultats d'analyse spectrale
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `spectral_analyses` (
  `id`              BIGINT   NOT NULL AUTO_INCREMENT,
  `signal_id`       BIGINT   NOT NULL,
  `peak_freq_mhz`   DOUBLE,
  `spectral_index`  DOUBLE,
  `doppler_shift`   DOUBLE,
  `ai_score`        DOUBLE   COMMENT 'Score anomalie IA [0-1]',
  `ai_label`        VARCHAR(64),
  `analysis_data`   JSON,
  `analyzed_at`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sa_signal` (`signal_id`),
  CONSTRAINT `fk_sa_signal` FOREIGN KEY (`signal_id`) REFERENCES `signals` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Table : batch_jobs – suivi des jobs Spring Batch
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `batch_job_registry` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT,
  `job_name`    VARCHAR(128) NOT NULL,
  `status`      ENUM('STARTED','COMPLETED','FAILED','STOPPED') NOT NULL,
  `start_time`  DATETIME,
  `end_time`    DATETIME,
  `records_in`  BIGINT DEFAULT 0,
  `records_out` BIGINT DEFAULT 0,
  `error_msg`   TEXT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Données de démo (dev only)
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO `telescopes` (`name`, `location`, `latitude`, `longitude`, `status`) VALUES
  ('FAST-China',      'Guizhou, China',    25.6525,  106.8573, 'ONLINE'),
  ('Parkes-64m',      'New South Wales, AU', -32.9994, 148.2635, 'ONLINE'),
  ('Arecibo-Legacy',  'Puerto Rico, US',   18.3464,  -66.7528, 'OFFLINE'),
  ('GBT-WV',          'Green Bank, WV, US', 38.4332, -79.8400, 'ONLINE'),
  ('LOFAR-NL',        'Exloo, Netherlands', 52.9088,   6.8683, 'ONLINE');
