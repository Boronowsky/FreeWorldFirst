#!/bin/bash

echo "🚀 Starte FreeWorldFirst Collector in der Entwicklungsumgebung..."
cd ..  # Ein Verzeichnis nach oben wechseln zum Projektroot
docker-compose -f docker-compose.dev.yml up --build
