#!/bin/bash
set -e

echo "🛠 Erstelle direkte UI-Komponenten statt shadcn/ui..."

cd ~/fwf-arlernativesDB_V2/FreeWorldFirst_Installation/FreeWorldFirst/frontend

# Erstelle notwendige Verzeichnisse
mkdir -p components/ui

# Button-Komponente erstellen
cat > components/ui/button.tsx << 'EOF'
"use client";

import * as React from "react";

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "default" | "outline" | "ghost" | "destructive";
  size?: "default" | "sm" | "lg";
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className = "", variant = "default", size = "default", children, disabled, ...props }, ref) => {
    const variantClasses = {
      default: "bg-blue-600 text-white hover:bg-blue-700",
      outline: "border border-blue-600 text-blue-600 hover:bg-blue-50",
      ghost: "hover:bg-gray-100",
      destructive: "bg-red-600 text-white hover:bg-red-700",
    };
    
    const sizeClasses = {
      default: "py-2 px-4 text-sm",
      sm: "py-1 px-3 text-xs",
      lg: "py-3 px-6 text-base",
    };
    
    return (
      <button
        className={`inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-400 disabled:opacity-50 disabled:pointer-events-none ${variantClasses[variant]} ${sizeClasses[size]} ${className}`}
        ref={ref}
        disabled={disabled}
        {...props}
      >
        {children}
      </button>
    );
  }
);

Button.displayName = "Button";
EOF

# Card-Komponenten erstellen
cat > components/ui/card.tsx << 'EOF'
import * as React from "react";

export function Card({ className = "", ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={`rounded-lg border bg-card text-card-foreground shadow-sm ${className}`}
      {...props}
    />
  );
}

export function CardHeader({ className = "", ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={`flex flex-col space-y-1.5 p-6 ${className}`} {...props} />;
}

export function CardTitle({ className = "", ...props }: React.HTMLAttributes<HTMLHeadingElement>) {
  return (
    <h3 className={`text-lg font-semibold leading-none tracking-tight ${className}`} {...props} />
  );
}

export function CardDescription({ className = "", ...props }: React.HTMLAttributes<HTMLParagraphElement>) {
  return <p className={`text-sm text-muted-foreground ${className}`} {...props} />;
}

export function CardContent({ className = "", ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={`p-6 pt-0 ${className}`} {...props} />;
}

export function CardFooter({ className = "", ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div className={`flex items-center p-6 pt-0 ${className}`} {...props} />
  );
}
EOF

# Input Komponente erstellen
cat > components/ui/input.tsx << 'EOF'
import * as React from "react";

export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {}

export const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className = "", type, ...props }, ref) => {
    return (
      <input
        type={type}
        className={`flex h-10 w-full rounded-md border border-input bg-transparent px-3 py-2 text-sm placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-blue-400 disabled:cursor-not-allowed disabled:opacity-50 ${className}`}
        ref={ref}
        {...props}
      />
    );
  }
);

Input.displayName = "Input";
EOF

# Einfaches Toast-System erstellen
mkdir -p components/ui/toast

cat > components/ui/toast.tsx << 'EOF'
"use client";

import * as React from "react";

interface ToastProps {
  title?: string;
  description?: string;
  variant?: "default" | "destructive";
}

interface ToastContextType {
  toast: (props: ToastProps) => void;
}

const ToastContext = React.createContext<ToastContextType | undefined>(undefined);

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [toasts, setToasts] = React.useState<(ToastProps & { id: string })[]>([]);

  const toast = React.useCallback((props: ToastProps) => {
    const id = Math.random().toString(36).substring(2, 9);
    setToasts((prev) => [...prev, { ...props, id }]);
    
    // Auto-dismiss nach 5 Sekunden
    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, 5000);
  }, []);

  return (
    <ToastContext.Provider value={{ toast }}>
      {children}
      <div className="fixed bottom-0 right-0 z-50 p-4 space-y-4 w-full max-w-sm">
        {toasts.map((t) => (
          <div 
            key={t.id} 
            className={`rounded-lg border p-4 shadow-md ${
              t.variant === "destructive" ? "bg-red-50 border-red-200" : "bg-white border-gray-200"
            }`}
          >
            {t.title && <h5 className="font-medium">{t.title}</h5>}
            {t.description && <p className="text-sm text-gray-500">{t.description}</p>}
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  );
}

export function useToast() {
  const context = React.useContext(ToastContext);
  if (!context) {
    throw new Error("useToast must be used within a ToastProvider");
  }
  return context;
}

export const Toaster = () => null; // Placeholder für Kompatibilität
EOF

# Form-Komponenten erstellen (vereinfacht)
mkdir -p components/ui/form

cat > components/ui/form.tsx << 'EOF'
"use client";

import * as React from "react";

export const Form = ({ ...props }) => <form {...props} />;
export const FormItem = ({ className = "", ...props }) => <div className={`space-y-2 ${className}`} {...props} />;
export const FormLabel = ({ className = "", ...props }) => <label className={`text-sm font-medium ${className}`} {...props} />;
export const FormControl = ({ ...props }) => <div className="mt-1" {...props} />;
export const FormDescription = ({ className = "", ...props }) => <p className={`text-xs text-gray-500 ${className}`} {...props} />;
export const FormMessage = ({ className = "", children, ...props }) => 
  children ? <p className={`text-sm text-red-500 mt-1 ${className}`} {...props}>{children}</p> : null;
EOF

# Aktualisiere das Layout, um statt shadcn den Tailwind-Stil zu verwenden
cat >> app/globals.css << 'EOF'
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
    --primary: 221.2 83.2% 53.3%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96.1%;
    --secondary-foreground: 222.2 47.4% 11.2%;
    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96.1%;
    --accent-foreground: 222.2 47.4% 11.2%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 221.2 83.2% 53.3%;
    --radius: 0.5rem;
  }
 
  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;
    --primary: 217.2 91.2% 59.8%;
    --primary-foreground: 222.2 47.4% 11.2%;
    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;
    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 224.3 76.3% 48%;
  }
}
EOF

# Einfachen Ersatz für die Navbar erstellen, der keine komplexen Abhängigkeiten hat
cat > components/organisms/navbar.tsx << 'EOF'
"use client";

import { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Button } from "@/components/ui/button";

export function Navbar() {
  const pathname = usePathname();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  // Simulieren, dass wir noch nicht angemeldet sind
  const isAuthenticated = false; 
  const isAdmin = false;

  const routes = [
    { name: "Startseite", path: "/" },
    { name: "Alternativen", path: "/alternatives" },
  ];

  const isActive = (path: string) => {
    if (path === "/") {
      return pathname === path;
    }
    return pathname.startsWith(path);
  };

  return (
    <header className="border-b bg-background">
      <div className="container flex h-16 items-center justify-between px-4">
        <div className="flex items-center">
          <Link href="/" className="font-bold text-lg">
            FreeWorldFirst
          </Link>
          <nav className="hidden md:flex ml-6 space-x-4">
            {routes.map((route) => (
              <Link
                key={route.path}
                href={route.path}
                className={`px-3 py-2 rounded-md text-sm font-medium ${
                  isActive(route.path)
                    ? "bg-primary/10 text-primary"
                    : "text-muted-foreground hover:bg-accent hover:text-accent-foreground"
                }`}
              >
                {route.name}
              </Link>
            ))}
          </nav>
        </div>

        <div className="flex items-center">
          {isAuthenticated ? (
            <div className="relative">
              <Button variant="outline" className="font-medium">
                Benutzer
              </Button>
              {/* Vereinfachtes Dropdown */}
            </div>
          ) : (
            <div className="flex space-x-2">
              <Link href="/auth/login">
                <Button variant="ghost">Anmelden</Button>
              </Link>
              <Link href="/auth/register">
                <Button>Registrieren</Button>
              </Link>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
EOF

# Layoutdatei anpassen, um die ToastProvider zu inkludieren
cat > app/layout.tsx << 'EOF'
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { ThemeProvider } from "@/components/theme-provider";
import { ToastProvider } from "@/components/ui/toast";
import { Navbar } from "@/components/organisms/navbar";

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
          <ToastProvider>
            <div className="flex min-h-screen flex-col">
              <Navbar />
              <main className="flex-1">
                {children}
              </main>
              <footer className="border-t py-6 md:py-0">
                <div className="container flex flex-col items-center justify-between gap-4 md:h-16 md:flex-row">
                  <p className="text-sm text-muted-foreground">
                    &copy; {new Date().getFullYear()} FreeWorldFirst Collector. Alle Rechte vorbehalten.
                  </p>
                </div>
              </footer>
            </div>
          </ToastProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
EOF

echo "✅ UI-Komponenten erfolgreich eingebettet!"
