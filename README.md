## DevOps-Project

A small FastAPI application used to demonstrate DevOps practices: containerization, testing, database integration, and Kubernetes/Helm deployment.

### Features
- FastAPI service exposing:
  - `GET /healthz`: health check
  - `GET /`: greeting message
  - `GET /users`: returns users from a PostgreSQL database
- PostgreSQL integration via `psycopg2`
- Docker multi-stage build (`Dockerfile`)
- Kubernetes manifests (`deploy/kubernetes`)
- Helm chart (`deploy/helm`)
- Simple SQL migrations (`db/migrations`)
- Basic tests with `pytest`

### Repository Structure
```
app/
  src/
    main.py          # FastAPI app and routes
    db.py            # DB connection and queries
  requirements.txt   # App + tooling deps
  tests/             # pytest tests
db/
  migrations/        # SQL schema + seed data
deploy/
  kubernetes/        # Raw k8s manifests
  helm/              # Helm chart and values
Dockerfile            # Multi-stage container build
LICENSE
```

### Requirements
- Python 3.12+ (for local dev without Docker)
- Docker (for containerized runs)
- Kubernetes cluster + `kubectl` (to apply manifests)
- Helm 3 (for Helm deployment)

### Configuration
- **DATABASE_URL**: PostgreSQL URL used by the app and tests
  - Default: `postgresql://testuser:testpass@localhost:5432/testdb`

### Quickstart (Local Python)
1) Create and activate a virtual environment
```
python -m venv .venv
. .venv/Scripts/activate  # PowerShell: . .venv\Scripts\Activate.ps1
```

2) Install dependencies
```
pip install --upgrade pip
pip install -r app/requirements.txt
```

3) Start PostgreSQL (example via Docker)
```
docker run -d --name devops-pg -p 5432:5432 \
  -e POSTGRES_USER=testuser -e POSTGRES_PASSWORD=testpass -e POSTGRES_DB=testdb \
  postgres:16
```

4) Apply migrations (requires `psql` client)
```
psql "$env:DATABASE_URL" -f db/migrations/create_table_users.sql
psql "$env:DATABASE_URL" -f db/migrations/add_users_1.sql
```

5) Run the app
```
$env:DATABASE_URL = "postgresql://testuser:testpass@localhost:5432/testdb"
uvicorn app.src.main:app --host 0.0.0.0 --port 8080
```

### Quickstart (Docker)
1) Build the image
```
docker build -t devops-project:latest .
```

2) Ensure PostgreSQL is running (see step 3 above)

3) Run the container
```
docker run --rm -p 8080:8080 \
  -e DATABASE_URL=postgresql://testuser:testpass@host.docker.internal:5432/testdb \
  devops-project:latest
```

### API Endpoints
- Health:
```
curl http://localhost:8080/healthz
```
- Greeting:
```
curl http://localhost:8080/
```
- Users (requires DB + migrations):
```
curl http://localhost:8080/users
```

### Testing
- Run tests locally:
```
pytest -q
```
- To skip DB tests (e.g., when DB is unavailable):
```
$env:SKIP_DB_TESTS = "1"; pytest -q
```

### Kubernetes Deployment (Docker Desktop)

This project includes Kubernetes manifests for deployment. Docker Desktop provides a built-in Kubernetes cluster that's perfect for local testing.

#### Prerequisites
- Docker Desktop with Kubernetes enabled
- `kubectl` (usually comes with Docker Desktop)

#### Enable Kubernetes in Docker Desktop
1. Open Docker Desktop
2. Go to Settings → Kubernetes
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"

#### Deploy to Docker Desktop Kubernetes

**Option 1: Use local image (recommended for testing)**
1) Build the image locally
```powershell
docker build -t devops-project:latest .
```

2) Load image into Docker Desktop's Kubernetes
```powershell
# For Windows PowerShell
kubectl config use-context docker-desktop
```

3) Apply the manifests
```powershell
kubectl apply -f deploy/kubernetes/deployment.yaml
kubectl apply -f deploy/kubernetes/service.yaml
```

4) Verify deployment
```powershell
# Check pods are running
kubectl get pods

# Check services
kubectl get services

# Check deployment status
kubectl get deployments
```

5) Access the application
```powershell
# Port forward to access the service locally
kubectl port-forward svc/devops-project 8080:80
```

6) Test the endpoints
```powershell
# In another terminal
curl http://localhost:8080/healthz
curl http://localhost:8080/
curl http://localhost:8080/users
```

**Option 2: Use a registry image**
1) Push your image to a registry (Docker Hub, etc.)
2) Update `deploy/kubernetes/deployment.yaml` to use your registry image:
```yaml
image: your-registry/your-username/devops-project:latest
```
3) Apply manifests as above

#### Useful Docker Desktop Kubernetes Commands

```powershell
# View all resources
kubectl get all

# View pod logs
kubectl logs -l app=devops-project

# Scale the deployment
kubectl scale deployment devops-project --replicas=3

# Delete the deployment
kubectl delete -f deploy/kubernetes/

# View detailed pod information
kubectl describe pod <pod-name>

# Execute commands in a pod
kubectl exec -it <pod-name> -- /bin/bash
```

#### Troubleshooting Docker Desktop Kubernetes

```powershell
# Check if Kubernetes is running
kubectl cluster-info

# Check node status
kubectl get nodes

# View events for debugging
kubectl get events --sort-by=.metadata.creationTimestamp

# Check if pods are stuck in Pending
kubectl describe pod <pod-name>
```

#### Database Setup for Kubernetes

The app expects a PostgreSQL database. For testing with Docker Desktop:

1) Deploy PostgreSQL to Kubernetes
```powershell
# Create a simple PostgreSQL deployment
kubectl create deployment postgres --image=postgres:16
kubectl expose deployment postgres --port=5432 --target-port=5432

# Set up the database
kubectl exec -it deployment/postgres -- psql -U postgres -c "CREATE DATABASE testdb;"
kubectl exec -it deployment/postgres -- psql -U postgres -c "CREATE USER testuser WITH PASSWORD 'testpass';"
kubectl exec -it deployment/postgres -- psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE testdb TO testuser;"
```

2) Update the app deployment to use the internal PostgreSQL service
```yaml
# Add to deployment.yaml under containers[0].env
env:
- name: DATABASE_URL
  value: "postgresql://testuser:testpass@postgres:5432/testdb"
```

3) Apply database migrations
```powershell
# Copy migration files to the pod and run them
kubectl cp db/migrations/create_table_users.sql <pod-name>:/tmp/
kubectl exec -it <pod-name> -- psql "$DATABASE_URL" -f /tmp/create_table_users.sql
```

### Helm Deployment (Docker Desktop)

Helm provides templated Kubernetes deployments with configurable values.

#### Prerequisites
- Docker Desktop with Kubernetes enabled
- Helm 3 installed (`choco install kubernetes-helm` or download from GitHub)

#### Deploy with Helm

**Option 1: Use local image**
```powershell
# Build the image
docker build -t devops-project:latest .

# Install with local image
helm install devops-project deploy/helm/DevOps-Project \
  --set image.repository=devops-project \
  --set image.tag=latest \
  --set image.pullPolicy=IfNotPresent
```

**Option 2: Use registry image**
```powershell
# Install with registry image
helm install devops-project deploy/helm/DevOps-Project \
  --set image.repository=your-registry/your-username/devops-project \
  --set image.tag=v1.0.0
```

#### Helm Management Commands

```powershell
# List all releases
helm list

# Check release status
helm status devops-project

# View generated manifests
helm template devops-project deploy/helm/DevOps-Project

# Upgrade with new values
helm upgrade devops-project deploy/helm/DevOps-Project \
  --set replicaCount=3

# Uninstall the release
helm uninstall devops-project

# View release history
helm history devops-project

# Rollback to previous version
helm rollback devops-project 1
```

#### Customizing Values

Create a custom values file:
```yaml
# custom-values.yaml
replicaCount: 3
image:
  repository: devops-project
  tag: latest
  pullPolicy: IfNotPresent
service:
  type: NodePort
  port: 80
containerPort: 8080
```

Install with custom values:
```powershell
helm install devops-project deploy/helm/DevOps-Project -f custom-values.yaml
```

#### Access the Helm-deployed Application

```powershell
# Port forward to access the service
kubectl port-forward svc/devops-project 8080:80

# Test endpoints
curl http://localhost:8080/healthz
curl http://localhost:8080/users
```

### Notes
- The `/users` endpoint depends on a reachable PostgreSQL and applied migrations.
- The Dockerfile uses a multi-stage build and wheels for faster, reproducible installs.
- Linting/security tools like `ruff`, `black`, `bandit`, `pip-audit`, and `semgrep` are listed in `app/requirements.txt` if you want to integrate quality checks.

### License
See `LICENSE` for details.


