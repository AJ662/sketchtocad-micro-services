# 1. Apply all Kubernetes manifests
kubectl apply -f kubernetes/ -R

# 2. Wait for pods to be ready
kubectl get pods -w

# 3. Initialize the saga database (one-time)
kubectl exec -it $(kubectl get pod -l app=workflow-orchestrator -o jsonpath='{.items[0].metadata.name}') -- python -c "from app.database.init_db import init_database; init_database()"

# 4. Start port-forwards to access services locally
kubectl port-forward svc/frontend 3000:3000 &
kubectl port-forward svc/api-gateway 8000:8000 &
kubectl port-forward svc/grafana 3001:3000 &

# 5. To stop the cluster/pods
kubectl delete -f kubernetes/ -R
