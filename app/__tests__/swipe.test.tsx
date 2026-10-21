import React from 'react';
import { Text } from 'react-native';
import { fireEvent, render, screen, within } from '@testing-library/react-native';
import SwipeCard from '../src/components/SwipeCard';
import DiscoverScreen from '../src/screens/DiscoverScreen';
import { AppDataProvider } from '../src/state/AppDataContext';
import type { KeyValueStore } from '../src/logic/storage';
import { swipeDecision } from '../src/logic/swipe';

function memoryStore(): KeyValueStore {
  const items = new Map<string, string>();
  return {
    getItem: async (key: string) => items.get(key) ?? null,
    setItem: async (key: string, value: string) => {
      items.set(key, value);
    },
    removeItem: async (key: string) => {
      items.delete(key);
    },
  };
}

describe('swipe', () => {
  test('Entscheidung nach Weg', () => {
    expect(swipeDecision(130, 0)).toBe('like');
    expect(swipeDecision(-130, 0)).toBe('pass');
    expect(swipeDecision(60, 0)).toBeNull();
    expect(swipeDecision(0, 0)).toBeNull();
  });

  test('Entscheidung nach Tempo', () => {
    expect(swipeDecision(50, 1)).toBe('like');
    expect(swipeDecision(-50, -1)).toBe('pass');
    expect(swipeDecision(30, 2)).toBeNull();
  });

  test('SwipeCard zeigt den Inhalt', async () => {
    await render(
      <SwipeCard onLike={jest.fn()} onPass={jest.fn()}>
        <Text>Karte</Text>
      </SwipeCard>,
    );
    expect(screen.getByText('Karte')).toBeTruthy();
    expect(screen.getByTestId('swipe-card')).toBeTruthy();
  });

  test('DiscoverScreen nutzt SwipeCard', async () => {
    await render(
      <AppDataProvider store={memoryStore()}>
        <DiscoverScreen />
      </AppDataProvider>,
    );
    expect(within(screen.getByTestId('swipe-card')).getByText('Sam, 33')).toBeTruthy();
    await fireEvent.press(screen.getByTestId('btn-like'));
    expect(within(await screen.findByTestId('swipe-card')).getByText('Mira, 26')).toBeTruthy();
  });
});
