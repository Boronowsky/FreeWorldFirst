#!/bin/bash
set -e

echo "🚀 Richte das Frontend mit Next.js, TypeScript und Tailwind CSS ein..."

cd FreeWorldFirst/frontend

# Next.js mit TypeScript initialisieren
npx create-next-app@latest . --typescript --eslint --tailwind --app --no-src-dir --import-alias "@/*"

# Weitere Abhängigkeiten installieren
npm install @tanstack/react-query @tanstack/react-query-devtools
npm install zod react-hook-form @hookform/resolvers
npm install next-auth@beta
npm install next-themes
npm install date-fns
npm install clsx tailwind-merge

# Dev-Abhängigkeiten
npm install --save-dev @types/node @types/react @types/react-dom
npm install --save-dev prettier prettier-plugin-tailwindcss
npm install --save-dev eslint-plugin-react-hooks

# shadcn/ui einrichten
npx shadcn-ui@latest init --yes

# Atom Design Struktur erstellen
mkdir -p components/atoms components/molecules components/organisms components/templates
mkdir -p app/alternatives app/auth app/admin app/profile
mkdir -p lib/hooks lib/utils lib/validators
mkdir -p public/images

# Tailwind CSS Konfiguration aktualisieren
cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ["class"],
  content: [
    './pages/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './app/**/*.{ts,tsx}',
  ],
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      keyframes: {
        "accordion-down": {
          from: { height: 0 },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: 0 },
        },
      },
      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
}
EOF

# Erstellen von Utility-Dateien
cat > lib/utils.ts << 'EOF'
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatDate(date: Date | string): string {
  if (typeof date === "string") {
    date = new Date(date);
  }
  return new Intl.DateTimeFormat("de-DE", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  }).format(date);
}
EOF

# Layout-Datei aktualisieren
cat > app/layout.tsx << 'EOF'
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { ThemeProvider } from "@/components/theme-provider";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "FreeWorldFirst Collector",
  description: "Plattform für ethische Alternativen zu BigTech-Produkten und -Diensten",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="de" suppressHydrationWarning>
      <body className={inter.className}>
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          {children}
        </ThemeProvider>
      </body>
    </html>
  );
}
EOF

# Theme Provider für Dark Mode
mkdir -p components
cat > components/theme-provider.tsx << 'EOF'
"use client";

import * as React from "react";
import { ThemeProvider as NextThemesProvider } from "next-themes";
import { type ThemeProviderProps } from "next-themes/dist/types";

export function ThemeProvider({ children, ...props }: ThemeProviderProps) {
  return <NextThemesProvider {...props}>{children}</NextThemesProvider>;
}
EOF

# .gitignore aktualisieren
echo ".env*.local" >> .gitignore
echo "node_modules/" >> .gitignore
echo ".next/" >> .gitignore

# Startseite erstellen
cat > app/page.tsx << 'EOF'
import Link from "next/link";

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <h1 className="mb-4 text-4xl font-bold">FreeWorldFirst Collector</h1>
      <p className="mb-8 text-center text-xl">
        Entdecke ethische Alternativen zu BigTech-Produkten und -Diensten
      </p>
      <div className="flex gap-4">
        <Link
          href="/alternatives"
          className="rounded-md bg-blue-600 px-4 py-2 text-white hover:bg-blue-700"
        >
          Alternativen durchsuchen
        </Link>
        <Link
          href="/auth/login"
          className="rounded-md border border-blue-600 px-4 py-2 text-blue-600 hover:bg-blue-50"
        >
          Anmelden
        </Link>
      </div>
    </main>
  );
}
EOF

# Installieren von notwendigen shadcn/ui-Komponenten
npx shadcn-ui@latest add button
npx shadcn-ui@latest add card
npx shadcn-ui@latest add form
npx shadcn-ui@latest add input

echo "✅ Frontend-Setup erfolgreich abgeschlossen!"