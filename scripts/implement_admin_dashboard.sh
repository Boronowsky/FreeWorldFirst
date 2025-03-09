#!/bin/bash
set -e

echo "👑 Implementiere Admin-Dashboard..."

cd FreeWorldFirst/frontend

# Erstellen der Admin-Dashboard-Seite
mkdir -p app/admin

cat > app/admin/page.tsx << 'EOF'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { getPendingAlternatives, approveAlternative } from "@/lib/api/alternatives";
import { Button } from "@/components/ui/button";
import { useAuth } from "@/contexts/auth-context";
import { useToast } from "@/components/ui/use-toast";
import { formatDate } from "@/lib/utils";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export default function AdminDashboardPage() {
  const router = useRouter();
  const { isAuthenticated, isAdmin, user } = useAuth();
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const [expandedAlternative, setExpandedAlternative] = useState<string | null>(null);

  // Prüfen, ob Benutzer angemeldet und Admin ist
  if (!isAuthenticated || !isAdmin) {
    router.push("/");
    return null;
  }

  const {
    data: pendingAlternatives,
    isLoading,
    error,
  } = useQuery({
    queryKey: ["pendingAlternatives"],
    queryFn: async () => {
      const token = localStorage.getItem("token");
      if (!token) throw new Error("Nicht authentifiziert");
      return getPendingAlternatives(token);
    },
  });

  const approveMutation = useMutation({
    mutationFn: async (id: string) => {
      const token = localStorage.getItem("token");
      if (!token) throw new Error("Nicht authentifiziert");
      return approveAlternative(id, token);
    },
    onSuccess: () => {
      // Daten nach erfolgreicher Genehmigung aktualisieren
      queryClient.invalidateQueries({ queryKey: ["pendingAlternatives"] });
      toast({
        title: "Alternative genehmigt",
        description: "Die Alternative wurde erfolgreich genehmigt und ist jetzt öffentlich sichtbar.",
      });
    },
    onError: (error) => {
      toast({
        title: "Fehler bei der Genehmigung",
        description: error instanceof Error ? error.message : "Es ist ein Fehler aufgetreten.",
        variant: "destructive",
      });
    },
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

  if (error) {
    return (
      <div className="container mx-auto py-8 px-4">
        <h1 className="text-3xl font-bold mb-8">Admin-Dashboard</h1>
        <div className="text-center my-12">
          <p className="text-red-500">
            Fehler beim Laden der ausstehenden Alternativen: {error instanceof Error ? error.message : "Unbekannter Fehler"}
          </p>
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

# Erstellen der Navigationsleiste-Komponente
mkdir -p components/organisms

cat > components/organisms/navbar.tsx << 'EOF'
"use client";

import { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Button } from "@/components/ui/button";
import { useAuth } from "@/contexts/auth-context";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

export function Navbar() {
  const { isAuthenticated, isAdmin, user, logout } = useAuth();
  const pathname = usePathname();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

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
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" className="font-medium">
                  {user?.username || "Benutzer"}
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                <DropdownMenuLabel>Mein Konto</DropdownMenuLabel>
                <DropdownMenuSeparator />
                <DropdownMenuItem asChild>
                  <Link href="/alternatives/new">Neue Alternative</Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild>
                  <Link href="/profile">Mein Profil</Link>
                </DropdownMenuItem>
                {isAdmin && (
                  <>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem asChild>
                      <Link href="/admin">Admin-Dashboard</Link>
                    </DropdownMenuItem>
                  </>
                )}
                <DropdownMenuSeparator />
                <DropdownMenuItem onClick={logout}>Abmelden</DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
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

# Aktualisierung des Layouts, um die Navigationsleiste hinzuzufügen
cat > app/layout.tsx << 'EOF'
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { ThemeProvider } from "@/components/theme-provider";
import { AuthProvider } from "@/contexts/auth-context";
import { Toaster } from "@/components/ui/toaster";
import { Navbar } from "@/components/organisms/navbar";
import { QueryClientProvider } from "@/components/query-client-provider";

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
              <Toaster />
            </AuthProvider>
          </QueryClientProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
EOF

# Erstellen des QueryClientProvider für React Query
mkdir -p components

cat > components/query-client-provider.tsx << 'EOF'
"use client";

import { useState } from "react";
import { QueryClient, QueryClientProvider as TanstackQueryProvider } from "@tanstack/react-query";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";

export function QueryClientProvider({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 1000 * 60 * 5, // 5 Minuten
            refetchOnWindowFocus: false,
          },
        },
      })
  );

  return (
    <TanstackQueryProvider client={queryClient}>
      {children}
      <ReactQueryDevtools initialIsOpen={false} />
    </TanstackQueryProvider>
  );
}
EOF

# Installieren zusätzlicher UI-Komponenten
npx shadcn-ui@latest add dropdown-menu

echo "✅ Admin-Dashboard erfolgreich implementiert!"