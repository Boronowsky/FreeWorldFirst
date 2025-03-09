#!/bin/bash
set -e

echo "🔧 Behebe Syntaxfehler in der Alternatives-New-Seite..."

cd ~/fwf-arlernativesDB_V2/FreeWorldFirst_Installation/FreeWorldFirst/frontend

# Korrigiere die Struktur des Formulars
cat > app/alternatives/new/page.tsx << 'EOF'
"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { useAuth } from "@/contexts/auth-context";
import { useToast } from "@/components/ui/toast";

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
  const { isAuthenticated } = useAuth();
  const { toast } = useToast();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [formData, setFormData] = useState({
    title: "",
    replaces: "",
    description: "",
    reasons: "",
    benefits: "",
    website: "",
    category: "",
  });

  // Wenn nicht angemeldet, umleiten
  if (!isAuthenticated) {
    router.push("/auth/login");
    return null;
  }

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleCategoryChange = (value: string) => {
    setFormData(prev => ({ ...prev, category: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    
    try {
      // Validierung
      const requiredFields = ['title', 'replaces', 'description', 'reasons', 'benefits', 'category'];
      const missingFields = requiredFields.filter(field => !formData[field as keyof typeof formData]);
      
      if (missingFields.length > 0) {
        throw new Error(`Bitte füllen Sie alle Pflichtfelder aus: ${missingFields.join(', ')}`);
      }
      
      // Simuliere API-Aufruf
      await new Promise(resolve => setTimeout(resolve, 1000));
      
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
  };

  return (
    <div className="container mx-auto py-8 px-4 max-w-3xl">
      <div className="mb-6">
        <Link href="/alternatives">
          <Button variant="ghost" size="sm">
            ← Zurück zur Übersicht
          </Button>
        </Link>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Neue Alternative vorschlagen</CardTitle>
          <CardDescription>
            Schlagen Sie eine ethische Alternative zu einem Big-Tech-Produkt vor
          </CardDescription>
        </CardHeader>
        <form onSubmit={handleSubmit}>
          <CardContent className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <label className="text-sm font-medium">Name der Alternative</label>
                <Input 
                  placeholder="z.B. Signal" 
                  name="title"
                  value={formData.title}
                  onChange={handleChange}
                  required
                />
                <p className="text-xs text-gray-500">
                  Der Name der datenschutzfreundlichen Alternative
                </p>
              </div>

              <div className="space-y-2">
                <label className="text-sm font-medium">Ersetzt</label>
                <Input 
                  placeholder="z.B. WhatsApp" 
                  name="replaces"
                  value={formData.replaces}
                  onChange={handleChange}
                  required
                />
                <p className="text-xs text-gray-500">
                  Der Name des Big-Tech-Produkts, das ersetzt wird
                </p>
              </div>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium">Beschreibung</label>
              <Textarea
                placeholder="Beschreiben Sie die Alternative und ihre Funktionen..."
                className="min-h-[120px]"
                name="description"
                value={formData.description}
                onChange={handleChange}
                required
              />
              <p className="text-xs text-gray-500">
                Eine detaillierte Beschreibung der Alternative
              </p>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium">Gründe für den Wechsel</label>
              <Textarea
                placeholder="Warum sollte man vom BigTech-Produkt zu dieser Alternative wechseln?"
                className="min-h-[120px]"
                name="reasons"
                value={formData.reasons}
                onChange={handleChange}
                required
              />
              <p className="text-xs text-gray-500">
                Datenschutzbedenken, ethische Probleme oder andere Gründe
              </p>
            </div>

            <div className="space-y-2">
              <label className="text-sm font-medium">Vorteile</label>
              <Textarea
                placeholder="Welche Vorteile bietet diese Alternative?"
                className="min-h-[120px]"
                name="benefits"
                value={formData.benefits}
                onChange={handleChange}
                required
              />
              <p className="text-xs text-gray-500">
                Datenschutz, Open Source, Dezentralisierung, Funktionen etc.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-2">
                <label className="text-sm font-medium">Website (optional)</label>
                <Input 
                  placeholder="z.B. https://signal.org" 
                  name="website"
                  value={formData.website}
                  onChange={handleChange}
                />
                <p className="text-xs text-gray-500">
                  Die offizielle Website der Alternative
                </p>
              </div>

              <div className="space-y-2">
                <label className="text-sm font-medium">Kategorie</label>
                <Select value={formData.category} onValueChange={handleCategoryChange}>
                  <SelectTrigger>
                    <SelectValue placeholder="Wählen Sie eine Kategorie" />
                  </SelectTrigger>
                  <SelectContent>
                    {categories.map((category) => (
                      <SelectItem key={category} value={category}>
                        {category}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                <p className="text-xs text-gray-500">
                  Die Kategorie der Alternative
                </p>
              </div>
            </div>
          </CardContent>
          <CardFooter className="flex justify-end gap-4 pt-4">
            <Link href="/alternatives">
              <Button variant="outline" type="button">
                Abbrechen
              </Button>
            </Link>
            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? "Wird eingereicht..." : "Alternative vorschlagen"}
            </Button>
          </CardFooter>
        </form>
      </Card>
    </div>
  );
}
EOF

echo "✅ Syntaxfehler erfolgreich behoben!"
