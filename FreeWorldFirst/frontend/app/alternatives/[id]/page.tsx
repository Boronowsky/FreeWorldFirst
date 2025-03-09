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
