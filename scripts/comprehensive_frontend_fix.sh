#!/bin/bash
set -e

echo "🚀 Erstelle umfassendes Frontend-Fix für das Gesamtsystem..."

cd ~/fwf-arlernativesDB_V2/FreeWorldFirst_Installation/FreeWorldFirst/frontend

# Mock-Daten für Alternativen
mkdir -p lib/mock-data
cat > lib/mock-data/alternatives.ts << 'EOF'
export const mockAlternatives = [
  {
    id: "1",
    title: "Signal",
    replaces: "WhatsApp",
    description: "Signal ist ein sicherer Messenger mit Ende-zu-Ende-Verschlüsselung. Die App bietet alle wichtigen Funktionen wie Gruppenchats, Sprachanrufe und Videotelefonie, ohne dass Ihre Daten für Werbung verwendet werden.",
    reasons: "WhatsApp gehört zu Meta (Facebook) und teilt Metadaten für Werbezwecke. Die Privatsphäre der Nutzer ist nicht der Fokus des Unternehmens.",
    benefits: "Vollständige Ende-zu-Ende-Verschlüsselung, Open-Source, keine Werbung, keine Datensammlung, selbstlöschende Nachrichten und moderne Oberfläche.",
    website: "https://signal.org",
    category: "Kommunikation",
    upvotes: 120,
    approved: true,
    submitterId: "1",
    submitter: { id: "1", username: "datenschutz_fan" },
    createdAt: "2024-10-02T14:35:00Z",
    updatedAt: "2024-10-02T14:35:00Z",
    comments: []
  },
  {
    id: "2",
    title: "ProtonMail",
    replaces: "Gmail",
    description: "ProtonMail ist ein Ende-zu-Ende-verschlüsselter E-Mail-Dienst aus der Schweiz. Ihre E-Mails können auf dem Server nicht gelesen werden, da sie verschlüsselt gespeichert werden.",
    reasons: "Google scannt E-Mails für Werbezwecke und sammelt umfangreiche Nutzerdaten. Die Privatsphäre ist nicht gewährleistet.",
    benefits: "Verschlüsselung, keine Werbung, kein E-Mail-Scanning, Schweizer Datenschutz, freies Basiskonto verfügbar.",
    website: "https://proton.me/mail",
    category: "E-Mail",
    upvotes: 97,
    approved: true,
    submitterId: "2",
    submitter: { id: "2", username: "sicherheit_zuerst" },
    createdAt: "2024-10-01T09:22:00Z",
    updatedAt: "2024-10-01T09:22:00Z",
    comments: []
  },
  {
    id: "3",
    title: "DuckDuckGo",
    replaces: "Google",
    description: "DuckDuckGo ist eine Suchmaschine, die keine Benutzer trackt. Sie speichert Ihre Suchhistorie nicht und erstellt kein Nutzerprofil von Ihnen.",
    reasons: "Google sammelt umfangreiche Daten über Nutzer, um personalisierte Werbung zu schalten und Profile zu erstellen.",
    benefits: "Keine Verfolgung, keine Filterblasen, keine personalisierte Werbung, gleiche Suchergebnisse für alle Nutzer.",
    website: "https://duckduckgo.com",
    category: "Suche",
    upvotes: 145,
    approved: true,
    submitterId: "1",
    submitter: { id: "1", username: "datenschutz_fan" },
    createdAt: "2024-09-22T18:45:00Z",
    updatedAt: "2024-09-22T18:45:00Z",
    comments: []
  },
  {
    id: "4",
    title: "Firefox",
    replaces: "Google Chrome",
    description: "Firefox ist ein Open-Source-Browser, der von der gemeinnützigen Mozilla Foundation entwickelt wird. Er bietet starke Privatsphäre-Einstellungen und Tracking-Schutz.",
    reasons: "Chrome sammelt Nutzerdaten für Google und schränkt mit seiner Marktmacht die Web-Standards ein.",
    benefits: "Open-Source, Privatsphäre-Fokus, unabhängige Entwicklung, große Erweiterungsauswahl, geringerer Ressourcenverbrauch.",
    website: "https://www.mozilla.org/firefox",
    category: "Browser",
    upvotes: 88,
    approved: true,
    submitterId: "3",
    submitter: { id: "3", username: "web_freiheit" },
    createdAt: "2024-09-18T11:20:00Z",
    updatedAt: "2024-09-18T11:20:00Z",
    comments: []
  }
];

export const pendingAlternatives = [
  {
    id: "5",
    title: "Jitsi Meet",
    replaces: "Zoom",
    description: "Jitsi Meet ist eine kostenlose Open-Source-Videokonferenzlösung, die direkt im Browser ohne Installation funktioniert.",
    reasons: "Zoom hatte in der Vergangenheit mehrere Datenschutz- und Sicherheitsprobleme.",
    benefits: "Open-Source, keine Registrierung nötig, Ende-zu-Ende-Verschlüsselung, keine Zeitbegrenzung, hohe Qualität.",
    website: "https://meet.jit.si",
    category: "Kommunikation",
    upvotes: 0,
    approved: false,
    submitterId: "2",
    submitter: { id: "2", username: "sicherheit_zuerst" },
    createdAt: "2024-10-05T16:30:00Z",
    updatedAt: "2024-10-05T16:30:00Z",
    comments: []
  }
];

// Hilfsfunktion zum Abrufen einer Alternative nach ID
export function getAlternativeById(id: string) {
  return mockAlternatives.find(alt => alt.id === id) || 
         pendingAlternatives.find(alt => alt.id === id);
}
EOF

# Aktualisierter AuthProvider mit vollständiger Mock-Funktionalität
cat > contexts/auth-context.tsx << 'EOF'
"use client";

import React, { createContext, useContext, useState, useEffect } from "react";
import { useRouter } from "next/navigation";

interface User {
  id: string;
  username: string;
  email: string;
  isAdmin: boolean;
  createdAt: string;
}

interface AuthContextType {
  user: User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (username: string, email: string, password: string) => Promise<void>;
  logout: () => void;
  isAuthenticated: boolean;
  isAdmin: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

// Mock-Benutzer für Demo-Zwecke
const MOCK_USERS = [
  {
    id: "admin",
    username: "admin",
    email: "admin@example.com",
    password: "password123",
    isAdmin: true,
    createdAt: "2024-09-01T10:00:00Z"
  },
  {
    id: "user",
    username: "benutzer",
    email: "benutzer@example.com",
    password: "password123",
    isAdmin: false,
    createdAt: "2024-09-15T14:30:00Z"
  }
];

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();

  // Bei Laden versuchen, Benutzer aus dem localStorage zu holen
  useEffect(() => {
    const storedUser = localStorage.getItem("user");
    if (storedUser) {
      try {
        setUser(JSON.parse(storedUser));
      } catch (e) {
        localStorage.removeItem("user");
      }
    }
    setLoading(false);
  }, []);

  const login = async (email: string, password: string) => {
    setLoading(true);
    try {
      // Simuliere API-Aufruf mit Verzögerung
      await new Promise(resolve => setTimeout(resolve, 800));
      
      // Finde den Benutzer in den Mock-Daten
      const foundUser = MOCK_USERS.find(u => u.email === email);
      
      if (foundUser && foundUser.password === password) {
        // Passwort aus dem Objekt entfernen, bevor wir es speichern
        const { password: _, ...userWithoutPassword } = foundUser;
        setUser(userWithoutPassword);
        localStorage.setItem("user", JSON.stringify(userWithoutPassword));
      } else {
        throw new Error("Ungültige Anmeldedaten");
      }
    } catch (error) {
      console.error("Login-Fehler:", error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  const register = async (username: string, email: string, password: string) => {
    setLoading(true);
    try {
      // Simuliere API-Aufruf mit Verzögerung
      await new Promise(resolve => setTimeout(resolve, 800));
      
      // Prüfe, ob E-Mail oder Benutzername bereits existieren
      if (MOCK_USERS.some(u => u.email === email)) {
        throw new Error("Diese E-Mail-Adresse wird bereits verwendet");
      }
      
      if (MOCK_USERS.some(u => u.username === username)) {
        throw new Error("Dieser Benutzername wird bereits verwendet");
      }
      
      // Erstelle neuen Benutzer
      const newUser = {
        id: Math.random().toString(36).substring(2, 9),
        username,
        email,
        isAdmin: false,
        createdAt: new Date().toISOString()
      };
      
      setUser(newUser);
      localStorage.setItem("user", JSON.stringify(newUser));
    } catch (error) {
      console.error("Registrierungs-Fehler:", error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  const logout = () => {
    localStorage.removeItem("user");
    setUser(null);
    router.push("/");
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        loading,
        login,
        register,
        logout,
        isAuthenticated: !!user,
        isAdmin: user?.isAdmin || false,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth muss innerhalb eines AuthProviders verwendet werden");
  }
  return context;
};
EOF

# Vereinfachter QueryClientProvider mit Mock-Funktionen
cat > components/query-client-provider.tsx << 'EOF'
"use client";

import React, { createContext, useContext } from "react";
import { mockAlternatives, pendingAlternatives, getAlternativeById } from "@/lib/mock-data/alternatives";

interface QueryResult<T> {
  data: T | undefined;
  isLoading: boolean;
  error: Error | null;
}

interface QueryContextType {
  useQuery: <T>(options: { queryKey: any[], queryFn: () => T | Promise<T> }) => QueryResult<T>;
  useMutation: <TData, TVariables>(options: {
    mutationFn: (variables: TVariables) => Promise<TData>,
    onSuccess?: (data: TData) => void,
    onError?: (error: Error) => void
  }) => {
    mutate: (variables: TVariables) => Promise<TData>,
    isPending: boolean
  };
  invalidateQueries: (options: { queryKey: any[] }) => void;
}

const QueryContext = createContext<QueryContextType | undefined>(undefined);

// Ein einfacher Cache für Mock-Daten
const dataCache: Record<string, any> = {
  alternatives: mockAlternatives,
  pendingAlternatives: pendingAlternatives
};

export function QueryClientProvider({ children }: { children: React.ReactNode }) {
  // Vereinfachte useQuery-Implementierung
  const useQuery = <T,>({ queryKey, queryFn }: { queryKey: any[], queryFn: () => T | Promise<T> }): QueryResult<T> => {
    const [key] = queryKey;
    
    // Für bestimmte Query-Keys verwenden wir vordefinierte Daten
    if (key === "alternatives") {
      return { data: dataCache.alternatives as T, isLoading: false, error: null };
    }
    
    if (key === "pendingAlternatives") {
      return { data: dataCache.pendingAlternatives as T, isLoading: false, error: null };
    }
    
    if (key === "alternative") {
      const id = queryKey[1];
      const alternative = getAlternativeById(id);
      return { data: alternative as T, isLoading: false, error: null };
    }
    
    // Fallback: Ergebnis der queryFn zurückgeben
    try {
      return { data: queryFn() as T, isLoading: false, error: null };
    } catch (err) {
      return { data: undefined, isLoading: false, error: err as Error };
    }
  };

  // Vereinfachte useMutation-Implementierung
  const useMutation = <TData, TVariables>({ 
    mutationFn, 
    onSuccess, 
    onError 
  }: {
    mutationFn: (variables: TVariables) => Promise<TData>,
    onSuccess?: (data: TData) => void,
    onError?: (error: Error) => void
  }) => {
    const mutate = async (variables: TVariables) => {
      try {
        const result = await mutationFn(variables);
        onSuccess?.(result);
        return result;
      } catch (err) {
        const error = err as Error;
        onError?.(error);
        throw error;
      }
    };

    return { mutate, isPending: false };
  };

  // Vereinfachte invalidateQueries-Implementierung
  const invalidateQueries = () => {
    // In dieser Mockversion machen wir nichts
  };

  return (
    <QueryContext.Provider value={{ useQuery, useMutation, invalidateQueries }}>
      {children}
    </QueryContext.Provider>
  );
}

// Hook für den Zugriff auf den QueryClient
export function useQueryClient() {
  const context = useContext(QueryContext);
  if (!context) {
    throw new Error("useQueryClient muss innerhalb eines QueryClientProviders verwendet werden");
  }
  return context;
}
EOF

# Aktualisiertes Layout, um beide Provider zu inkludieren
cat > app/layout.tsx << 'EOF'
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { ThemeProvider } from "@/components/theme-provider";
import { ToastProvider } from "@/components/ui/toast";
import { Navbar } from "@/components/organisms/navbar";
import { QueryClientProvider } from "@/components/query-client-provider";
import { AuthProvider } from "@/contexts/auth-context";

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
          <QueryClientProvider>
            <AuthProvider>
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
            </AuthProvider>
          </QueryClientProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
EOF

# Aktualisierte Navbar
cat > components/organisms/navbar.tsx << 'EOF'
"use client";

import { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Button } from "@/components/ui/button";
import { useAuth } from "@/contexts/auth-context";

export function Navbar() {
  const pathname = usePathname();
  const { isAuthenticated, isAdmin, user, logout } = useAuth();
  
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
            <div className="flex items-center gap-4">
              <span className="text-sm">{user?.username || 'Benutzer'}</span>
              {isAdmin && (
                <Link href="/admin">
                  <Button variant="outline" size="sm">Admin</Button>
                </Link>
              )}
              <Button variant="ghost" onClick={logout}>Abmelden</Button>
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

# Aktualisierte AlternativesPage mit queryClient
cat > app/alternatives/page.tsx << 'EOF'
"use client";

import { useState } from "react";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { useAuth } from "@/contexts/auth-context";
import { useToast } from "@/components/ui/toast";
import { useQueryClient } from "@/components/query-client-provider";

const categories = [
  "Alle",
  "Kommunikation",
  "Soziale Medien",
  "Suche",
  "E-Mail",
  "Cloud-Speicher",
  "Browser",
  "Betriebssysteme",
  "Produktivität",
  "Streaming",
];

export default function AlternativesPage() {
  const [selectedCategory, setSelectedCategory] = useState<string | undefined>(undefined);
  const { isAuthenticated } = useAuth();
  const { toast } = useToast();
  const { useQuery } = useQueryClient();

  const { data: alternatives, isLoading } = useQuery({
    queryKey: ["alternatives", selectedCategory],
    queryFn: () => [] // Mock-Funktion, die echte Daten kommen aus dem QueryClientProvider
  });

  // Filtere Alternativen basierend auf Kategorie
  const filteredAlternatives = selectedCategory && selectedCategory !== "Alle"
    ? alternatives?.filter(alt => alt.category === selectedCategory)
    : alternatives;

  // Formatiere Datum
  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return new Intl.DateTimeFormat("de-DE").format(date);
  };

  return (
    <div className="container mx-auto py-8 px-4">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold mb-2">Ethische Alternativen</h1>
          <p className="text-muted-foreground">
            Entdecken Sie datenschutzfreundliche und ethische Alternativen zu Big-Tech-Produkten
          </p>
        </div>
        {isAuthenticated ? (
          <Link href="/alternatives/new" className="mt-4 md:mt-0">
            <Button>Neue Alternative vorschlagen</Button>
          </Link>
        ) : (
          <Link href="/auth/login" className="mt-4 md:mt-0">
            <Button variant="outline">Anmelden zum Vorschlagen</Button>
          </Link>
        )}
      </div>

      {/* Kategorie-Filter */}
      <div className="mb-8 overflow-x-auto">
        <div className="flex space-x-2 pb-2">
          {categories.map((category) => (
            <Button
              key={category}
              variant={selectedCategory === category || (category === "Alle" && !selectedCategory) ? "default" : "outline"}
              size="sm"
              onClick={() => setSelectedCategory(category === "Alle" ? undefined : category)}
            >
              {category}
            </Button>
          ))}
        </div>
      </div>

      {isLoading ? (
        <div className="flex justify-center my-12">
          <p>Lade Alternativen...</p>
        </div>
      ) : filteredAlternatives && filteredAlternatives.length > 0 ? (
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {filteredAlternatives.map((alternative) => (
            <Link href={`/alternatives/${alternative.id}`} key={alternative.id}>
              <Card className="h-full transition-shadow hover:shadow-md">
                <CardHeader>
                  <div className="flex justify-between items-start">
                    <div>
                      <CardTitle>{alternative.title}</CardTitle>
                      <CardDescription>Alternative zu {alternative.replaces}</CardDescription>
                    </div>
                    <div className="bg-primary/10 text-primary rounded-full px-3 py-1 text-sm">
                      {alternative.category}
                    </div>
                  </div>
                </CardHeader>
                <CardContent>
                  <p className="line-clamp-3">{alternative.description}</p>
                </CardContent>
                <CardFooter className="flex justify-between text-sm text-muted-foreground">
                  <div>
                    👍 {alternative.upvotes} Upvotes
                  </div>
                  <div>
                    {formatDate(alternative.createdAt)}
                  </div>
                </CardFooter>
              </Card>
            </Link>
          ))}
        </div>
      ) : (
        <div className="text-center my-12">
          <p className="mb-4">Keine Alternativen in dieser Kategorie gefunden.</p>
          {!isAuthenticated && (
            <p>
              <Link href="/auth/login" className="text-primary hover:underline">
                Melden Sie sich an
              </Link>{" "}
              und schlagen Sie die erste Alternative vor!
            </p>
          )}
        </div>
      )}
    </div>
  );
}
EOF

# Alternativdetailseite
mkdir -p app/alternatives/[id]
cat > app/alternatives/[id]/page.tsx << 'EOF'
"use client";

import { useState } from "react";
import Link from "next/link";
import { useParams } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { useAuth } from "@/contexts/auth-context";
import { useToast } from "@/components/ui/toast";
import { useQueryClient } from "@/components/query-client-provider";

export default function AlternativeDetailPage() {
  const params = useParams<{ id: string }>();
  const { isAuthenticated, user } = useAuth();
  const { toast } = useToast();
  const { useQuery, useMutation, invalidateQueries } = useQueryClient();

  const { data: alternative, isLoading, error } = useQuery({
    queryKey: ["alternative", params.id],
    queryFn: () => ({}) // Mock-Funktion, echte Daten kommen aus dem QueryClientProvider
  });

  const voteMutation = useMutation({
    mutationFn: async ({ type }: { type: 'upvote' | 'downvote' }) => {
      // Simuliere API-Aufruf
      await new Promise(resolve => setTimeout(resolve, 500));
      return alternative;
    },
    onSuccess: () => {
      toast({
        title: "Bewertung gespeichert",
        description: "Ihre Bewertung wurde erfolgreich gespeichert.",
      });
      invalidateQueries({ queryKey: ["alternative", params.id] });
    }
  });

  const handleVote = (type: 'upvote' | 'downvote') => {
    if (!isAuthenticated) {
      toast({
        title: "Anmeldung erforderlich",
        description: "Bitte melden Sie sich an, um abzustimmen.",
        variant: "default",
      });
      return;
    }
    
    voteMutation.mutate({ type });
  };

  // Formatiere Datum
  const formatDate = (dateString: string) => {
    if (!dateString) return '';
    const date = new Date(dateString);
    return new Intl.DateTimeFormat("de-DE").format(date);
  };

  if (isLoading) {
    return (
      <div className="container mx-auto py-8 px-4">
        <div className="flex justify-center">
          <p>Lade Alternative...</p>
        </div>
      </div>
    );
  }

  if (error || !alternative) {
    return (
      <div className="container mx-auto py-8 px-4">
        <div className="text-center">
          <h1 className="text-2xl font-bold mb-4">Fehler beim Laden der Alternative</h1>
          <p className="mb-4">{error instanceof Error ? error.message : "Alternative konnte nicht geladen werden."}</p>
          <Link href="/alternatives">
            <Button>Zurück zur Übersicht</Button>
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto py-8 px-4">
      <div className="mb-6">
        <Link href="/alternatives">
          <Button variant="ghost" size="sm">
            ← Zurück zur Übersicht
          </Button>
        </Link>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="md:col-span-2">
          <Card>
            <CardHeader>
              <div className="flex flex-col md:flex-row justify-between items-start md:items-center">
                <div>
                  <CardTitle className="text-2xl">{alternative.title}</CardTitle>
                  <CardDescription className="text-lg">
                    Alternative zu <span className="font-medium">{alternative.replaces}</span>
                  </CardDescription>
                </div>
                <div className="mt-2 md:mt-0 bg-primary/10 text-primary rounded-full px-3 py-1">
                  {alternative.category}
                </div>
              </div>
            </CardHeader>
            <CardContent className="space-y-6">
              <div>
                <h3 className="font-semibold mb-2">Beschreibung</h3>
                <p className="whitespace-pre-line">{alternative.description}</p>
              </div>
              
              <div>
                <h3 className="font-semibold mb-2">Gründe für den Wechsel</h3>
                <p className="whitespace-pre-line">{alternative.reasons}</p>
              </div>
              
              <div>
                <h3 className="font-semibold mb-2">Vorteile</h3>
                <p className="whitespace-pre-line">{alternative.benefits}</p>
              </div>

              {alternative.website && (
                <div>
                  <h3 className="font-semibold mb-2">Website</h3>
                  <a 
                    href={alternative.website.startsWith('http') ? alternative.website : `https://${alternative.website}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-primary hover:underline"
                  >
                    {alternative.website}
                  </a>
                </div>
              )}
            </CardContent>
            <CardFooter className="flex justify-between text-sm text-muted-foreground border-t pt-6">
              <div>
                Vorgeschlagen von {alternative.submitter?.username || "Unbekannt"} am {formatDate(alternative.createdAt)}
              </div>
              
              {isAuthenticated && alternative.submitter?.id === user?.id && (
                <Link href={`/alternatives/${alternative.id}/edit`}>
                  <Button variant="outline" size="sm">Bearbeiten</Button>
                </Link>
              )}
            </CardFooter>
          </Card>
        </div>

        <div>
          <Card>
            <CardHeader>
              <CardTitle>Bewerten</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex justify-center space-x-4">
                <Button 
                  onClick={() => handleVote('upvote')} 
                  variant="outline"
                  size="lg"
                  disabled={voteMutation.isPending}
                  className="flex-1 py-8"
                >
                  👍<br />Unterstützen
                </Button>
                <Button 
                  onClick={() => handleVote('downvote')} 
                  variant="outline"
                  size="lg"
                  disabled={voteMutation.isPending}
                  className="flex-1 py-8"
                >
                  👎<br />Ablehnen
                </Button>
              </div>
              
              <div className="text-center">
                <p className="text-2xl font-bold">{alternative.upvotes}</p>
                <p className="text-sm text-muted-foreground">Bewertung</p>
              </div>

              {!isAuthenticated && (
                <div className="text-center mt-4">
                  <p className="text-sm text-muted-foreground mb-2">Melden Sie sich an, um abzustimmen</p>
                  <Link href="/auth/login">
                    <Button variant="outline" size="sm">Anmelden</Button>
                  </Link>
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
EOF

# Login-Seite
mkdir -p app/auth/login
cat > app/auth/login/page.tsx << 'EOF'
"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { useAuth } from "@/contexts/auth-context";
import { useToast } from "@/components/ui/toast";

export default function LoginPage() {
  const router = useRouter();
  const { login } = useAuth();
  const { toast } = useToast();
  const [isLoading, setIsLoading] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setIsLoading(true);
    
    try {
      await login(email, password);
      toast({
        title: "Erfolgreich angemeldet",
        description: "Sie wurden erfolgreich angemeldet.",
      });
      router.push("/alternatives");
    } catch (error) {
      setError(error instanceof Error ? error.message : "Anmeldung fehlgeschlagen");
      toast({
        title: "Anmeldung fehlgeschlagen",
        description: error instanceof Error ? error.message : "Es ist ein Fehler aufgetreten.",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <div className="flex h-screen items-center justify-center p-4">
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>Anmelden</CardTitle>
          <CardDescription>
            Melden Sie sich an, um ethische Alternativen vorzuschlagen und zu bewerten
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-2">
              <label className="text-sm font-medium">E-Mail</label>
              <Input 
                placeholder="ihre.email@beispiel.de" 
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">Passwort</label>
              <Input 
                type="password" 
                placeholder="••••••••" 
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
            {error && <p className="text-sm text-red-500">{error}</p>}
            <Button type="submit" className="w-full" disabled={isLoading}>
              {isLoading ? "Anmeldung..." : "Anmelden"}
            </Button>
          </form>
        </CardContent>
        <CardFooter className="flex justify-center">
          <p className="text-sm text-muted-foreground">
            Noch kein Konto?{" "}
            <Link href="/auth/register" className="text-primary hover:underline">
              Jetzt registrieren
            </Link>
          </p>
        </CardFooter>
      </Card>
    </div>
  );
}
EOF

# Register-Seite
mkdir -p app/auth/register
cat > app/auth/register/page.tsx << 'EOF'
"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { useAuth } from "@/contexts/auth-context";
import { useToast } from "@/components/ui/toast";

export default function RegisterPage() {
  const router = useRouter();
  const { register } = useAuth();
  const { toast } = useToast();
  const [isLoading, setIsLoading] = useState(false);
  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [error, setError] = useState("");

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");

    if (password !== confirmPassword) {
      setError("Die Passwörter stimmen nicht überein");
      return;
    }

    setIsLoading(true);
    
    try {
      await register(username, email, password);
      toast({
        title: "Registrierung erfolgreich",
        description: "Ihr Konto wurde erfolgreich erstellt.",
      });
      router.push("/alternatives");
    } catch (error) {
      setError(error instanceof Error ? error.message : "Registrierung fehlgeschlagen");
      toast({
        title: "Registrierung fehlgeschlagen",
        description: error instanceof Error ? error.message : "Es ist ein Fehler aufgetreten.",
        variant: "destructive",
      });
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center p-4">
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>Registrieren</CardTitle>
          <CardDescription>
            Erstellen Sie ein Konto, um ethische Alternativen vorzuschlagen und zu bewerten
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-2">
              <label className="text-sm font-medium">Benutzername</label>
              <Input 
                placeholder="benutzername" 
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">E-Mail</label>
              <Input 
                placeholder="ihre.email@beispiel.de" 
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">Passwort</label>
              <Input 
                type="password" 
                placeholder="••••••••" 
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">Passwort bestätigen</label>
              <Input 
                type="password" 
                placeholder="••••••••" 
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                required
              />
            </div>
            {error && <p className="text-sm text-red-500">{error}</p>}
            <Button type="submit" className="w-full" disabled={isLoading}>
              {isLoading ? "Registrierung..." : "Registrieren"}
            </Button>
          </form>
        </CardContent>
        <CardFooter className="flex justify-center">
          <p className="text-sm text-muted-foreground">
            Bereits registriert?{" "}
            <Link href="/auth/login" className="text-primary hover:underline">
              Jetzt anmelden
            </Link>
          </p>
        </CardFooter>
      </Card>
    </div>
  );
}
EOF

# Admin-Dashboard
mkdir -p app/admin
cat > app/admin/page.tsx << 'EOF'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { useAuth } from "@/contexts/auth-context";
import { useToast } from "@/components/ui/toast";
import { useQueryClient } from "@/components/query-client-provider";

export default function AdminDashboardPage() {
  const router = useRouter();
  const { isAuthenticated, isAdmin } = useAuth();
  const { toast } = useToast();
  const { useQuery, useMutation, invalidateQueries } = useQueryClient();
  const [expandedAlternative, setExpandedAlternative] = useState<string | null>(null);

  // Prüfen, ob Benutzer angemeldet und Admin ist
  if (!isAuthenticated || !isAdmin) {
    router.push("/");
    return null;
  }

  const { data: pendingAlternatives = [], isLoading } = useQuery({
    queryKey: ["pendingAlternatives"],
    queryFn: () => [], // Mock-Funktion, echte Daten kommen aus dem QueryClientProvider
  });

  const approveMutation = useMutation({
    mutationFn: async (id: string) => {
      // Simuliere API-Aufruf
      await new Promise(resolve => setTimeout(resolve, 800));
      return { success: true };
    },
    onSuccess: () => {
      invalidateQueries({ queryKey: ["pendingAlternatives"] });
      toast({
        title: "Alternative genehmigt",
        description: "Die Alternative wurde erfolgreich genehmigt und ist jetzt öffentlich sichtbar.",
      });
    }
  });

  const handleApprove = (id: string) => {
    approveMutation.mutate(id);
  };

  const toggleExpand = (id: string) => {
    if (expandedAlternative === id) {
      setExpandedAlternative(null);
    } else {
      setExpandedAlternative(id);
    }
  };

  // Formatiere Datum
  const formatDate = (dateString: string) => {
    if (!dateString) return '';
    const date = new Date(dateString);
    return new Intl.DateTimeFormat("de-DE").format(date);
  };

  if (isLoading) {
    return (
      <div className="container mx-auto py-8 px-4">
        <h1 className="text-3xl font-bold mb-8">Admin-Dashboard</h1>
        <div className="flex justify-center my-12">
          <p>Lade ausstehende Alternativen...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto py-8 px-4">
      <h1 className="text-3xl font-bold mb-2">Admin-Dashboard</h1>
      <p className="text-muted-foreground mb-8">
        Verwalten Sie ausstehende Alternativen und moderieren Sie Inhalte
      </p>

      <div className="mb-12">
        <h2 className="text-2xl font-semibold mb-4">Ausstehende Alternativen ({pendingAlternatives?.length || 0})</h2>

        {pendingAlternatives?.length === 0 ? (
          <div className="text-center my-8 p-6 bg-muted rounded-lg">
            <p>Keine ausstehenden Alternativen zur Überprüfung.</p>
          </div>
        ) : (
          <div className="space-y-6">
            {pendingAlternatives?.map((alternative) => (
              <Card key={alternative.id}>
                <CardHeader>
                  <div className="flex flex-col md:flex-row justify-between items-start md:items-center">
                    <div>
                      <CardTitle>{alternative.title}</CardTitle>
                      <CardDescription>Alternative zu {alternative.replaces}</CardDescription>
                    </div>
                    <div className="mt-2 md:mt-0 bg-primary/10 text-primary rounded-full px-3 py-1">
                      {alternative.category}
                    </div>
                  </div>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <div>
                      <h3 className="font-semibold mb-1">Beschreibung</h3>
                      <p className={expandedAlternative === alternative.id ? "" : "line-clamp-2"}>
                        {alternative.description}
                      </p>
                    </div>
                    
                    {expandedAlternative === alternative.id && (
                      <>
                        <div>
                          <h3 className="font-semibold mb-1">Gründe für den Wechsel</h3>
                          <p>{alternative.reasons}</p>
                        </div>
                        
                        <div>
                          <h3 className="font-semibold mb-1">Vorteile</h3>
                          <p>{alternative.benefits}</p>
                        </div>

                        {alternative.website && (
                          <div>
                            <h3 className="font-semibold mb-1">Website</h3>
                            <a 
                              href={alternative.website.startsWith('http') ? alternative.website : `https://${alternative.website}`}
                              target="_blank"
                              rel="noopener noreferrer"
                              className="text-primary hover:underline"
                            >
                              {alternative.website}
                            </a>
                          </div>
                        )}
                      </>
                    )}
                    
                    <Button 
                      variant="ghost" 
                      size="sm" 
                      onClick={() => toggleExpand(alternative.id)}
                    >
                      {expandedAlternative === alternative.id ? "Weniger anzeigen" : "Mehr anzeigen"}
                    </Button>
                  </div>
                </CardContent>
                <CardFooter className="flex flex-col md:flex-row justify-between items-start md:items-center border-t pt-4">
                  <div className="text-sm text-muted-foreground mb-4 md:mb-0">
                    Vorgeschlagen von {alternative.submitter?.username || "Unbekannt"} am {formatDate(alternative.createdAt)}
                  </div>
                  <div className="flex space-x-2 w-full md:w-auto">
                    <Button 
                      variant="outline" 
                      className="flex-1 md:flex-none"
                      onClick={() => router.push(`/alternatives/${alternative.id}`)}
                    >
                      Anzeigen
                    </Button>
                    <Button 
                      variant="default" 
                      className="flex-1 md:flex-none"
                      onClick={() => handleApprove(alternative.id)}
                      disabled={approveMutation.isPending}
                    >
                      Genehmigen
                    </Button>
                  </div>
                </CardFooter>
              </Card>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
EOF

# Hilfsklasse für Datenformatierung
mkdir -p lib/utils
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

echo "✅ Umfassender Frontend-Fix erfolgreich implementiert!"
