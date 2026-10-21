import React, { createContext, useCallback, useContext, useEffect, useRef, useState } from 'react';
import type { AppData } from '../logic/types';
import type { KeyValueStore } from '../logic/storage';
import { loadData, saveData, resetData } from '../logic/storage';
import { demoData } from '../logic/demoData';

export type AppDataValue = {
  data: AppData;
  loaded: boolean;
  update: (fn: (d: AppData) => AppData) => void;
  reset: () => Promise<void>;
};

const AppDataContext = createContext<AppDataValue | null>(null);

export function AppDataProvider({
  children,
  store,
  initialData,
}: {
  children: React.ReactNode;
  store?: KeyValueStore;
  initialData?: AppData;
}) {
  const initial = initialData ?? demoData();
  const [data, setData] = useState<AppData>(initial);
  const [loaded, setLoaded] = useState<boolean>(!!initialData || false);
  const currentDataRef = useRef<AppData>(initial);

  useEffect(() => {
    if (initialData) {
      // initialData bereits im State, nichts mehr tun
      return;
    }
    loadData(store).then((d) => {
      setData(d);
      currentDataRef.current = d;
      setLoaded(true);
    });
  }, [store, initialData]);

  const update = useCallback(
    (fn: (d: AppData) => AppData) => {
      const current = currentDataRef.current;
      const next = fn(current);
      if (next === current) {
        return;
      }
      setData(next);
      currentDataRef.current = next;
      saveData(next, store);
    },
    [store]
  );

  const reset = useCallback(async () => {
    const result = await resetData(store);
    setData(result);
    currentDataRef.current = result;
  }, [store]);

  return (
    <AppDataContext.Provider value={{ data, loaded, update, reset }}>
      {children}
    </AppDataContext.Provider>
  );
}

export function useAppData(): AppDataValue {
  const ctx = useContext(AppDataContext);
  if (!ctx) {
    throw new Error('useAppData nur innerhalb von AppDataProvider');
  }
  return ctx;
}
