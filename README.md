# 🚀 DevOps Practical Execution Task

**Prepared by:** JobAxle | **Duration:** 3 Hours (2:00 PM – 5:00 PM)

**Live Frontend:** [https://super-treacle-a8dae5.netlify.app/](https://super-treacle-a8dae5.netlify.app/)

---

## 📋 Table of Contents

1. [Task 1 — Initialize Git Repository & Push to GitHub](#task-1--initialize-git-repository-and-push-to-github)
2. [Task 2 — Branching Strategy](#task-2--branching-strategy)
3. [Task 3 — Merge Conflict Resolution](#task-3--merge-conflict-resolution)
4. [Task 4 — Dockerfile Optimization](#task-4--dockerfile-optimization)
5. [Task 5 — Run & Debug Container](#task-5--run--debug-container)
6. [Task 6 — Docker Compose Multi-Container Setup](#task-6--docker-compose-multi-container-setup)
7. [Task 7 — CI Pipeline Using GitHub Actions](#task-7--ci-pipeline-using-github-actions)
8. [Task 8 — Bash Deployment Script](#task-8--bash-deployment-script)
9. [Task 9 — Environment Variables (Secure Config)](#task-9--environment-variables-secure-config)
10. [Task 10 — Nginx as Reverse Proxy](#task-10--nginx-as-reverse-proxy)
11. [Task 11 — Deploy Static Frontend on Netlify](#task-11--deploy-static-frontend-on-netlify)
12. [Task 12 — Log Analysis & Root Cause Identification](#task-12--log-analysis--root-cause-identification)
13. [Task 13 — Debug a Failing Container](#task-13--debug-a-failing-container)
14. [Task 14 — Full CI/CD YAML File](#task-14--full-cicd-yaml-file)
15. [Task 15 — End-to-End Deployment Lifecycle](#task-15--end-to-end-deployment-lifecycle)

---

## Task 1 — Initialize Git Repository and Push to GitHub

```bash
git init
git add .
git commit -m "feat: initial project setup with Node.js express app"
git remote add origin https://github.com/YOUR_USERNAME/devops-practical.git
git push -u origin main
```

**Commit Message Convention:**

| Prefix | Purpose |
|--------|---------|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `chore:` | Maintenance/setup |
| `docs:` | Documentation update |
| `merge:` | Branch merge commit |

---

## Task 2 — Branching Strategy

**Strategy Used: Git Flow**

```
main        ●────────────────────────●  (production only)
             \                      /
develop       ●──────────────────●    (integration/staging)
               \                /
feature/*       ●────────────●         (individual features)
```

| Branch | Purpose |
|--------|---------|
| `main` | Production-ready code only |
| `develop` | Integration of all features |
| `feature/*` | Individual feature development |

```bash
git checkout -b develop
git checkout -b feature/add-health-endpoint

git add .
git commit -m "feat: add health check endpoint to express app"

git checkout develop
git merge feature/add-health-endpoint

git checkout main
git merge develop -m "merge: develop into main for release v1.0"

git push origin main
git push origin develop
git push origin feature/add-health-endpoint
```

---

## Task 3 — Merge Conflict Resolution

**Step 1 — Simulate the conflict:**

```bash
git checkout develop
git checkout -b feature/branch-A
# Edit app/index.js → message: 'Hello from Branch A!'
git add app/index.js
git commit -m "feat: update message in branch A"

git checkout develop
git checkout -b feature/branch-B
# Edit the SAME line → message: 'Hello from Branch B!'
git add app/index.js
git commit -m "feat: update message in branch B"
```

**Step 2 — Trigger the conflict:**

```bash
git checkout develop
git merge feature/branch-A   # succeeds
git merge feature/branch-B   # CONFLICT triggered
```

**Step 3 — Git marks the conflict:**

```
<<<<<<< HEAD
    message: 'Hello from Branch A!'
=======
    message: 'Hello from Branch B!'
>>>>>>> feature/branch-B
```

**Step 4 — Resolve manually:**

Remove all conflict markers and keep the correct line:

```javascript
message: 'Hello from DevOps Practical!'
```

**Step 5 — Complete the resolution:**

```bash
git add app/index.js
git commit -m "fix: resolve merge conflict between branch-A and branch-B"
```

---

## Task 4 — Dockerfile Optimization

```dockerfile
# Stage 1: Builder
FROM node:18-alpine AS builder
WORKDIR /app
COPY app/package*.json ./
RUN npm ci --omit=dev

# Stage 2: Production Image
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY app/ .
EXPOSE 3000
USER node
CMD ["node", "index.js"]
```

**Optimization Techniques:**

| Technique | Benefit |
|-----------|---------|
| `node:18-alpine` | ~50MB vs ~900MB for full image |
| Multi-stage build | Build tools excluded from final image |
| `npm ci --omit=dev` | Skips devDependencies |
| `COPY package*.json` first | Leverages Docker layer caching |
| `USER node` | Security — never run as root |

---

## Task 5 — Run & Debug Container

```bash
docker build -t devops-practical .
docker run -d -p 3000:3000 --name myapp devops-practical
curl http://localhost:3000/health
```

**Debug Commands:**

```bash
docker logs myapp
docker logs -f myapp
docker ps -a
docker inspect myapp --format='{{.State.ExitCode}}'
docker exec -it myapp sh
docker stats myapp
```

**Issue Found & Fixed:**

```
Error: npm ci command can only install with an existing package-lock.json
```

**Root Cause:** `package-lock.json` was missing from the `app/` folder.

**Fix:**
```bash
cd app
npm install     # generates package-lock.json
cd ..
docker build -t devops-practical .
```

---

## Task 6 — Docker Compose Multi-Container Setup

**`docker-compose.yml`:**

```yaml
version: '3.8'

services:

  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - PORT=3000
      - DB_HOST=db
      - DB_PORT=5432
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=${POSTGRES_DB}
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - app
    restart: unless-stopped

volumes:
  pgdata:
```

```bash
cp .env.example .env
docker-compose up -d
docker-compose ps
docker-compose logs app
docker-compose down
```

**Architecture:**
```
Internet → Nginx (port 80) → Node.js App (port 3000) → PostgreSQL (port 5432)
```

---

## Task 7 — CI Pipeline Using GitHub Actions

**`.github/workflows/ci-cd.yml`:**

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:

  build-and-test:
    name: Build & Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: app/package.json
      - run: cd app && npm ci
      - run: cd app && npm test

  docker-build:
    name: Docker Build & Health Check
    runs-on: ubuntu-latest
    needs: build-and-test
    steps:
      - uses: actions/checkout@v3
      - run: docker build -t devops-practical:latest .
      - run: |
          docker run -d -p 3000:3000 --name test-app devops-practical:latest
          sleep 5
          curl -f http://localhost:3000/health || exit 1
          docker stop test-app

  deploy:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: docker-build
    if: github.ref == 'refs/heads/main'
    steps:
      - run: echo "Deployed commit ${{ github.sha }} successfully"
```

**Pipeline Flow:**
```
Push → Build & Test → Docker Build & Health Check → Deploy (main only)
```

---

## Task 8 — Bash Deployment Script

**`scripts/deploy.sh`:**

```bash
#!/bin/bash
set -e

echo "=== DevOps Practical — Auto Deploy ==="

# Load environment variables
if [ -f .env ]; then
  export $(cat .env | grep -v '#' | grep -v '^$' | xargs)
else
  echo "ERROR: .env file not found!"
  exit 1
fi

git pull origin main
docker-compose build --no-cache
docker-compose down
docker-compose up -d

sleep 5
if curl -f -s http://localhost/health > /dev/null; then
  echo "Deployment successful — app is healthy!"
else
  echo "Health check failed!"
  docker-compose logs app
  exit 1
fi
```

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

---

## Task 9 — Environment Variables (Secure Config)

**`.env.example`** (committed to Git — safe template):

```bash
NODE_ENV=production
PORT=3000
POSTGRES_DB=myapp_db
POSTGRES_USER=myapp_user
POSTGRES_PASSWORD=your_secure_password_here
# Copy this to .env and fill in real values. NEVER commit .env!
```

```bash
cp .env.example .env
```

**GitHub Actions Secrets:**

```yaml
env:
  POSTGRES_PASSWORD: ${{ secrets.POSTGRES_PASSWORD }}
```

Add secrets via: GitHub repo → Settings → Secrets and variables → Actions

**Security Practices:**

| Practice | How |
|----------|-----|
| Never commit secrets | `.env` is in `.gitignore` |
| Safe template | `.env.example` in repo |
| CI/CD secrets | GitHub Actions encrypted secrets |
| Non-root container | `USER node` in Dockerfile |

---

## Task 10 — Nginx as Reverse Proxy

**`nginx/nginx.conf`:**

```nginx
events {
    worker_connections 1024;
}

http {
    upstream app {
        server app:3000;
    }

    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://app;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_cache_bypass $http_upgrade;
        }

        location /health {
            proxy_pass http://app/health;
        }
    }
}
```

**Traffic Flow:**
```
User → http://localhost:80 → Nginx → http://app:3000 → Node.js App
```

| Benefit | Description |
|---------|-------------|
| Security | Port 3000 not exposed publicly |
| Load balancing | Distribute to multiple app instances |
| SSL termination | Handle HTTPS at Nginx level |

---

## Task 11 — Deploy Static Frontend on Netlify

**`frontend/index.html`:**

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>DevOps Practical — JobAxle</title>
  <style>
    body { font-family: sans-serif; background: #0f172a; color: #e2e8f0;
           display: flex; align-items: center; justify-content: center; min-height: 100vh; }
    .card { background: #1e293b; padding: 40px; border-radius: 12px; text-align: center; }
    h1 { color: #38bdf8; }
    .badge { background: #0ea5e9; color: white; padding: 4px 12px; border-radius: 20px; }
  </style>
</head>
<body>
  <div class="card">
    <h1>🚀 DevOps Practical</h1>
    <p>JobAxle Practical Execution Task</p>
    <p>Frontend deployed on Netlify | Backend on Docker + Nginx</p>
    <span class="badge">✅ Deployed Successfully</span>
  </div>
</body>
</html>
```

**Deployment Steps:**
1. Go to [https://netlify.com](https://netlify.com) and log in
2. Click **Add new site** → **Deploy manually**
3. Drag and drop the `frontend/` folder
4. Copy the live URL provided

**Live URL:** [https://super-treacle-a8dae5.netlify.app/](https://super-treacle-a8dae5.netlify.app/)

---

## Task 12 — Log Analysis & Root Cause Identification

```bash
docker logs myapp
docker logs -f myapp
docker logs --tail 50 --timestamps myapp
docker-compose logs -f app
```

**Common Log Messages & Fixes:**

| Log Message | Root Cause | Fix |
|-------------|-----------|-----|
| `ECONNREFUSED 127.0.0.1:5432` | DB container not running | Check `docker-compose ps`, start db |
| `Cannot find module 'express'` | node_modules missing | Run `npm install` |
| `OOMKilled` (exit 137) | Out of memory | Increase Docker memory limit |
| `port is already allocated` | Port already in use | Stop conflicting process |
| `502 Bad Gateway` | Nginx can't reach app | App container is down |

```bash
docker stats myapp
docker inspect myapp --format='{{.State.ExitCode}}'
docker inspect myapp --format='{{.RestartCount}}'
```

---

## Task 13 — Debug a Failing Container

```bash
# Step 1: Check status
docker ps -a

# Step 2: Read logs
docker logs myapp

# Step 3: Check exit code
docker inspect myapp --format='{{.State.ExitCode}}'
# 1 = app error | 137 = OOM killed | 0 = clean exit

# Step 4: Enter container shell
docker exec -it myapp sh

# Step 5: Run app manually inside container
node index.js

# Step 6: Rebuild from scratch
docker build --no-cache -t devops-practical .
```

**Real Debugging Case:**

**Error:**
```
npm error The npm ci command can only install with an existing package-lock.json
```

**Root Cause:** `package-lock.json` was missing — `npm install` had never been run in `app/`.

**Fix:**
```bash
cd app && npm install
docker build -t devops-practical .

git add app/package-lock.json
git commit -m "fix: add package-lock.json for npm ci compatibility"
git push origin main
```

---

## Task 14 — Full CI/CD YAML File

**`.github/workflows/ci-cd.yml`:**

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:

  build-and-test:
    name: Build & Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: app/package.json
      - run: cd app && npm ci
      - run: cd app && npm test
      - uses: actions/upload-artifact@v3
        if: always()
        with:
          name: coverage-report
          path: app/coverage/

  docker-build:
    name: Docker Build & Verify
    runs-on: ubuntu-latest
    needs: build-and-test
    steps:
      - uses: actions/checkout@v3
      - run: docker build -t devops-practical:${{ github.sha }} .
      - run: docker tag devops-practical:${{ github.sha }} devops-practical:latest
      - run: |
          docker run -d -p 3000:3000 --name test-app devops-practical:latest
          sleep 5
          curl -f http://localhost:3000/health && echo "Health check passed!" || exit 1
          docker stop test-app && docker rm test-app

  deploy:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: docker-build
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - run: |
          echo "Deployment Successful!"
          echo "Commit: ${{ github.sha }}"
          echo "Branch: ${{ github.ref_name }}"
          echo "Time:   $(date)"
```

| Stage | Trigger | Actions |
|-------|---------|---------|
| Build & Test | Every push | Install → Test → Upload coverage |
| Docker Build | Tests pass | Build image → Tag → Health check |
| Deploy | Main branch only | Deploy to production |

---

## Task 15 — End-to-End Deployment Lifecycle

```
Developer Machine
  └── Write code → git commit → git push to feature branch
                                        │
                                        ▼
                              GitHub Actions CI/CD
                                        │
                              Stage 1: Build & Test
                                Install deps + run tests
                                If FAIL → stop, notify dev
                                        │
                              Stage 2: Docker Build
                                Build image + health check
                                If FAIL → stop, notify dev
                                        │
                              Stage 3: Deploy (main only)
                                Run deploy.sh on server
                                        │
                                        ▼
                              Production Server
                                docker-compose up -d
                                PostgreSQL → App → Nginx
                                        │
                                        ▼
                                    End User
                                http://your-domain.com
```

**Possible Failure Points:**

| Stage | Failure | Detection | Resolution |
|-------|---------|-----------|------------|
| CI | Missing package-lock.json | `npm ci` error | Run `npm install`, commit lock file |
| Docker Build | Wrong COPY path | Build error | Verify paths in Dockerfile |
| Tests | Failing assertion | Stage 1 fails | Fix failing test logic |
| Container Start | Port already in use | Container exits immediately | Stop conflicting process |
| Container Start | Missing `.env` | App crashes on startup | Copy `.env.example` to `.env` |
| Database | DB not ready | `ECONNREFUSED` in logs | Use `depends_on` + retry logic |
| Nginx | Wrong upstream name | 502 Bad Gateway | Fix `nginx.conf` upstream to match compose service name |
| Production | Out of memory | Exit code 137 | Increase Docker memory limit |

---

<div align="center">

Made with ❤️ for the JobAxle DevOps Practical Task

</div>
