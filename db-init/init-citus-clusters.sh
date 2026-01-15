#!/bin/bash
# Citus cluster initialization script
# Registers worker nodes and distributes tables after all nodes are healthy

set -e

echo "Waiting for Citus clusters to be ready..."
sleep 15

# ============================================================
# Image Processing Cluster
# ============================================================
exec_psql citus-image-processing-coordinator imageprocessingdb "SELECT citus_set_coordinator_host('citus-image-processing-coordinator', 5432);"
exec_psql citus-image-processing-coordinator imageprocessingdb "SELECT citus_add_node('citus-image-processing-worker-1', 5432);"
exec_psql citus-image-processing-coordinator imageprocessingdb "DO \$\$ BEGIN IF NOT EXISTS (SELECT 1 FROM citus_tables WHERE table_name = 'sessions'::regclass) THEN PERFORM create_distributed_table('sessions', 'id', shard_count := 32); END IF; END \$\$;"
exec_psql citus-image-processing-coordinator imageprocessingdb "DO \$\$ BEGIN IF NOT EXISTS (SELECT 1 FROM citus_tables WHERE table_name = 'image_processing_sessions'::regclass) THEN PERFORM create_reference_table('image_processing_sessions'); END IF; END \$\$;"
exec_psql citus-image-processing-coordinator imageprocessingdb "SELECT nodename, nodeport FROM citus_get_active_worker_nodes();"
echo "Image Processing cluster initialized!"

# ============================================================
# Clustering Cluster
# ============================================================
echo "Initializing Clustering Citus cluster..."
exec_psql citus-clustering-coordinator clusteringdb "SELECT citus_set_coordinator_host('citus-clustering-coordinator', 5432);"
exec_psql citus-clustering-coordinator clusteringdb "SELECT citus_add_node('citus-clustering-worker-1', 5432);"
exec_psql citus-clustering-coordinator clusteringdb "DO \$\$ BEGIN IF NOT EXISTS (SELECT 1 FROM citus_tables WHERE table_name = 'sessions'::regclass) THEN PERFORM create_distributed_table('sessions', 'id', shard_count := 32); END IF; END \$\$;"
exec_psql citus-clustering-coordinator clusteringdb "SELECT nodename, nodeport FROM citus_get_active_worker_nodes();"
echo "Clustering cluster initialized!"

# ============================================================
# DXF Export Cluster
# ============================================================
echo "Initializing DXF Export Citus cluster..."
exec_psql citus-dxf-export-coordinator dxfexportdb "SELECT citus_set_coordinator_host('citus-dxf-export-coordinator', 5432);"
exec_psql citus-dxf-export-coordinator dxfexportdb "SELECT citus_add_node('citus-dxf-export-worker-1', 5432);"
exec_psql citus-dxf-export-coordinator dxfexportdb "DO \$\$ BEGIN IF NOT EXISTS (SELECT 1 FROM citus_tables WHERE table_name = 'sessions'::regclass) THEN PERFORM create_distributed_table('sessions', 'id', shard_count := 32); END IF; END \$\$;"
exec_psql citus-dxf-export-coordinator dxfexportdb "SELECT nodename, nodeport FROM citus_get_active_worker_nodes();"
echo "DXF Export cluster initialized!"

echo ""
echo "============================================"
echo "All Citus clusters initialized successfully!"
echo "============================================"
