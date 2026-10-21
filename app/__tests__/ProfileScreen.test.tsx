import React from 'react';
import { fireEvent, render, screen, waitFor } from '@testing-library/react-native';
import ProfileScreen from '../src/screens/ProfileScreen';
import { AppDataProvider } from '../src/state/AppDataContext';
import type { KeyValueStore } from '../src/logic/storage';
import { STORAGE_KEY } from '../src/logic/storage';

function memoryStore(): KeyValueStore & { raw: Record<string, string> } {
  const raw: Record<string, string> = {};
  return {
    raw,
    getItem: async (key: string) => raw[key] ?? null,
    setItem: async (key: string, value: string) => {
      raw[key] = value;
    },
    removeItem: async (key: string) => {
      delete raw[key];
    },
  };
}

async function renderScreen(store: KeyValueStore) {
  return render(
    <AppDataProvider store={store}>
      <ProfileScreen />
    </AppDataProvider>
  );
}

function saved(store: { raw: Record<string, string> }) {
  const text = store.raw[STORAGE_KEY];
  return text ? JSON.parse(text) : null;
}

async function editAndSave() {
  await fireEvent.press(await screen.findByTestId('profile-edit'));
  await fireEvent.changeText(screen.getByTestId('edit-name'), 'Alexa');
  await fireEvent.press(screen.getByTestId('edit-art-1'));
  await fireEvent.press(screen.getByTestId('edit-save'));
  await screen.findByText('Alexa, 29');
}

describe('ProfileScreen', () => {
  test('zeigt das aktive Profil', async () => {
    await renderScreen(memoryStore());
    expect(await screen.findByText('Alex, 29')).toBeOnTheScreen();
    expect(screen.getByText('Dein Demoprofil')).toBeOnTheScreen();
  });

  test('bearbeiten und speichern', async () => {
    const store = memoryStore();
    await renderScreen(store);
    await editAndSave();
    expect(screen.getByText('MMA')).toBeOnTheScreen();
    await waitFor(() => expect(saved(store)?.profiles[0].name).toBe('Alexa'));
  });

  test('ungültig', async () => {
    const store = memoryStore();
    await renderScreen(store);
    await fireEvent.press(await screen.findByTestId('profile-edit'));
    await fireEvent.changeText(screen.getByTestId('edit-age'), '15');
    await fireEvent.press(screen.getByTestId('edit-save'));
    expect(screen.getByTestId('edit-errors')).toHaveTextContent(
      'Alter muss zwischen 18 und 99 liegen',
      { exact: false }
    );
    const data = saved(store);
    expect(data === null || data.profiles[0].age === 29).toBe(true);
  });

  test('abbrechen', async () => {
    await renderScreen(memoryStore());
    await fireEvent.press(await screen.findByTestId('profile-edit'));
    await fireEvent.changeText(screen.getByTestId('edit-name'), 'Bob');
    await fireEvent.press(screen.getByTestId('edit-cancel'));
    expect(await screen.findByText('Alex, 29')).toBeOnTheScreen();
    expect(screen.queryByText('Bob, 29')).toBeNull();
  });

  test('nach Neustart erhalten', async () => {
    const store = memoryStore();
    const first = await renderScreen(store);
    await editAndSave();
    await waitFor(() => expect(saved(store)?.profiles[0].name).toBe('Alexa'));
    first.unmount();
    await renderScreen(store);
    expect(await screen.findByText('Alexa, 29')).toBeOnTheScreen();
  });
});
