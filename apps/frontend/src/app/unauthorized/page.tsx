import Link from 'next/link';

export default function UnauthorizedPage({
  searchParams,
}: {
  searchParams?: { reason?: string };
}) {
  const isPendingReview = searchParams?.reason === 'pending_review';

  return (
    <div className="flex min-h-screen flex-col items-center justify-center p-24 bg-zinc-950 text-white">
      <div className="z-10 w-full max-w-md items-center justify-between font-mono text-sm">
        <div className="bg-zinc-900 border border-zinc-800 p-8 rounded-xl shadow-2xl space-y-6 text-center">
          <h1 className="text-3xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-red-400 to-pink-600">
            Access Denied
          </h1>
          <p className="text-zinc-400">
            {isPendingReview
              ? "Your lab account is pending review. You'll be able to access the lab dashboard after activation."
              : 'You do not have the necessary permissions to view this page.'}
          </p>
          <div className="pt-4">
            <Link 
              href="/login" 
              className="inline-block w-full py-2 px-4 bg-zinc-800 hover:bg-zinc-700 text-white rounded-lg transition-colors border border-zinc-700"
            >
              Return to Login
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
