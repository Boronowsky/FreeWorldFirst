#!/bin/bash
set -e

echo "🔄 Aktualisiere das Hauptinstallationsskript für Phase 1..."

# Aktualisieren des Hauptinstallationsskripts
cat > install_phase1.sh << 'EOF'
#!/bin/bash
set -e

# Farben für die Ausgabe
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}===================================================${NC}"
echo -e "${BLUE}    FreeWorldFirst Collector - Phase 1 Erweiterung   ${NC}"
echo -e "${BLUE}===================================================${NC}"
echo ""

# Verzeichnis für die Skripte erstellen
mkdir -p scripts

# Prüfen, ob alle benötigten Befehle verfügbar sind
echo -e "${YELLOW}Prüfe Systemvoraussetzungen...${NC}"
REQUIRED_COMMANDS=("npm" "node" "git")
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

REQUIRED_SCRIPTS=("implement_auth_backend.sh" "implement_alternatives_backend.sh" "implement_auth_frontend.sh" "implement_alternatives_frontend.sh" "implement_admin_dashboard.sh")
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

# Prüfen, ob das FreeWorldFirst-Verzeichnis existiert
if [ ! -d "FreeWorldFirst" ]; then
  echo -e "${RED}Das FreeWorldFirst-Verzeichnis wurde nicht gefunden.${NC}"
  echo -e "${YELLOW}Bitte führen Sie zuerst das Basisinstallationsskript aus, bevor Sie diese Erweiterung installieren.${NC}"
  exit 1
fi

# Benutzer informieren und Bestätigung einholen
echo -e "${YELLOW}Diese Installation wird folgende Funktionalitäten hinzufügen:${NC}"
echo -e "1. Benutzerauthentifizierung (Registrierung und Anmeldung)"
echo -e "2. Alternativen-Verwaltung (Anzeigen, Erstellen, Bewerten)"
echo -e "3. Admin-Dashboard zur Moderation von Alternativen"
echo -e "4. Navigation und grundlegende UI-Komponenten"
echo ""
echo -e "${YELLOW}Der Prozess kann je nach Internetgeschwindigkeit 5-10 Minuten dauern.${NC}"
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
echo -e "${BLUE}    Start der Phase 1 Erweiterung    ${NC}"
echo -e "${BLUE}===================================================${NC}"
echo ""

# Ausführen der Skripte
echo -e "${YELLOW}Schritt 1/5: Authentifizierungsmodul im Backend implementieren...${NC}"
./scripts/implement_auth_backend.sh
echo -e "${GREEN}Authentifizierungsmodul im Backend erfolgreich implementiert!${NC}"
echo ""

echo -e "${YELLOW}Schritt 2/5: Alternativen-Modul im Backend implementieren...${NC}"
./scripts/implement_alternatives_backend.sh
echo -e "${GREEN}Alternativen-Modul im Backend erfolgreich implementiert!${NC}"
echo ""

echo -e "${YELLOW}Schritt 3/5: Authentifizierungskomponenten im Frontend implementieren...${NC}"
./scripts/implement_auth_frontend.sh
echo -e "${GREEN}Authentifizierungskomponenten im Frontend erfolgreich implementiert!${NC}"
echo ""

echo -e "${YELLOW}Schritt 4/5: Alternativen-Komponenten im Frontend implementieren...${NC}"
./scripts/implement_alternatives_frontend.sh
echo -e "${GREEN}Alternativen-Komponenten im Frontend erfolgreich implementiert!${NC}"
echo ""

echo -e "${YELLOW}Schritt 5/5: Admin-Dashboard implementieren...${NC}"
./scripts/implement_admin_dashboard.sh
echo -e "${GREEN}Admin-Dashboard erfolgreich implementiert!${NC}"
echo ""

# Installation abgeschlossen
echo -e "${BLUE}===================================================${NC}"
echo -e "${BLUE}    Phase 1 Erweiterung abgeschlossen!    ${NC}"
echo -e "${BLUE}===================================================${NC}"
echo ""

# Anleitung für die nächsten Schritte
echo -e "${YELLOW}Nächste Schritte:${NC}"
echo -e "1. Navigieren Sie in das Projektverzeichnis: ${GREEN}cd FreeWorldFirst${NC}"
echo -e "2. Starten Sie die Entwicklungsumgebung: ${GREEN}npm run dev${NC}"
echo -e "3. Öffnen Sie in Ihrem Browser: ${GREEN}http://localhost:3000${NC}"
echo ""
echo -e "Für die vollständige Funktionalität benötigen Sie eine laufende PostgreSQL-Datenbank:"
echo -e "- In der Entwicklungsumgebung können Sie Docker verwenden: ${GREEN}cd FreeWorldFirst && docker-compose -f docker-compose.dev.yml up -d postgres${NC}"
echo -e "- Oder starten Sie die gesamte Umgebung mit Docker: ${GREEN}cd FreeWorldFirst && ./scripts/start-dev.sh${NC}"
echo ""
echo -e "${GREEN}Viel Erfolg mit Ihrem FreeWorldFirst Collector Projekt!${NC}"
EOF

chmod +x install_phase1.sh

echo "✅ Hauptinstallationsskript für Phase 1 erfolgreich aktualisiert!"