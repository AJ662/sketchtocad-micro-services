-- Citus initialization script for Image Processing service
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

-- Create the image_processing_sessions table (legacy table)
CREATE TABLE IF NOT EXISTS image_processing_sessions (
    id VARCHAR PRIMARY KEY,
    original_image_s3_key VARCHAR,
    processed_borders_s3_key VARCHAR,
    image_width INTEGER,
    image_height INTEGER,
    file_size_bytes INTEGER,
    redis_session_key VARCHAR,
    bed_count INTEGER DEFAULT 0,
    bed_data_s3_key VARCHAR,
    raw_border_pixels INTEGER,
    clean_border_pixels INTEGER,
    final_border_pixels INTEGER,
    processing_time_ms FLOAT,
    status VARCHAR DEFAULT 'processing',
    error_message VARCHAR,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP,
    anonymized BOOLEAN DEFAULT FALSE
);
