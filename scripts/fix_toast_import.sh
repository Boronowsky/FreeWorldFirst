#!/bin/bash
set -e

echo "🔧 Behebe Toast-Import-Problem..."

cd ~/fwf-arlernativesDB_V2/FreeWorldFirst_Installation/FreeWorldFirst/frontend

# Erstellen eines Re-Export-Moduls für Kompatibilität
mkdir -p components/ui
cat > components/ui/use-toast.ts << 'EOF'
// Re-Export von der neuen Struktur für Kompatibilität
export { useToast } from './toast';
EOF

echo "✅ Toast-Import-Problem erfolgreich behoben!"
