// API-Client für Alternativen

export interface Alternative {
  id: string;
  title: string;
  replaces: string;
  description: string;
  reasons: string;
  benefits: string;
  website: string | null;
  category: string;
  upvotes: number;
  approved: boolean;
  submitterId: string;
  createdAt: string;
  updatedAt: string;
  submitter?: {
    id: string;
    username: string;
  };
  comments?: Comment[];
}

export interface Comment {
  id: string;
  content: string;
  userId: string;
  alternativeId: string;
  createdAt: string;
  updatedAt: string;
  user: {
    id: string;
    username: string;
  };
}

export interface CreateAlternativeData {
  title: string;
  replaces: string;
  description: string;
  reasons: string;
  benefits: string;
  website?: string;
  category: string;
}

// Alle Alternativen abrufen
export async function getAlternatives(category?: string): Promise<Alternative[]> {
  const url = new URL(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/alternatives`);
  if (category) {
    url.searchParams.append('category', category);
  }

  const response = await fetch(url.toString(), {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
  });

  if (!response.ok) {
    throw new Error('Alternativen konnten nicht abgerufen werden');
  }

  return response.json();
}

// Eine Alternative abrufen
export async function getAlternative(id: string): Promise<Alternative> {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/alternatives/${id}`,
    {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    },
  );

  if (!response.ok) {
    throw new Error('Alternative konnte nicht abgerufen werden');
  }

  return response.json();
}

// Eine neue Alternative erstellen
export async function createAlternative(data: CreateAlternativeData, token: string): Promise<Alternative> {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/alternatives`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
      body: JSON.stringify(data),
    },
  );

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'Alternative konnte nicht erstellt werden');
  }

  return response.json();
}

// Für eine Alternative abstimmen
export async function voteForAlternative(
  id: string,
  type: 'upvote' | 'downvote',
  token: string,
): Promise<Alternative> {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/alternatives/${id}/vote?type=${type}`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
    },
  );

  if (!response.ok) {
    throw new Error('Abstimmung fehlgeschlagen');
  }

  return response.json();
}

// Ausstehende Alternativen abrufen (nur für Admins)
export async function getPendingAlternatives(token: string): Promise<Alternative[]> {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/alternatives/pending`,
    {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    },
  );

  if (!response.ok) {
    throw new Error('Ausstehende Alternativen konnten nicht abgerufen werden');
  }

  return response.json();
}

// Eine Alternative genehmigen (nur für Admins)
export async function approveAlternative(id: string, token: string): Promise<Alternative> {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'}/alternatives/${id}/approve`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    },
  );

  if (!response.ok) {
    throw new Error('Alternative konnte nicht genehmigt werden');
  }

  return response.json();
}
