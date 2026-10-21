import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react-native';
import { AppDataProvider } from '../src/state/AppDataContext';
import DiscoverScreen from '../src/screens/DiscoverScreen';

const createMockStore = () => {
  let store: Record<string, string> = {};
  return {
    setItem(key: string, value: string): Promise<void> {
      store[key] = value;
      return Promise.resolve();
    },
    getItem(key: string): Promise<string | null> {
      return Promise.resolve(store[key] || null);
    },
    removeItem(key: string): Promise<void> {
      delete store[key];
      return Promise.resolve();
    },
  };
};

describe('DiscoverScreen', () => {
  test('zeigt das erste Profil', async () => {
    const store = createMockStore();
    render(
      <AppDataProvider store={store}>
        <DiscoverScreen />
      </AppDataProvider>
    );
    await waitFor(() => {
      expect(screen.getByText('Sam, 33')).toBeTruthy();
    }, { timeout: 5000 });
    expect(screen.getByText('Du bist: Alex (Demo)')).toBeTruthy();
  });

  test('Überspringen zeigt das nächste', async () => {
    const store = createMockStore();
    render(
      <AppDataProvider store={store}>
        <DiscoverScreen />
      </AppDataProvider>
    );
    await waitFor(() => {
      expect(screen.getByText('Sam, 33')).toBeTruthy();
    }, { timeout: 5000 });
    await fireEvent.press(screen.getByTestId('btn-pass'));
    await waitFor(() => {
      expect(screen.getByText('Mira, 26')).toBeTruthy();
    }, { timeout: 5000 });
  });

  test('Interesse zeigt das nächste', async () => {
    const store = createMockStore();
    render(
      <AppDataProvider store={store}>
        <DiscoverScreen />
      </AppDataProvider>
    );
    await waitFor(() => {
      expect(screen.getByText('Sam, 33')).toBeTruthy();
    }, { timeout: 5000 });
    await fireEvent.press(screen.getByTestId('btn-like'));
    await waitFor(() => {
      expect(screen.getByText('Mira, 26')).toBeTruthy();
    }, { timeout: 5000 });
  });

  test('alle bewertet', async () => {
    const store = createMockStore();
    render(
      <AppDataProvider store={store}>
        <DiscoverScreen />
      </AppDataProvider>
    );
    await waitFor(() => {
      expect(screen.getByText('Sam, 33')).toBeTruthy();
    }, { timeout: 5000 });
    for (let i = 0; i < 7; i++) {
      await fireEvent.press(screen.getByTestId('btn-pass'));
    }
    await waitFor(() => {
      expect(screen.getByTestId('discover-empty')).toBeTruthy();
    }, { timeout: 10000 });
  });
});
