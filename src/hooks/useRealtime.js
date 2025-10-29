import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';

/**
 * Hook for subscribing to real-time updates from Supabase
 * @param {string} table - Table name
 * @param {string} filter - Optional filter (e.g., "id=eq.123")
 * @returns {Array} [data, loading, error]
 */
export function useRealtime(table, filter = null) {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Initial fetch
    let query = supabase.from(table).select('*');
    if (filter) {
      query = query.eq(filter.split('=')[0], filter.split('=')[2]);
    }

    query.then(({ data: initialData, error: fetchError }) => {
      if (fetchError) {
        setError(fetchError);
      } else {
        setData(initialData || []);
      }
      setLoading(false);
    });

    // Subscribe to changes
    const channel = supabase
      .channel(`${table}_changes`)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: table,
        },
        (payload) => {
          if (payload.eventType === 'INSERT') {
            setData((prev) => [...prev, payload.new]);
          } else if (payload.eventType === 'UPDATE') {
            setData((prev) =>
              prev.map((item) =>
                item.id === payload.new.id ? payload.new : item
              )
            );
          } else if (payload.eventType === 'DELETE') {
            setData((prev) =>
              prev.filter((item) => item.id !== payload.old.id)
            );
          }
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [table, filter]);

  return [data, loading, error];
}

