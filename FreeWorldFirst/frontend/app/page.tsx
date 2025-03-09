import Link from "next/link";

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <h1 className="mb-4 text-4xl font-bold">FreeWorldFirst Collector</h1>
      <p className="mb-8 text-center text-xl">
        Entdecke ethische Alternativen zu BigTech-Produkten und -Diensten
      </p>
      <div className="flex gap-4">
        <Link
          href="/alternatives"
          className="rounded-md bg-blue-600 px-4 py-2 text-white hover:bg-blue-700"
        >
          Alternativen durchsuchen
        </Link>
        <Link
          href="/auth/login"
          className="rounded-md border border-blue-600 px-4 py-2 text-blue-600 hover:bg-blue-50"
        >
          Anmelden
        </Link>
      </div>
    </main>
  );
}
