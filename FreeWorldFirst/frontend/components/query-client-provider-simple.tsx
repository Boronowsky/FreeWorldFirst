"use client";

import React from "react";

// Einfache Mock-Version des QueryClientProvider
export function QueryClientProvider({ children }: { children: React.ReactNode }) {
  return (
    <>{children}</>
  );
}
