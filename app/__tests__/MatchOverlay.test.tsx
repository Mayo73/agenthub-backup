import React from 'react';
import { fireEvent, render, screen } from '@testing-library/react-native';
import MatchOverlay from '../src/components/MatchOverlay';
import DiscoverScreen from '../src/screens/DiscoverScreen';
import { AppDataProvider } from '../src/state/AppDataContext';
import { DEMO_PROFILES, demoData } from '../src/logic/demoData';
import { saveData, type KeyValueStore } from '../src/logic/storage';

function createStore(): KeyValueStore {
  const map = new Map<string, string>();
  return {
    getItem: (key: string) => Promise.resolve(map.get(key) ?? null),
    setItem: (key: string, value: string) => {
      map.set(key, value);
      return Promise.resolve();
    },
    removeItem: (key: string) => {
      map.delete(key);
      return Promise.resolve();
    },
  };
}

describe('MatchOverlay', () => {
  test('Knöpfe', async () => {
    const onChat = jest.fn();
    const onClose = jest.fn();
    await render(
      <MatchOverlay visible={true} me={DEMO_PROFILES[0]} other={DEMO_PROFILES[1]} onChat={onChat} onClose={onClose} />
    );
    expect(screen.getByText('Match!')).toBeTruthy();
    expect(screen.getByText('Du und Sam habt gegenseitig Interesse.')).toBeTruthy();
    await fireEvent.press(screen.getByTestId('match-chat'));
    expect(onChat).toHaveBeenCalledTimes(1);
    await fireEvent.press(screen.getByTestId('match-close'));
    expect(onClose).toHaveBeenCalledTimes(1);
  });

  test('kein Match bei einseitigem Interesse', async () => {
    await render(
      <AppDataProvider store={createStore()}>
        <DiscoverScreen onOpenChat={jest.fn()} />
      </AppDataProvider>
    );
    await screen.findByText('Sam, 33');
    await fireEvent.press(screen.getByTestId('btn-like'));
    expect(screen.queryByTestId('match-overlay')).toBeNull();
  });

  test('Match bei gegenseitigem Interesse', async () => {
    const store = createStore();
    await saveData({ ...demoData(), likes: ['p02>p01'] }, store);
    const onOpenChat = jest.fn();
    await render(
      <AppDataProvider store={store}>
        <DiscoverScreen onOpenChat={onOpenChat} />
      </AppDataProvider>
    );
    await screen.findByText('Sam, 33');
    await fireEvent.press(screen.getByTestId('btn-like'));
    expect(screen.getByTestId('match-overlay')).toBeTruthy();
    await fireEvent.press(screen.getByTestId('match-chat'));
    expect(onOpenChat).toHaveBeenCalledWith('m1');
    expect(screen.queryByTestId('match-overlay')).toBeNull();
  });
});
