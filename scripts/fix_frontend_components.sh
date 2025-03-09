#!/bin/bash
set -e

echo "🎨 Installiere fehlende UI-Komponenten im Frontend..."

cd ~/fwf-arlernativesDB_V2/FreeWorldFirst_Installation/FreeWorldFirst/frontend

# Zuerst shadcn/ui initialisieren, falls es noch nicht initialisiert wurde
npx shadcn-ui@latest init --yes

# Die benötigten UI-Komponenten installieren
echo "Installiere Button-Komponente..."
npx shadcn-ui@latest add button

echo "Installiere Card-Komponente..."
npx shadcn-ui@latest add card

echo "Installiere Form-Komponente..."
npx shadcn-ui@latest add form

echo "Installiere Input-Komponente..."
npx shadcn-ui@latest add input

echo "Installiere Textarea-Komponente..."
npx shadcn-ui@latest add textarea

echo "Installiere Select-Komponente..."
npx shadcn-ui@latest add select

echo "Installiere Dropdown-Menu-Komponente..."
npx shadcn-ui@latest add dropdown-menu

echo "Installiere Tabs-Komponente..."
npx shadcn-ui@latest add tabs

echo "Installiere Toast-Komponente..."
npx shadcn-ui@latest add toast

echo "✅ UI-Komponenten erfolgreich installiert!"
