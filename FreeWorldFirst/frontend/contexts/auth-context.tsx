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
