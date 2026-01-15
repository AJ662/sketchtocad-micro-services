#!/bin/bash
# Citus cluster initialization script
# Registers worker nodes and distributes tables after all nodes are healthy

set -e

echo "Waiting for Citus clusters to be ready..."
sleep 15

# ============================================================
# Image Processing Cluster
# ============================================================
echo "Initializing Image Processing Citus cluster..."
PGPASSWORD=sketchtocad_dev psql -h citus-image-processing-coordinator -U sketchtocad -d image_processing <<EOF
-- Register worker nodes
SELECT citus_add_node('citus-image-processing-worker-1', 5432);
SELECT citus_add_node('citus-image-processing-worker-2', 5432);

-- Distribute the sessions table by id across workers (32 shards)
SELECT create_distributed_table('sessions', 'id', shard_count := 32);

-- Keep image_processing_sessions as a reference table (replicated to all nodes)
SELECT create_reference_table('image_processing_sessions');

-- Verify setup
SELECT nodename, nodeport FROM citus_get_active_worker_nodes();
SELECT table_name, citus_table_type, distribution_column FROM citus_tables;
EOF
echo "Image Processing cluster initialized!"

# ============================================================
# Clustering Cluster
# ============================================================
echo "Initializing Clustering Citus cluster..."
PGPASSWORD=password psql -h citus-clustering-coordinator -U postgres -d clusteringdb <<EOF
-- Register worker nodes
SELECT citus_add_node('citus-clustering-worker-1', 5432);
SELECT citus_add_node('citus-clustering-worker-2', 5432);

-- Distribute the sessions table by id across workers (32 shards)
SELECT create_distributed_table('sessions', 'id', shard_count := 32);

-- Verify setup
SELECT nodename, nodeport FROM citus_get_active_worker_nodes();
SELECT table_name, citus_table_type, distribution_column FROM citus_tables;
EOF
echo "Clustering cluster initialized!"

# ============================================================
# DXF Export Cluster
# ============================================================
echo "Initializing DXF Export Citus cluster..."
PGPASSWORD=password psql -h citus-dxf-export-coordinator -U postgres -d dxfexportdb <<EOF
-- Register worker nodes
SELECT citus_add_node('citus-dxf-export-worker-1', 5432);
SELECT citus_add_node('citus-dxf-export-worker-2', 5432);

-- Distribute the sessions table by id across workers (32 shards)
SELECT create_distributed_table('sessions', 'id', shard_count := 32);

-- Verify setup
SELECT nodename, nodeport FROM citus_get_active_worker_nodes();
SELECT table_name, citus_table_type, distribution_column FROM citus_tables;
EOF
echo "DXF Export cluster initialized!"

echo ""
echo "============================================"
echo "All Citus clusters initialized successfully!"
echo "============================================"
