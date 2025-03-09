#!/bin/bash
set -e

echo "🌐 Implementiere Alternativen-Komponenten im Frontend..."

cd FreeWorldFirst/frontend

# API Client für Alternativen erstellen
cat > lib/api/alternatives.ts << 'EOF'
// API-Client für Alternativen

export interface Alternative {
  id: string;
  title: string;
  replaces: string;
  description: string;
  reasons: string;
  benefits: string;
  website: string | null;
  category: string;
  upvotes: number;
  approved: boolean;
  submitterId: string;
  createdAt: string;
  updatedAt: string;
  submitter?: {
    id: string;
    username: string;
  };
  comments?: Comment[];
}

export interface Comment {
  id: string;
  content: string;
  userId: string;
  alternativeId: string;
  createdAt: string;
  updatedAt: string;
  user: {
    id: string;
    username: string;
  };
}

export interface CreateAlternativeData {
  title: string;
  replaces: string;
  description: string;
  reasons: string;
  benefits: string;
  website?: string;
  category: string;
}

// Alle Alternativen abrufen
export async function getAlternatives(category?: string): Promise<Alternative[]> {
  const url = new URL(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/alternatives`);
  if (category) {
    url.searchParams.append('category', category);
  }

  const response = await fetch(url.toString(), {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
  });

  if (!response.ok) {
    throw new Error('Alternativen konnten nicht abgerufen werden');
  }

  return response.json();
}

// Eine Alternative abrufen
export async function getAlternative(id: string): Promise<Alternative> {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/alternatives/${id}`,
    {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    },
  );

  if (!response.ok) {
    throw new Error('Alternative konnte nicht abgerufen werden');
  }

  return response.json();
}

// Eine neue Alternative erstellen
export async function createAlternative(data: CreateAlternativeData, token: string): Promise<Alternative> {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/alternatives`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
      body: JSON.stringify(data),
    },
  );

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'Alternative konnte nicht erstellt werden');
  }

  return response.json();
}

// Für eine Alternative abstimmen
export async function voteForAlternative(
  id: string,
  type: 'upvote' | 'downvote',
  token: string,
): Promise<Alternative> {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/alternatives/${id}/vote?type=${type}`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
    },
  );

  if (!response.ok) {
    throw new Error('Abstimmung fehlgeschlagen');
  }

  return response.json();
}

// Ausstehende Alternativen abrufen (nur für Admins)
export async function getPendingAlternatives(token: string): Promise<Alternative[]> {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/alternatives/pending`,
    {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    },
  );

  if (!response.ok) {
    throw new Error('Ausstehende Alternativen konnten nicht abgerufen werden');
  }

  return response.json();
}

// Eine Alternative genehmigen (nur für Admins)
export async function approveAlternative(id: string, token: string): Promise<Alternative> {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/alternatives/${id}/approve`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    },
  );

  if (!response.ok) {
    throw new Error('Alternative konnte nicht genehmigt werden');
  }

  return response.json();
}
EOF

# Schema für Alternatives-Formulare
cat > lib/validators/alternative-schemas.ts << 'EOF'
import * as z from "zod";

export const createAlternativeSchema = z.object({
  title: z
    .string()
    .min(3, "Der Titel muss mindestens 3 Zeichen lang sein")
    .max(100, "Der Titel darf maximal 100 Zeichen lang sein"),
  replaces: z
    .string()
    .min(3, "Der zu ersetzende Dienst muss mindestens 3 Zeichen lang sein")
    .max(100, "Der zu ersetzende Dienst darf maximal 100 Zeichen lang sein"),
  description: z
    .string()
    .min(20, "Die Beschreibung muss mindestens 20 Zeichen lang sein")
    .max(2000, "Die Beschreibung darf maximal 2000 Zeichen lang sein"),
  reasons: z
    .string()
    .min(20, "Die Gründe müssen mindestens 20 Zeichen lang sein")
    .max(1000, "Die Gründe dürfen maximal 1000 Zeichen lang sein"),
  benefits: z
    .string()
    .min(20, "Die Vorteile müssen mindestens 20 Zeichen lang sein")
    .max(1000, "Die Vorteile dürfen maximal 1000 Zeichen lang sein"),
  website: z
    .string()
    .url("Bitte geben Sie eine gültige URL ein")
    .optional()
    .or(z.literal("")),
  category: z
    .string()
    .min(1, "Bitte wählen Sie eine Kategorie aus"),
});

export type CreateAlternativeFormValues = z.infer<typeof createAlternativeSchema>;
EOF

# Erstellen der Alternativen-Übersichtsseite
mkdir -p app/alternatives

cat > app/alternatives/page.tsx << 'EOF'
"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { getAlternatives } from "@/lib/api/alternatives";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { useAuth } from "@/contexts/auth-context";
import { useToast } from "@/components/ui/use-toast";
import { formatDate } from "@/lib/utils";

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

  const { data: alternatives, isLoading, error } = useQuery({
    queryKey: ["alternatives", selectedCategory],
    queryFn: () => getAlternatives(selectedCategory === "Alle" ? undefined : selectedCategory),
  });

  // Bei Fehler eine Toast-Nachricht anzeigen
  useEffect(() => {
    if (error) {
      toast({
        title: "Fehler beim Laden der Alternativen",
        description: error instanceof Error ? error.message : "Es ist ein Fehler aufgetreten.",
        variant: "destructive",
      });
    }
  }, [error, toast]);

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
      ) : alternatives && alternatives.length > 0 ? (
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {alternatives.map((alternative) => (
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

# Erstellen der Detailseite für eine Alternative
mkdir -p app/alternatives/[id]

cat > app/alternatives/[id]/page.tsx << 'EOF'
"use client";

import { useState } from "react";
import Link from "next/link";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useParams } from "next/navigation";
import { getAlternative, voteForAlternative } from "@/lib/api/alternatives";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { useAuth } from "@/contexts/auth-context";
import { useToast } from "@/components/ui/use-toast";
import { formatDate } from "@/lib/utils";

export default function AlternativeDetailPage() {
  const params = useParams<{ id: string }>();
  const { isAuthenticated, user } = useAuth();
  const { toast } = useToast();
  const queryClient = useQueryClient();

  const { data: alternative, isLoading, error } = useQuery({
    queryKey: ["alternative", params.id],
    queryFn: () => getAlternative(params.id),
  });

  const voteMutation = useMutation({
    mutationFn: ({ type }: { type: 'upvote' | 'downvote' }) => {
      const token = localStorage.getItem("token");
      if (!token) throw new Error("Nicht authentifiziert");
      return voteForAlternative(params.id, type, token);
    },
    onSuccess: () => {
      // Daten nach erfolgreicher Abstimmung aktualisieren
      queryClient.invalidateQueries({ queryKey: ["alternative", params.id] });
    },
    onError: (error) => {
      toast({
        title: "Abstimmung fehlgeschlagen",
        description: error instanceof Error ? error.message : "Es ist ein Fehler aufgetreten.",
        variant: "destructive",
      });
    },
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

          {/* Hier würden Kommentare angezeigt werden (in einem zukünftigen Skript implementiert) */}
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

# Erstellen einer Seite für das Vorschlagen neuer Alternativen
mkdir -p app/alternatives/new

cat > app/alternatives/new/page.tsx << 'EOF'
"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { createAlternative } from "@/lib/api/alternatives";
import { createAlternativeSchema, type CreateAlternativeFormValues } from "@/lib/validators/alternative-schemas";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useToast } from "@/components/ui/use-toast";

const categories = [
  "Kommunikation",
  "Soziale Medien",
  "Suche",
  "E-Mail",
  "Cloud-Speicher",
  "Browser",
  "Betriebssysteme",
  "Produktivität",
  "Streaming",
  "Sonstiges",
];

export default function NewAlternativePage() {
  const router = useRouter();
  const { toast } = useToast();
  const [isSubmitting, setIsSubmitting] = useState(false);

  const form = useForm<CreateAlternativeFormValues>({
    resolver: zodResolver(createAlternativeSchema),
    defaultValues: {
      title: "",
      replaces: "",
      description: "",
      reasons: "",
      benefits: "",
      website: "",
      category: "",
    },
  });

  async function onSubmit(values: CreateAlternativeFormValues) {
    setIsSubmitting(true);
    try {
      const token = localStorage.getItem("token");
      if (!token) {
        throw new Error("Sie sind nicht angemeldet. Bitte melden Sie sich an, um eine Alternative vorzuschlagen.");
      }

      await createAlternative(values, token);
      
      toast({
        title: "Alternative erfolgreich vorgeschlagen",
        description: "Ihre Alternative wurde erfolgreich eingereicht und wird von einem Administrator überprüft.",
      });
      
      router.push("/alternatives");
    } catch (error) {
      toast({
        title: "Fehler beim Vorschlagen der Alternative",
        description: error instanceof Error ? error.message : "Es ist ein Fehler aufgetreten.",
        variant: "destructive",
      });
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <div className="container mx-auto py-8 px-4 max-w-3xl">
      <div className="mb-6">
        <Link href="/alternatives">
          <Button variant="ghost" size="sm">
            ← Zurück zur Übersicht
          </Button>
        </Link>
      </div>

      <div className="mb-8">
        <h1 className="text-3xl font-bold mb-2">Neue Alternative vorschlagen</h1>
        <p className="text-muted-foreground">
          Schlagen Sie eine ethische Alternative zu einem Big-Tech-Produkt vor
        </p>
      </div>

      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <FormField
              control={form.control}
              name="title"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Name der Alternative</FormLabel>
                  <FormControl>
                    <Input placeholder="z.B. Signal" {...field} />
                  </FormControl>
                  <FormDescription>
                    Der Name der datenschutzfreundlichen Alternative
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="replaces"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Ersetzt</FormLabel>
                  <FormControl>
                    <Input placeholder="z.B. WhatsApp" {...field} />
                  </FormControl>
                  <FormDescription>
                    Der Name des Big-Tech-Produkts, das ersetzt wird
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />
          </div>

          <FormField
            control={form.control}
            name="description"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Beschreibung</FormLabel>
                <FormControl>
                  <Textarea
                    placeholder="Beschreiben Sie die Alternative und ihre Funktionen..."
                    className="min-h-[120px]"
                    {...field}
                  />
                </FormControl>
                <FormDescription>
                  Eine detaillierte Beschreibung der Alternative
                </FormDescription>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="reasons"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Gründe für den Wechsel</FormLabel>
                <FormControl>
                  <Textarea
                    placeholder="Warum sollte man vom BigTech-Produkt zu dieser Alternative wechseln?"
                    className="min-h-[120px]"
                    {...field}
                  />
                </FormControl>
                <FormDescription>
                  Datenschutzbedenken, ethische Probleme oder andere Gründe
                </FormDescription>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="benefits"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Vorteile</FormLabel>
                <FormControl>
                  <Textarea
                    placeholder="Welche Vorteile bietet diese Alternative?"
                    className="min-h-[120px]"
                    {...field}
                  />
                </FormControl>
                <FormDescription>
                  Datenschutz, Open Source, Dezentralisierung, Funktionen etc.
                </FormDescription>
                <FormMessage />
              </FormItem>
            )}
          />

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <FormField
              control={form.control}
              name="website"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Website (optional)</FormLabel>
                  <FormControl>
                    <Input placeholder="z.B. https://signal.org" {...field} />
                  </FormControl>
                  <FormDescription>
                    Die offizielle Website der Alternative
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="category"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Kategorie</FormLabel>
                  <Select onValueChange={field.onChange} defaultValue={field.value}>
                    <FormControl>
                      <SelectTrigger>
                        <SelectValue placeholder="Wählen Sie eine Kategorie" />
                      </SelectTrigger>
                    </FormControl>
                    <SelectContent>
                      {categories.map((category) => (
                        <SelectItem key={category} value={category}>
                          {category}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <FormDescription>
                    Die Kategorie der Alternative
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />
          </div>

          <div className="flex justify-end gap-4 pt-4">
            <Link href="/alternatives">
              <Button variant="outline" type="button">
                Abbrechen
              </Button>
            </Link>
            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? "Wird eingereicht..." : "Alternative vorschlagen"}
            </Button>
          </div>
        </form>
      </Form>
    </div>
  );
}
EOF

# Installieren zusätzlicher UI-Komponenten
npx shadcn-ui@latest add textarea
npx shadcn-ui@latest add select

echo "✅ Alternativen-Komponenten im Frontend erfolgreich implementiert!"