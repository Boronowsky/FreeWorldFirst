import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { ThemeProvider } from "@/components/theme-provider";
import { ToastProvider } from "@/components/ui/toast";
import { Navbar } from "@/components/organisms/navbar";
import { QueryClientProvider } from "@/components/query-client-provider";
import { AuthProvider } from "@/contexts/auth-context";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "FreeWorldFirst Collector",
  description: "Plattform für ethische Alternativen zu BigTech-Produkten und -Diensten",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="de" suppressHydrationWarning>
      <body className={inter.className}>
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          <QueryClientProvider>
            <AuthProvider>
              <ToastProvider>
                <div className="flex min-h-screen flex-col">
                  <Navbar />
                  <main className="flex-1">
                    {children}
                  </main>
                  <footer className="border-t py-6 md:py-0">
                    <div className="container flex flex-col items-center justify-between gap-4 md:h-16 md:flex-row">
                      <p className="text-sm text-muted-foreground">
                        &copy; {new Date().getFullYear()} FreeWorldFirst Collector. Alle Rechte vorbehalten.
                      </p>
                    </div>
                  </footer>
                </div>
              </ToastProvider>
            </AuthProvider>
          </QueryClientProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
