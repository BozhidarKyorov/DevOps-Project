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

### Kubernetes (manifests)
1) Push your image to a registry and update `deploy/kubernetes/deployment.yaml` image reference

2) Apply manifests
```
kubectl apply -f deploy/kubernetes/deployment.yaml
kubectl apply -f deploy/kubernetes/service.yaml
```

3) Access the service (ClusterIP by default). For local testing, port-forward:
```
kubectl port-forward svc/devops-project 8080:80
```

### Helm
1) Set image values and install
```
helm install devops-project deploy/helm/DevOps-Project \
  --set image.repository=<your-registry>/<your-image> \
  --set image.tag=<your-tag>
```

2) Override other values as needed (see `deploy/helm/DevOps-Project/values.yaml`)

### Notes
- The `/users` endpoint depends on a reachable PostgreSQL and applied migrations.
- The Dockerfile uses a multi-stage build and wheels for faster, reproducible installs.
- Linting/security tools like `ruff`, `black`, `bandit`, `pip-audit`, and `semgrep` are listed in `app/requirements.txt` if you want to integrate quality checks.

### License
See `LICENSE` for details.


