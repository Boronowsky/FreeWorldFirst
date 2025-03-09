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
