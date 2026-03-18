'use client';

import { useEffect, useState } from 'react';

export default function AdminDashboardPage() {
  const [data, setData] = useState<{ message: string; timestamp: string } | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // In a real app we would use an axios instance with an interceptor to attach the JWT automatically,
    // or rely on cookies sent with credentials. Assuming standard fetch with cookies for this MVP.
    fetch('http://localhost:3000/api/admin/data')
      .then((res) => {
        if (!res.ok) throw new Error(`HTTP Error ${res.status}`);
        return res.json();
      })
      .then((json) => setData(json))
      .catch((err) => setError(err.message));
  }, []);

  return (
    <div className="min-h-screen bg-zinc-950 text-white p-8">
      <div className="max-w-4xl mx-auto space-y-8">
        <h1 className="text-4xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-purple-400 to-indigo-600">
          Admin Dashboard
        </h1>
        
        <div className="bg-zinc-900 border border-zinc-800 p-6 rounded-xl">
          <h2 className="text-xl font-semibold mb-4 text-zinc-200">Protected Backend Data</h2>
          
          {error && (
            <div className="bg-red-500/10 border border-red-500/20 text-red-400 p-4 rounded-lg">
              Failed to load data: {error}
            </div>
          )}
          
          {data ? (
            <div className="space-y-4">
              <div className="flex justify-between items-center p-4 bg-zinc-950 rounded-lg border border-zinc-800">
                <span className="text-zinc-400">Message</span>
                <span className="font-mono text-green-400">{data.message}</span>
              </div>
              <div className="flex justify-between items-center p-4 bg-zinc-950 rounded-lg border border-zinc-800">
                <span className="text-zinc-400">Server Time</span>
                <span className="font-mono text-zinc-300">{new Date(data.timestamp).toLocaleString()}</span>
              </div>
            </div>
          ) : !error && (
            <div className="animate-pulse flex space-x-4">
              <div className="flex-1 space-y-4 py-1">
                <div className="h-4 bg-zinc-800 rounded w-3/4"></div>
                <div className="space-y-2">
                  <div className="h-4 bg-zinc-800 rounded"></div>
                  <div className="h-4 bg-zinc-800 rounded w-5/6"></div>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
