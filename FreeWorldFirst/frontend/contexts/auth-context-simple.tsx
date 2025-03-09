"use client";

import React, { createContext, useContext, useState, useEffect } from "react";

interface User {
  id: string;
  username: string;
  email: string;
  isAdmin: boolean;
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

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(false);

  // Simulierter Login
  const login = async (email: string, password: string) => {
    setLoading(true);
    try {
      // Simuliere einen erfolgreichen Login (für Demo)
      console.log("Login versucht mit:", email, password);
      setUser({
        id: "1",
        username: "demo",
        email: email,
        isAdmin: email.includes("admin"),
      });
    } catch (error) {
      console.error("Login-Fehler:", error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  // Simulierter Register
  const register = async (username: string, email: string, password: string) => {
    setLoading(true);
    try {
      // Simuliere eine erfolgreiche Registrierung (für Demo)
      console.log("Registrierung versucht mit:", username, email, password);
      setUser({
        id: "1",
        username: username,
        email: email,
        isAdmin: false,
      });
    } catch (error) {
      console.error("Registrierungs-Fehler:", error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  // Logout
  const logout = () => {
    setUser(null);
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
