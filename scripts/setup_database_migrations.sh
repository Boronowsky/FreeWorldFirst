#!/bin/bash
set -e

echo "🚀 Erstelle Datenbank-Migrationen für Prisma..."

cd FreeWorldFirst/backend

# Datenbankverbindung in .env-Datei einstellen
if [ ! -f ".env" ]; then
  echo "DATABASE_URL=\"postgresql://postgres:postgres@localhost:5432/freeworldfirst?schema=public\"" > .env
  echo "JWT_SECRET=\"dev-secret-key\"" >> .env
  echo "JWT_EXPIRATION=\"1d\"" >> .env
  echo "PORT=3001" >> .env
fi

# PostgreSQL muss laufen, damit die Migration funktioniert
echo "⚠️ Stellen Sie sicher, dass PostgreSQL läuft und die Datenbank 'freeworldfirst' existiert!"
echo "⚠️ Falls nicht, führen Sie folgende Befehle aus:"
echo "  docker run --name postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -p 5432:5432 -d postgres:15-alpine"
echo "  docker exec -it postgres createdb -U postgres freeworldfirst"
echo ""

read -p "Ist PostgreSQL bereit? (j/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Jj]$ ]]; then
  echo "Migration abgebrochen. Bitte starten Sie PostgreSQL und erstellen Sie die Datenbank."
  exit 1
fi

# Erste Migration erstellen
echo "📦 Erstelle initiale Datenbank-Migration..."
npx prisma migrate dev --name init

# Prisma Client generieren
echo "🔧 Generiere Prisma Client..."
npx prisma generate

echo "✅ Datenbank-Migrationen erfolgreich erstellt!"
echo "🔍 Sie können das Datenbankschema mit 'npx prisma studio' anzeigen."