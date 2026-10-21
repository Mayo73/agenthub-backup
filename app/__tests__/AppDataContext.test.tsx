import React from 'react';
import { fireEvent, render, screen } from '@testing-library/react-native';
import { Pressable, Text } from 'react-native';
import { AppDataProvider, useAppData } from '../src/state/AppDataContext';
import type { KeyValueStore } from '../src/logic/storage';
import { STORAGE_KEY, saveData, resetData } from '../src/logic/storage';
import { demoData } from '../src/logic/demoData';

async function renderWithProvider(
  store?: KeyValueStore,
  ui?: React.ReactNode
) {
  const wrapped = ui ?? <Probe />;
  return render(<AppDataProvider store={store}>{wrapped}</AppDataProvider>);
}

function Probe() {
  const { data, update, reset } = useAppData();
  return (
    <>
      <Text testID="active">{data.activeId}</Text>
      <Pressable
        testID="switch"
        onPress={() => {
          update((d) => ({ ...d, activeId: 'p02' }));
        }}
      />
      <Pressable
        testID="reset"
        onPress={() => {
          reset();
        }}
      />
    </>
  );
}

function memoryStore(): KeyValueStore {
  let store: Record<string, string> = {};
  return {
    getItem: async (key: string) => store[key] ?? null,
    setItem: async (key: string, value: string) => {
      store[key] = value;
    },
    removeItem: async (key: string) => {
      delete store[key];
    },
  };
}

describe('AppDataContext', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  test('startet mit Testdaten', async () => {
    await renderWithProvider(memoryStore());
    expect(screen.getByText('p01')).toBeTruthy();
  });

  test('Änderung wird gespeichert', async () => {
    const store = memoryStore();
    await renderWithProvider(store);
    fireEvent.press(screen.getByTestId('switch'));
    expect(await screen.findByText('p02')).toBeTruthy();
    const json = JSON.parse(await store.getItem(STORAGE_KEY) || '');
    expect(json.activeId).toBe('p02');
  });

  test('lädt gespeicherte Daten', async () => {
    const store = memoryStore();
    await saveData({ ...demoData(), activeId: 'p05' }, store);
    await renderWithProvider(store);
    expect(await screen.findByText('p05')).toBeTruthy();
  });

  test('zurücksetzen', async () => {
    const store = memoryStore();
    await renderWithProvider(store);
    fireEvent.press(screen.getByTestId('switch'));
    expect(await screen.findByText('p02')).toBeTruthy();
    fireEvent.press(screen.getByTestId('reset'));
    expect(await screen.findByText('p01')).toBeTruthy();
    const item = await store.getItem(STORAGE_KEY);
    expect(item).toBe(null);
  });

  test('außerhalb des Providers', async () => {
    const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation(() => {});

    function WithoutProvider() {
      useAppData();
      return <Text testID="fallback" />;
    }

    let thrown: Error | null = null;
    try {
      await render(<WithoutProvider />);
    } catch (e) {
      thrown = e as Error;
    }

    expect(thrown).toBeInstanceOf(Error);
    expect(thrown?.message).toContain('useAppData nur innerhalb von AppDataProvider');
    consoleErrorSpy.mockRestore();
  });
});
