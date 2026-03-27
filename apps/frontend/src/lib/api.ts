export const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL?.replace(/\/+$/, '') || 'http://localhost:3001';

export class ApiError extends Error {
  status: number;
  bodyText?: string;

  constructor(message: string, params: { status: number; bodyText?: string }) {
    super(message);
    this.name = 'ApiError';
    this.status = params.status;
    this.bodyText = params.bodyText;
  }
}

async function readBodyTextSafe(response: Response) {
  try {
    return await response.text();
  } catch {
    return undefined;
  }
}

export async function apiFetch<T>(path: string, init?: RequestInit): Promise<T> {
  const url = `${API_BASE_URL}${path.startsWith('/') ? '' : '/'}${path}`;

  const response = await fetch(url, {
    ...init,
    credentials: 'include',
    headers: {
      ...(init?.headers ?? {}),
    },
  });

  if (!response.ok) {
    const bodyText = await readBodyTextSafe(response);
    throw new ApiError(`API request failed: ${response.status}`, {
      status: response.status,
      bodyText,
    });
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return (await response.json()) as T;
}

