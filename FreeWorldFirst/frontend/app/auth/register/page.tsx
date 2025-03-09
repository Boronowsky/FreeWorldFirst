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
