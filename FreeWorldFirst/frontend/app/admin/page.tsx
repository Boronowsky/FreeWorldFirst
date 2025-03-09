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
