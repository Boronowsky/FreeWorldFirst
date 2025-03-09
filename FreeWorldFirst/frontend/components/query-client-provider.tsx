"use client";

import React, { createContext, useContext } from "react";
import { mockAlternatives, pendingAlternatives, getAlternativeById } from "@/lib/mock-data/alternatives";

interface QueryResult<T> {
  data: T | undefined;
  isLoading: boolean;
  error: Error | null;
}

interface QueryContextType {
  useQuery: <T>(options: { queryKey: any[], queryFn: () => T | Promise<T> }) => QueryResult<T>;
  useMutation: <TData, TVariables>(options: {
    mutationFn: (variables: TVariables) => Promise<TData>,
    onSuccess?: (data: TData) => void,
    onError?: (error: Error) => void
  }) => {
    mutate: (variables: TVariables) => Promise<TData>,
    isPending: boolean
  };
  invalidateQueries: (options: { queryKey: any[] }) => void;
}

const QueryContext = createContext<QueryContextType | undefined>(undefined);

// Ein einfacher Cache für Mock-Daten
const dataCache: Record<string, any> = {
  alternatives: mockAlternatives,
  pendingAlternatives: pendingAlternatives
};

export function QueryClientProvider({ children }: { children: React.ReactNode }) {
  // Vereinfachte useQuery-Implementierung
  const useQuery = <T,>({ queryKey, queryFn }: { queryKey: any[], queryFn: () => T | Promise<T> }): QueryResult<T> => {
    const [key] = queryKey;
    
    // Für bestimmte Query-Keys verwenden wir vordefinierte Daten
    if (key === "alternatives") {
      return { data: dataCache.alternatives as T, isLoading: false, error: null };
    }
    
    if (key === "pendingAlternatives") {
      return { data: dataCache.pendingAlternatives as T, isLoading: false, error: null };
    }
    
    if (key === "alternative") {
      const id = queryKey[1];
      const alternative = getAlternativeById(id);
      return { data: alternative as T, isLoading: false, error: null };
    }
    
    // Fallback: Ergebnis der queryFn zurückgeben
    try {
      return { data: queryFn() as T, isLoading: false, error: null };
    } catch (err) {
      return { data: undefined, isLoading: false, error: err as Error };
    }
  };

  // Vereinfachte useMutation-Implementierung
  const useMutation = <TData, TVariables>({ 
    mutationFn, 
    onSuccess, 
    onError 
  }: {
    mutationFn: (variables: TVariables) => Promise<TData>,
    onSuccess?: (data: TData) => void,
    onError?: (error: Error) => void
  }) => {
    const mutate = async (variables: TVariables) => {
      try {
        const result = await mutationFn(variables);
        onSuccess?.(result);
        return result;
      } catch (err) {
        const error = err as Error;
        onError?.(error);
        throw error;
      }
    };

    return { mutate, isPending: false };
  };

  // Vereinfachte invalidateQueries-Implementierung
  const invalidateQueries = () => {
    // In dieser Mockversion machen wir nichts
  };

  return (
    <QueryContext.Provider value={{ useQuery, useMutation, invalidateQueries }}>
      {children}
    </QueryContext.Provider>
  );
}

// Hook für den Zugriff auf den QueryClient
export function useQueryClient() {
  const context = useContext(QueryContext);
  if (!context) {
    throw new Error("useQueryClient muss innerhalb eines QueryClientProviders verwendet werden");
  }
  return context;
}
