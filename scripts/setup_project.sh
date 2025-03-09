#!/bin/bash
set -e

echo "🚀 Erstelle FreeWorldFirst Collector Projektstruktur..."

# Hauptverzeichnisse erstellen
mkdir -p FreeWorldFirst
cd FreeWorldFirst

# Frontend und Backend Verzeichnisse
mkdir -p frontend backend scripts docs

# Git initialisieren
git init
echo "node_modules/" > .gitignore
echo ".env" >> .gitignore
echo ".env.local" >> .gitignore
echo ".next/" >> .gitignore
echo "dist/" >> .gitignore
echo ".DS_Store" >> .gitignore

# README erstellen
cat > README.md << 'EOF'
# FreeWorldFirst Collector

Eine Plattform für ethische Alternativen zu BigTech-Produkten und -Diensten.

## Projektbeschreibung

FreeWorldFirst Collector ist eine Webanwendung, auf der Benutzer ethische Alternativen zu populären BigTech-Produkten vorschlagen und bewerten können. Das Projekt zielt darauf ab, Menschen dabei zu helfen, datenschutzfreundlichere und ethischere Alternativen zu finden.

## Technologie-Stack

- **Frontend**: Next.js, TypeScript, Tailwind CSS, React Query
- **Backend**: NestJS, TypeScript, Prisma, PostgreSQL
- **DevOps**: Docker, GitHub Actions, Vercel/Railway

## Installation

Siehe Installationsanweisungen in der Dokumentation.
EOF

# package.json für das Hauptverzeichnis
cat > package.json << 'EOF'
{
  "name": "freeworldfirst-collector",
  "version": "0.1.0",
  "description": "Eine Plattform für ethische Alternativen zu BigTech-Produkten",
  "scripts": {
    "dev:frontend": "cd frontend && npm run dev",
    "dev:backend": "cd backend && npm run start:dev",
    "dev": "concurrently \"npm run dev:frontend\" \"npm run dev:backend\"",
    "build:frontend": "cd frontend && npm run build",
    "build:backend": "cd backend && npm run build",
    "build": "npm run build:frontend && npm run build:backend"
  },
  "devDependencies": {
    "concurrently": "^8.2.2"
  }
}
EOF

echo "✅ Projektstruktur erfolgreich erstellt!"