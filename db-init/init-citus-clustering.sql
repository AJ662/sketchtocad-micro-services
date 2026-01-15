-- Citus initialization script for Clustering service
-- This script runs on the coordinator node at startup

-- Enable Citus extension
CREATE EXTENSION IF NOT EXISTS citus;

-- Create the sessions table (same schema as SQLAlchemy model)
CREATE TABLE IF NOT EXISTS sessions (
    id VARCHAR(64) PRIMARY KEY,
    saga_id VARCHAR(64),
    status VARCHAR(30) DEFAULT 'created',
    
    -- Step 1: Image Processing Data
    raw_image_ref VARCHAR(256),
    bed_data JSONB,
    bed_count INTEGER,
    image_shape JSONB,
    image_processing_time_ms INTEGER,
    
    -- Step 2: Clustering Data
    enhanced_colors JSONB,
    enhancement_method VARCHAR(50),
    clusters JSONB,
    cluster_count INTEGER,
    clustering_time_ms INTEGER,
    
    -- Step 3: DXF Export Data
    dxf_content BYTEA,
    dxf_file_ref VARCHAR(256),
    dxf_file_size INTEGER,
    export_time_ms INTEGER,
    
    -- Error tracking
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);

-- Create index on saga_id for efficient lookups
CREATE INDEX IF NOT EXISTS idx_sessions_saga_id ON sessions(saga_id);
