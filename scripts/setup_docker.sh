#!/bin/bash
set -e

echo "🚀 Erstelle Docker-Konfiguration für das Projekt..."

cd FreeWorldFirst

# Dockerfile für Frontend erstellen
cat > frontend/Dockerfile << 'EOF'
FROM node:20-alpine AS base

# Install dependencies only when needed
FROM base AS deps
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Next.js collects completely anonymous telemetry data about general usage.
# Learn more here: https://nextjs.org/telemetry
# Uncomment the following line in case you want to disable telemetry during the build.
ENV NEXT_TELEMETRY_DISABLED 1

RUN npm run build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]
EOF

# Dockerfile für Backend erstellen
cat > backend/Dockerfile << 'EOF'
FROM node:20-alpine AS development

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build

FROM node:20-alpine AS production

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci --only=production

COPY --from=development /usr/src/app/dist ./dist
COPY --from=development /usr/src/app/prisma ./prisma

RUN npx prisma generate

EXPOSE 3001

CMD ["node", "dist/main"]
EOF

# Docker Compose für Entwicklung erstellen
cat > docker-compose.dev.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: freeworldfirst
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - freeworldfirst-network

  backend:
    build:
      context: ./backend
      target: development
    volumes:
      - ./backend:/usr/src/app
      - /usr/src/app/node_modules
    ports:
      - "3001:3001"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/freeworldfirst?schema=public
      - JWT_SECRET=dev-secret-key
      - PORT=3001
      - FRONTEND_URL=http://localhost:3000
    depends_on:
      - postgres
    command: npm run start:dev
    networks:
      - freeworldfirst-network

  frontend:
    build:
      context: ./frontend
      target: deps
    volumes:
      - ./frontend:/app
      - /app/node_modules
      - /app/.next
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - NEXT_PUBLIC_API_URL=http://localhost:3001
    command: npm run dev
    networks:
      - freeworldfirst-network
    depends_on:
      - backend

networks:
  freeworldfirst-network:

volumes:
  postgres-data:
EOF

# Docker Compose für Produktion erstellen
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    restart: always
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-postgres}
      POSTGRES_DB: ${POSTGRES_DB:-freeworldfirst}
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - freeworldfirst-network
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    build:
      context: ./backend
      target: production
    restart: always
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://${POSTGRES_USER:-postgres}:${POSTGRES_PASSWORD:-postgres}@postgres:5432/${POSTGRES_DB:-freeworldfirst}?schema=public
      - JWT_SECRET=${JWT_SECRET}
      - PORT=3001
      - FRONTEND_URL=${FRONTEND_URL:-http://localhost:3000}
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - freeworldfirst-network

  frontend:
    build:
      context: ./frontend
    restart: always
    environment:
      - NODE_ENV=production
      - NEXT_PUBLIC_API_URL=${API_URL:-http://localhost:3001}
    depends_on:
      - backend
    networks:
      - freeworldfirst-network

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf:/etc/nginx/conf.d
      - ./nginx/certbot/conf:/etc/letsencrypt
      - ./nginx/certbot/www:/var/www/certbot
    depends_on:
      - frontend
      - backend
    networks:
      - freeworldfirst-network

  certbot:
    image: certbot/certbot
    volumes:
      - ./nginx/certbot/conf:/etc/letsencrypt
      - ./nginx/certbot/www:/var/www/certbot
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'"

networks:
  freeworldfirst-network:

volumes:
  postgres-data:
EOF

# Nginx-Konfiguration für SSL erstellen
mkdir -p nginx/conf

cat > nginx/conf/app.conf << 'EOF'
server {
    listen 80;
    server_name example.com www.example.com;
    server_tokens off;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name example.com www.example.com;
    server_tokens off;

    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://frontend:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /api {
        proxy_pass http://backend:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# .dockerignore Dateien erstellen
cat > frontend/.dockerignore << 'EOF'
node_modules
.next
.git
.gitignore
.env
.env.local
.env.development
.env.production
README.md
EOF

cat > backend/.dockerignore << 'EOF'
node_modules
dist
.git
.gitignore
.env
.env.development
.env.production
README.md
EOF

# Erstellen eines Docker-Start-Skripts für Entwicklung
cat > scripts/start-dev.sh << 'EOF'
#!/bin/bash

echo "🚀 Starte FreeWorldFirst Collector in der Entwicklungsumgebung..."
docker-compose -f docker-compose.dev.yml up --build
EOF

chmod +x scripts/start-dev.sh

# Erstellen eines Docker-Start-Skripts für Produktion
cat > scripts/start-prod.sh << 'EOF'
#!/bin/bash

echo "🚀 Starte FreeWorldFirst Collector in der Produktionsumgebung..."
docker-compose up -d --build
EOF

chmod +x scripts/start-prod.sh

echo "✅ Docker-Konfiguration erfolgreich erstellt!"