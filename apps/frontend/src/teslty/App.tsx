import { useEffect } from 'react';

/**
 * @deprecated Legacy prototype shell retained as a guard.
 * Product routes now live in /app and this component must not be used.
 */
export default function App() {
  useEffect(() => {
    if (process.env.NODE_ENV !== 'production') {
      console.warn('Deprecated component used: teslty/App.tsx. Use app routes instead.');
    }
  }, []);

  return null;
}
