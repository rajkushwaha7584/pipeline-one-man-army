CREATE DATABASE IF NOT EXISTS skillpulse;
USE skillpulse;

CREATE TABLE IF NOT EXISTS skills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) DEFAULT '',
    target_hours INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS learning_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    skill_id INT NOT NULL,
    hours DECIMAL(4,1) NOT NULL,
    notes TEXT,
    log_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE
);

INSERT INTO skills (name, category, target_hours)
SELECT seed.name, seed.category, seed.target_hours
FROM (
    SELECT 'Docker' AS name, 'DevOps' AS category, 40 AS target_hours
    UNION ALL SELECT 'Kubernetes', 'DevOps', 60
    UNION ALL SELECT 'Go', 'Programming', 50
    UNION ALL SELECT 'Azure DevOps', 'Cloud', 30
    UNION ALL SELECT 'Terraform', 'DevOps', 35
) AS seed
WHERE NOT EXISTS (SELECT 1 FROM skills WHERE name = seed.name);

INSERT INTO learning_logs (skill_id, hours, notes, log_date)
SELECT skills.id, seed.hours, seed.notes, seed.log_date
FROM (
    SELECT 'Docker' AS skill_name, 2.0 AS hours, 'Learned Docker basics - images, containers, volumes' AS notes, '2026-03-10' AS log_date
    UNION ALL SELECT 'Docker', 1.5, 'Built multi-stage Dockerfile for Go app', '2026-03-12'
    UNION ALL SELECT 'Docker', 3.0, 'Docker Compose with multiple services', '2026-03-14'
    UNION ALL SELECT 'Kubernetes', 1.0, 'Kubernetes architecture overview', '2026-03-11'
    UNION ALL SELECT 'Kubernetes', 2.0, 'Deployed first pod and service', '2026-03-13'
    UNION ALL SELECT 'Go', 2.5, 'Go basics - structs, interfaces, goroutines', '2026-03-10'
    UNION ALL SELECT 'Go', 1.5, 'Built REST API with Gin framework', '2026-03-15'
    UNION ALL SELECT 'Azure DevOps', 1.0, 'Created Azure DevOps org and project', '2026-03-16'
    UNION ALL SELECT 'Terraform', 1.5, 'Terraform basics - providers, state', '2026-03-17'
) AS seed
JOIN skills ON skills.name = seed.skill_name
WHERE NOT EXISTS (
    SELECT 1 FROM learning_logs
    WHERE learning_logs.skill_id = skills.id
      AND learning_logs.hours = seed.hours
      AND learning_logs.notes = seed.notes
      AND learning_logs.log_date = seed.log_date
);