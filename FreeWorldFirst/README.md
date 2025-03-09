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

## CI/CD mit GitHub Actions

Dieses Projekt verwendet GitHub Actions für kontinuierliche Integration und kontinuierliches Deployment. Um die Workflows vollständig zu nutzen, müssen folgende Secrets in den GitHub Repository-Einstellungen konfiguriert werden:

- `DOCKERHUB_USERNAME`: Dein Docker Hub Benutzername
- `DOCKERHUB_TOKEN`: Dein Docker Hub Access Token
- `SSH_HOST`: Hostname oder IP-Adresse deines Produktionsservers
- `SSH_USERNAME`: SSH-Benutzername für den Produktionsserver
- `SSH_PRIVATE_KEY`: SSH-Private-Key für die Authentifizierung
- `SNYK_TOKEN`: (Optional) API-Token für Snyk-Sicherheitsanalysen

Diese Secrets werden für das automatische Bauen und Bereitstellen der Anwendung verwendet, wenn Code in den main-Branch gemergt wird.
