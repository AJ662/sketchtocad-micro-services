# SketchToCAD Kubernetes Deployment

## GKE Cluster Info
- **Project**: `treesandshrubsoftheworld`
- **Cluster**: `sketchtocad-cluster`
- **Zone**: `europe-west4-a`
- **Registry**: `gcr.io/treesandshrubsoftheworld/<service>`

---

## Connect to GKE Cluster
```bash
gcloud auth login
gcloud config set project treesandshrubsoftheworld
gcloud container clusters get-credentials sketchtocad-cluster --zone europe-west4-a --project treesandshrubsoftheworld
kubectl config current-context  # Verify: gke_treesandshrubsoftheworld_europe-west4-a_sketchtocad-cluster
```

---

## Deploy (Local / First Time)
```bash
kubectl apply -f kubernetes/ -R
kubectl get pods -w
```

## Initialize Database (one-time)
```bash
kubectl exec -it $(kubectl get pod -l app=workflow-orchestrator -o jsonpath='{.items[0].metadata.name}') -- python -c "from app.database.init_db import init_database; init_database()"
```

---

## Port Forwards (Local Access)
```bash
kubectl port-forward svc/frontend 3000:3000 &
kubectl port-forward svc/api-gateway 8000:8000 &
kubectl port-forward svc/grafana 3001:3000 &
```

---

## Monitoring
```bash
kubectl get pods -n default
kubectl top pods -n default --sort-by=cpu
kubectl top nodes
kubectl describe pod <pod-name> -n default
kubectl logs <pod-name> -n default
```

---

## Common Fixes

### StatefulSet Update Error (immutable fields)
```bash
kubectl delete statefulset postgres-saga postgres-image-processing -n default
kubectl delete pvc postgres-data-postgres-saga-0 postgres-data-postgres-image-processing-0 -n default
# Then sync in ArgoCD
```

### ImagePullBackOff - Check if image exists
```bash
gcloud container images list --project=treesandshrubsoftheworld
```

### Build & Push Image Manually
```bash
gcloud auth configure-docker gcr.io
docker build -t gcr.io/treesandshrubsoftheworld/<service>:latest ./<service-folder>
docker push gcr.io/treesandshrubsoftheworld/<service>:latest
```

### Restart All Deployments
```bash
kubectl rollout restart deployment -n default
```

---

## Teardown
```bash
kubectl delete -f kubernetes/ -R
```