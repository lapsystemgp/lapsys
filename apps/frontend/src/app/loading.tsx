export default function Loading() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50/50 dark:bg-zinc-900/50 backdrop-blur-sm">
      <div className="flex flex-col items-center gap-4">
        <div className="w-12 h-12 rounded-full border-4 border-blue-100 dark:border-blue-900 border-t-blue-600 dark:border-t-blue-500 animate-spin"></div>
        <p className="text-sm font-medium text-gray-500 dark:text-zinc-400 animate-pulse">Loading...</p>
      </div>
    </div>
  );
}
