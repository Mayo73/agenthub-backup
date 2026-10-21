import AsyncStorage from '@react-native-async-storage/async-storage';
import type { AppData, Profile } from './types';
import { demoData } from './demoData';

export const STORAGE_KEY = 'sparring.data.v1';

export type KeyValueStore = {
  getItem(key: string): Promise<string | null>;
  setItem(key: string, value: string): Promise<void>;
  removeItem(key: string): Promise<void>;
};

type AsyncStorageType = typeof AsyncStorage & KeyValueStore;

export async function loadData(
  store?: KeyValueStore
): Promise<AppData> {
  const actualStore = store ?? (AsyncStorage as AsyncStorageType);
  try {
    const stored = await actualStore.getItem(STORAGE_KEY);
    if (stored === null) {
      return demoData();
    }
    const parsed = JSON.parse(stored);
    if (typeof parsed !== 'object' || parsed === null) {
      return demoData();
    }
    if ((parsed as unknown as { version: unknown }).version !== 1) {
      return demoData();
    }
    if (!Array.isArray((parsed as unknown as { profiles: unknown }).profiles)) {
      return demoData();
    }
    if ((parsed as unknown as { profiles: Profile[] }).profiles.length === 0) {
      return demoData();
    }
    return parsed as AppData;
  } catch {
    return demoData();
  }
}

export async function saveData(
  data: AppData,
  store?: KeyValueStore
): Promise<void> {
  const actualStore = store ?? (AsyncStorage as AsyncStorageType);
  await actualStore.setItem(STORAGE_KEY, JSON.stringify(data));
}

export async function resetData(
  store?: KeyValueStore
): Promise<AppData> {
  const actualStore = store ?? (AsyncStorage as AsyncStorageType);
  await actualStore.removeItem(STORAGE_KEY);
  return demoData();
}
