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

# Projektverzeichnis festlegen
PROJECT_DIR="FreeWorldFirst"

# Prüfen, ob das Projektverzeichnis existiert
if [ ! -d "$PROJECT_DIR" ]; then
  echo -e "${RED}Das FreeWorldFirst-Verzeichnis wurde nicht gefunden.${NC}"
  echo -e "${YELLOW}Bitte führen Sie zuerst das Basisinstallationsskript aus, bevor Sie diese Erweiterung installieren.${NC}"
  exit 1
fi

# Benutzer informieren
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

# Funktion, um häufige Fehler zu beheben
fix_common_issues() {
  echo -e "${YELLOW}Behebe häufige Probleme...${NC}"
  
  # Zum Backend-Verzeichnis wechseln
  cd "$PROJECT_DIR/backend"
  
  # Helmet-Problem beheben
  if grep -q "app.use(helmet())" src/main.ts; then
    echo "Korrigiere Helmet-Aufruf in main.ts"
    sed -i 's/app.use(helmet())/app.use(helmet.default())/' src/main.ts
  fi
  
  # In das übergeordnete Verzeichnis zurückkehren
  cd ../..
}

# Schritt 1: Implementiere Users-Modul (neues Skript)
implement_users_module() {
  echo -e "${YELLOW}Schritt 1/6: Users-Modul implementieren...${NC}"
  
  # Zum Backend-Verzeichnis wechseln
  cd "$PROJECT_DIR/backend"
  
  # Users-Modul Verzeichnisse erstellen
  mkdir -p src/users/dto src/users/entities
  
  # Users-Entity erstellen
  cat > src/users/entities/user.entity.ts << 'EOF'
import { ApiProperty } from '@nestjs/swagger';

export class User {
  @ApiProperty()
  id: string;

  @ApiProperty()
  username: string;

  @ApiProperty()
  email: string;

  @ApiProperty()
  isAdmin: boolean;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}
EOF

  # Users-Modul erstellen
  cat > src/users/users.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { UsersService } from './users.service';

@Module({
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
EOF

  # Users-Service erstellen
  cat > src/users/users.service.ts << 'EOF'
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findByEmail(email: string) {
    return this.prisma.user.findUnique({
      where: { email },
    });
  }

  async findById(id: string) {
    return this.prisma.user.findUnique({
      where: { id },
    });
  }
}
EOF

  # Zurück zum Ausgangsverzeichnis
  cd ../..
  
  echo -e "${GREEN}Users-Modul erfolgreich implementiert!${NC}"
}

# Schritt 2: Implementiere Comments-Modul (neues Skript)
implement_comments_module() {
  echo -e "${YELLOW}Schritt 2/6: Comments-Modul implementieren...${NC}"
  
  # Zum Backend-Verzeichnis wechseln
  cd "$PROJECT_DIR/backend"
  
  # Comments-Modul Verzeichnisse erstellen
  mkdir -p src/comments/dto src/comments/entities
  
  # Comments-Entity erstellen
  cat > src/comments/entities/comment.entity.ts << 'EOF'
import { ApiProperty } from '@nestjs/swagger';

export class Comment {
  @ApiProperty()
  id: string;

  @ApiProperty()
  content: string;

  @ApiProperty()
  userId: string;

  @ApiProperty()
  alternativeId: string;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}
EOF

  # Comments-Modul erstellen
  cat > src/comments/comments.module.ts << 'EOF'
import { Module } from '@nestjs/common';

@Module({
  controllers: [],
  providers: [],
  exports: [],
})
export class CommentsModule {}
EOF

  # Zurück zum Ausgangsverzeichnis
  cd ../..
  
  echo -e "${GREEN}Comments-Modul erfolgreich implementiert!${NC}"
}

# Authentifizierungsmodul im Backend implementieren
implement_auth_backend() {
  echo -e "${YELLOW}Schritt 3/6: Authentifizierungsmodul im Backend implementieren...${NC}"
  
  # Skript ausführen, wenn es existiert
  if [ -f "scripts/implement_auth_backend.sh" ]; then
    bash scripts/implement_auth_backend.sh
  else
    echo -e "${RED}Skript nicht gefunden: scripts/implement_auth_backend.sh${NC}"
    echo -e "${YELLOW}Implementiere Minimal-Version...${NC}"
    
    # Zum Backend-Verzeichnis wechseln
    cd "$PROJECT_DIR/backend"
    
    # JWT Strategy verbessern
    mkdir -p src/auth/strategies
    cat > src/auth/strategies/jwt.strategy.ts << 'EOF'
import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private configService: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_SECRET') || 'fallback-secret',
    });
  }

  async validate(payload: any) {
    return { userId: payload.sub, username: payload.username };
  }
}
EOF

    # Zurück zum Ausgangsverzeichnis
    cd ../..
  fi
  
  echo -e "${GREEN}Authentifizierungsmodul im Backend erfolgreich implementiert!${NC}"
}

# Alternativen-Modul im Backend implementieren
implement_alternatives_backend() {
  echo -e "${YELLOW}Schritt 4/6: Alternativen-Modul im Backend implementieren...${NC}"
  
  # Skript ausführen, wenn es existiert
  if [ -f "scripts/implement_alternatives_backend.sh" ]; then
    bash scripts/implement_alternatives_backend.sh
  else
    echo -e "${RED}Skript nicht gefunden: scripts/implement_alternatives_backend.sh${NC}"
    exit 1
  fi
  
  echo -e "${GREEN}Alternativen-Modul im Backend erfolgreich implementiert!${NC}"
}

# Authentifizierungskomponenten im Frontend implementieren
implement_auth_frontend() {
  echo -e "${YELLOW}Schritt 5/6: Authentifizierungskomponenten im Frontend implementieren...${NC}"
  
  # Skript ausführen, wenn es existiert
  if [ -f "scripts/implement_auth_frontend.sh" ]; then
    bash scripts/implement_auth_frontend.sh
  else
    echo -e "${RED}Skript nicht gefunden: scripts/implement_auth_frontend.sh${NC}"
    exit 1
  fi
  
  echo -e "${GREEN}Authentifizierungskomponenten im Frontend erfolgreich implementiert!${NC}"
}

# Admin-Dashboard implementieren
implement_admin_dashboard() {
  echo -e "${YELLOW}Schritt 6/6: Admin-Dashboard implementieren...${NC}"
  
  # Skript ausführen, wenn es existiert
  if [ -f "scripts/implement_admin_dashboard.sh" ]; then
    bash scripts/implement_admin_dashboard.sh
  else
    echo -e "${RED}Skript nicht gefunden: scripts/implement_admin_dashboard.sh${NC}"
    exit 1
  fi
  
  echo -e "${GREEN}Admin-Dashboard erfolgreich implementiert!${NC}"
}

# Führe alle Implementierungsschritte aus
fix_common_issues
implement_users_module
implement_comments_module
implement_auth_backend
implement_alternatives_backend
implement_auth_frontend
implement_admin_dashboard

# Installation abgeschlossen
echo -e "${BLUE}===================================================${NC}"
echo -e "${BLUE}    Phase 1 Erweiterung abgeschlossen!    ${NC}"
echo -e "${BLUE}===================================================${NC}"
echo ""

# Anleitung für die nächsten Schritte
echo -e "${YELLOW}Nächste Schritte:${NC}"
echo -e "1. Navigieren Sie in das Projektverzeichnis: ${GREEN}cd $PROJECT_DIR${NC}"
echo -e "2. Starten Sie die Entwicklungsumgebung mit Docker: ${GREEN}cd $PROJECT_DIR && ./scripts/start-dev.sh${NC}"
echo -e "3. Öffnen Sie in Ihrem Browser: ${GREEN}http://localhost:3000${NC}"
echo ""
echo -e "${GREEN}Viel Erfolg mit Ihrem FreeWorldFirst Collector Projekt!${NC}"