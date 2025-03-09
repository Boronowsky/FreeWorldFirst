#!/bin/bash
set -e

echo "🚀 Erstelle GitHub Actions CI/CD-Workflows..."

cd FreeWorldFirst

# Verzeichnis für GitHub Workflows erstellen
mkdir -p .github/workflows

# CI-Workflow für Pull Requests
cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  pull_request:
    branches: [ main ]

jobs:
  lint-frontend:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./frontend
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run ESLint
        run: npm run lint

  lint-backend:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./backend
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: backend/package-lock.json
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run ESLint
        run: npm run lint

  test-frontend:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./frontend
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm test

  test-backend:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./backend
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: freeworldfirst_test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: backend/package-lock.json
      
      - name: Install dependencies
        run: npm ci
      
      - name: Generate Prisma Client
        run: npx prisma generate
      
      - name: Run migrations
        run: npx prisma migrate deploy
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/freeworldfirst_test?schema=public
      
      - name: Run tests
        run: npm test
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/freeworldfirst_test?schema=public
          JWT_SECRET: test-secret
EOF

# CD-Workflow für Deployment bei Merge in main
cat > .github/workflows/cd.yml << 'EOF'
name: CD

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Build and push Backend
        uses: docker/build-push-action@v4
        with:
          context: ./backend
          push: true
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/freeworldfirst-backend:latest
      
      - name: Build and push Frontend
        uses: docker/build-push-action@v4
        with:
          context: ./frontend
          push: true
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/freeworldfirst-frontend:latest
      
      - name: Deploy to Production
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SSH_HOST }}
          username: ${{ secrets.SSH_USERNAME }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            cd /path/to/deployment
            docker-compose pull
            docker-compose up -d
EOF

# Workflow für Sicherheitsanalyse
cat > .github/workflows/security.yml << 'EOF'
name: Security Scan

on:
  schedule:
    - cron: '0 0 * * 0'  # Läuft jeden Sonntag um Mitternacht
  workflow_dispatch:     # Ermöglicht manuelle Ausführung

jobs:
  security-scan:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Run npm audit (Frontend)
        working-directory: ./frontend
        run: npm audit --audit-level=high
      
      - name: Run npm audit (Backend)
        working-directory: ./backend
        run: npm audit --audit-level=high
      
      - name: Run Snyk to check for vulnerabilities (Frontend)
        uses: snyk/actions/node@master
        continue-on-error: true
        with:
          args: --severity-threshold=high
          command: test
          json: true
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

      - name: Run Snyk to check for vulnerabilities (Backend)
        uses: snyk/actions/node@master
        continue-on-error: true
        with:
          args: --severity-threshold=high --file=./backend/package.json
          command: test
          json: true
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
EOF

# README mit Anweisungen zu GitHub Secrets aktualisieren
cat >> README.md << 'EOF'

## CI/CD mit GitHub Actions

Dieses Projekt verwendet GitHub Actions für kontinuierliche Integration und kontinuierliches Deployment. Um die Workflows vollständig zu nutzen, müssen folgende Secrets in den GitHub Repository-Einstellungen konfiguriert werden:

- `DOCKERHUB_USERNAME`: Dein Docker Hub Benutzername
- `DOCKERHUB_TOKEN`: Dein Docker Hub Access Token
- `SSH_HOST`: Hostname oder IP-Adresse deines Produktionsservers
- `SSH_USERNAME`: SSH-Benutzername für den Produktionsserver
- `SSH_PRIVATE_KEY`: SSH-Private-Key für die Authentifizierung
- `SNYK_TOKEN`: (Optional) API-Token für Snyk-Sicherheitsanalysen

Diese Secrets werden für das automatische Bauen und Bereitstellen der Anwendung verwendet, wenn Code in den main-Branch gemergt wird.
EOF

echo "✅ GitHub Actions CI/CD-Workflows erfolgreich erstellt!"