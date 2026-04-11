import Link from 'next/link';

export default async function UnauthorizedPage({
  searchParams,
}: {
  searchParams?: Promise<{ reason?: string }>;
}) {
  const resolvedSearchParams = (await searchParams) ?? {};
  const isPendingReview = resolvedSearchParams.reason === 'pending_review';
  const isRejected = resolvedSearchParams.reason === 'rejected';
  const isSuspended = resolvedSearchParams.reason === 'suspended';

  const message = isPendingReview
    ? "Your lab account is pending review. You'll be able to access the lab dashboard after activation."
    : isRejected
      ? 'Your lab account was rejected during onboarding. Please update your setup details and contact support or an admin to continue.'
      : isSuspended
        ? 'Your lab account is currently suspended. Please contact the admin team for reactivation details.'
        : 'You do not have the necessary permissions to view this page.';

  return (
    <div className="flex min-h-screen flex-col items-center justify-center p-24 bg-zinc-950 text-white">
      <div className="z-10 w-full max-w-md items-center justify-between font-mono text-sm">
        <div className="bg-zinc-900 border border-zinc-800 p-8 rounded-xl shadow-2xl space-y-6 text-center">
          <h1 className="text-3xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-red-400 to-pink-600">
            Access Denied
          </h1>
          <p className="text-zinc-400">{message}</p>
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
