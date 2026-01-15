CREATE TYPE sagastatus AS ENUM ('STARTED', 'COMPLETED', 'FAILED');

CREATE TABLE IF NOT EXISTS sagas (
    id VARCHAR(64) PRIMARY KEY,
    workflow_type VARCHAR(50) NOT NULL,
    status sagastatus NOT NULL DEFAULT 'STARTED',
    current_step VARCHAR(50),
    session_id VARCHAR(64) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (NOW() AT TIME ZONE 'utc') NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (NOW() AT TIME ZONE 'utc') NOT NULL,
    completed_at TIMESTAMP WITHOUT TIME ZONE,
    result_data JSON,
    error_message TEXT,
    total_duration_ms INTEGER
);
CREATE INDEX IF NOT EXISTS ix_sagas_session_id ON sagas (session_id);

CREATE TABLE IF NOT EXISTS saga_step_logs (
    id SERIAL PRIMARY KEY,
    saga_id VARCHAR(64) NOT NULL,
    step_number INTEGER NOT NULL,
    step_name VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    event_type VARCHAR(50),
    correlation_id VARCHAR(64),
    input_data JSON,
    output_data JSON,
    error_message TEXT,
    started_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (NOW() AT TIME ZONE 'utc') NOT NULL,
    completed_at TIMESTAMP WITHOUT TIME ZONE,
    duration_ms INTEGER
);
CREATE INDEX IF NOT EXISTS ix_saga_step_logs_saga_id ON saga_step_logs (saga_id);

CREATE TABLE IF NOT EXISTS saga_compensations (
    id SERIAL PRIMARY KEY,
    saga_id VARCHAR(64) NOT NULL,
    step_name VARCHAR(50) NOT NULL,
    compensation_action VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL,
    error_message TEXT,
    executed_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (NOW() AT TIME ZONE 'utc') NOT NULL
);
CREATE INDEX IF NOT EXISTS ix_saga_compensations_saga_id ON saga_compensations (saga_id);
