#!/bin/bash
set -e

# Farben für die Ausgabe
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}===================================================${NC}"
echo -e "${BLUE}    FreeWorldFirst Collector - Installations-Tool   ${NC}"
echo -e "${BLUE}===================================================${NC}"
echo ""

# Verzeichnis für die Skripte erstellen
mkdir -p scripts

# Prüfen, ob alle benötigten Befehle verfügbar sind
echo -e "${YELLOW}Prüfe Systemvoraussetzungen...${NC}"
REQUIRED_COMMANDS=("npm" "node" "git" "docker" "docker-compose")
MISSING_COMMANDS=()

for cmd in "${REQUIRED_COMMANDS[@]}"; do
  if ! command -v $cmd &> /dev/null; then
    MISSING_COMMANDS+=($cmd)
  fi
done

if [ ${#MISSING_COMMANDS[@]} -ne 0 ]; then
  echo -e "${RED}Folgende erforderliche Programme sind nicht installiert:${NC}"
  for cmd in "${MISSING_COMMANDS[@]}"; do
    echo -e "${RED}- $cmd${NC}"
  done
  echo -e "${YELLOW}Bitte installieren Sie diese Programme und starten Sie das Skript erneut.${NC}"
  exit 1
fi

echo -e "${GREEN}Alle Systemvoraussetzungen erfüllt!${NC}"
echo ""

# Skripte in das Skript-Verzeichnis kopieren
echo -e "${YELLOW}Kopiere Installationsskripte...${NC}"

# Hier sollten die Benutzer die Skripte in das scripts-Verzeichnis kopieren
# Wir überprüfen, ob sie existieren

REQUIRED_SCRIPTS=("setup_project.sh" "setup_frontend.sh" "setup_backend.sh" "setup_docker.sh" "setup_github_actions.sh")
MISSING_SCRIPTS=()

for script in "${REQUIRED_SCRIPTS[@]}"; do
  if [ ! -f "scripts/$script" ]; then
    MISSING_SCRIPTS+=($script)
  else
    chmod +x "scripts/$script"
  fi
done

if [ ${#MISSING_SCRIPTS[@]} -ne 0 ]; then
  echo -e "${RED}Folgende Skripte fehlen im scripts/-Verzeichnis:${NC}"
  for script in "${MISSING_SCRIPTS[@]}"; do
    echo -e "${RED}- $script${NC}"
  done
  echo -e "${YELLOW}Bitte kopieren Sie diese Skripte in das scripts/-Verzeichnis und starten Sie das Installationsskript erneut.${NC}"
  exit 1
fi

echo -e "${GREEN}Alle Skripte gefunden!${NC}"
echo ""

# Benutzer informieren und Bestätigung einholen
echo -e "${YELLOW}Diese Installation wird folgende Schritte ausführen:${NC}"
echo -e "1. Projektstruktur erstellen"
echo -e "2. Frontend mit Next.js, TypeScript und Tailwind CSS einrichten"
echo -e "3. Backend mit NestJS, TypeScript und Prisma einrichten"
echo -e "4. Docker-Konfiguration für Entwicklung und Produktion erstellen"
echo -e "5. GitHub Actions CI/CD-Workflows erstellen"
echo ""
echo -e "${YELLOW}Der Prozess kann je nach Internetgeschwindigkeit 10-15 Minuten dauern.${NC}"
echo ""
read -p "Möchten Sie fortfahren? (j/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Jj]$ ]]; then
  echo -e "${RED}Installation abgebrochen.${NC}"
  exit 1
fi

echo ""

# Beginn der Installation
echo -e "${BLUE}===================================================${NC}"
echo -e "${BLUE}    Start der Installation    ${NC}"
echo -e "${BLUE}===================================================${NC}"
echo ""

# Ausführen der Skripte
echo -e "${YELLOW}Schritt 1/5: Projektstruktur erstellen...${NC}"
./scripts/setup_project.sh
echo -e "${GREEN}Projektstruktur erfolgreich erstellt!${NC}"
echo ""

echo -e "${YELLOW}Schritt 2/5: Frontend einrichten...${NC}"
./scripts/setup_frontend.sh
echo -e "${GREEN}Frontend erfolgreich eingerichtet!${NC}"
echo ""

echo -e "${YELLOW}Schritt 3/5: Backend einrichten...${NC}"
./scripts/setup_backend.sh
echo -e "${GREEN}Backend erfolgreich eingerichtet!${NC}"
echo ""

echo -e "${YELLOW}Schritt 4/5: Docker-Konfiguration erstellen...${NC}"
./scripts/setup_docker.sh
echo -e "${GREEN}Docker-Konfiguration erfolgreich erstellt!${NC}"
echo ""

echo -e "${YELLOW}Schritt 5/5: GitHub Actions CI/CD-Workflows erstellen...${NC}"
./scripts/setup_github_actions.sh
echo -e "${GREEN}GitHub Actions CI/CD-Workflows erfolgreich erstellt!${NC}"
echo ""

# Installation abgeschlossen
echo -e "${BLUE}===================================================${NC}"
echo -e "${BLUE}    Installation abgeschlossen!    ${NC}"
echo -e "${BLUE}===================================================${NC}"
echo ""

# Anleitung für die nächsten Schritte
echo -e "${YELLOW}Nächste Schritte:${NC}"
echo -e "1. Navigieren Sie in das Projektverzeichnis: ${GREEN}cd FreeWorldFirst${NC}"
echo -e "2. Starten Sie die Entwicklungsumgebung mit Docker: ${GREEN}./scripts/start-dev.sh${NC}"
echo -e "3. Öffnen Sie in Ihrem Browser: ${GREEN}http://localhost:3000${NC}"
echo ""
echo -e "Für die Produktionsumgebung:"
echo -e "1. Passen Sie die Umgebungsvariablen in einer .env-Datei an"
echo -e "2. Starten Sie die Produktionsumgebung: ${GREEN}./scripts/start-prod.sh${NC}"
echo ""
echo -e "Denken Sie daran, die GitHub-Repository-Secrets einzurichten, wenn Sie GitHub Actions verwenden möchten."
echo ""
echo -e "${GREEN}Viel Erfolg mit Ihrem FreeWorldFirst Collector Projekt!${NC}"