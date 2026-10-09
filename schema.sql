-- Personalized Health Monitoring System schema (MySQL 8+)
CREATE DATABASE IF NOT EXISTS health_monitoring;
USE health_monitoring;

CREATE TABLE IF NOT EXISTS users (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS health_metrics (
    metric_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    heart_rate SMALLINT UNSIGNED NOT NULL,
    spo2 DECIMAL(5,2) NOT NULL,
    steps INT UNSIGNED NOT NULL DEFAULT 0,
    sleep_hours DECIMAL(4,2) NOT NULL DEFAULT 0.00,
    recorded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_metrics_user FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_heart_rate CHECK (heart_rate BETWEEN 20 AND 250),
    CONSTRAINT chk_spo2 CHECK (spo2 BETWEEN 0 AND 100),
    CONSTRAINT chk_sleep_hours CHECK (sleep_hours BETWEEN 0 AND 24)
) ENGINE = InnoDB;

CREATE INDEX idx_metrics_user_recorded ON health_metrics (user_id, recorded_at DESC);

CREATE TABLE IF NOT EXISTS health_goals (
    goal_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    goal_type VARCHAR(40) NOT NULL,
    target_value DECIMAL(10,2) NOT NULL,
    current_value DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    start_date DATE NOT NULL,
    end_date DATE,
    status ENUM('ACTIVE', 'COMPLETED', 'PAUSED') NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT fk_goals_user FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE INDEX idx_goals_user_status ON health_goals (user_id, status);

CREATE TABLE IF NOT EXISTS health_alerts (
    alert_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    metric_id BIGINT,
    alert_type VARCHAR(60) NOT NULL,
    message VARCHAR(500) NOT NULL,
    severity ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') NOT NULL DEFAULT 'LOW',
    is_acknowledged BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_alerts_user FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_alerts_metric FOREIGN KEY (metric_id) REFERENCES health_metrics(metric_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE INDEX idx_alerts_user_created ON health_alerts (user_id, created_at DESC);

INSERT INTO users (full_name, email, password_hash, date_of_birth)
VALUES ('Aarav Sharma', 'aarav@example.com', '$2a$10$example-hash-replace-in-production', '1998-04-16')
ON DUPLICATE KEY UPDATE email = VALUES(email);

INSERT INTO health_metrics (user_id, heart_rate, spo2, steps, sleep_hours, recorded_at)
SELECT user_id, 72, 98.00, 6840, 7.50, NOW() - INTERVAL 1 DAY
FROM users WHERE email = 'aarav@example.com'
  AND NOT EXISTS (SELECT 1 FROM health_metrics WHERE user_id = users.user_id);

INSERT INTO health_goals (user_id, goal_type, target_value, current_value, start_date)
SELECT user_id, 'DAILY_STEPS', 10000, 6840, CURRENT_DATE
FROM users WHERE email = 'aarav@example.com'
  AND NOT EXISTS (SELECT 1 FROM health_goals WHERE user_id = users.user_id);
