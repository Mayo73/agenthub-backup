import React from 'react';
import { fireEvent, render, screen, waitFor } from '@testing-library/react-native';
import PerspectiveBar from '../src/components/PerspectiveBar';
import { AppDataProvider } from '../src/state/AppDataContext';
import type { KeyValueStore } from '../src/logic/storage';

function renderWithContext(store?: KeyValueStore) {
  return render(
    <AppDataProvider store={store}>
      <PerspectiveBar />
    </AppDataProvider>
  );
}

describe('PerspectiveBar', () => {
  test('acht Personen, Alex aktiv', async () => {
    const store = {
      getItem: jest.fn().mockResolvedValue(null),
      setItem: jest.fn(),
      removeItem: jest.fn(),
    } as KeyValueStore;

    await renderWithContext(store);

    expect(screen.getByText('Demo: Ansicht als')).toBeTruthy();

    for (const id of ['p01', 'p02', 'p03', 'p04', 'p05', 'p06', 'p07', 'p08']) {
      expect(screen.getByTestId(`perspective-${id}`)).toBeTruthy();
    }

    const p01Element = screen.getByTestId('perspective-p01');
    expect(p01Element.props.accessibilityState?.selected).toBe(true);
  });

  test('Wechsel', async () => {
    const store = {
      getItem: jest.fn().mockResolvedValue(null),
      setItem: jest.fn(),
      removeItem: jest.fn(),
    } as KeyValueStore;

    await renderWithContext(store);

    fireEvent.press(screen.getByTestId('perspective-p03'));

    await waitFor(() => {
      const p01Element = screen.getByTestId('perspective-p01');
      expect(p01Element.props.accessibilityState?.selected).toBe(false);

      const p03Element = screen.getByTestId('perspective-p03');
      expect(p03Element.props.accessibilityState?.selected).toBe(true);
    });
  });
});
