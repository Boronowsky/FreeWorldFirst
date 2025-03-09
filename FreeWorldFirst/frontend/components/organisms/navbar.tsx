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
