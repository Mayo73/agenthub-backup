import React from 'react';
import { fireEvent, render, screen } from '@testing-library/react-native';
import App from '../App';

function selected(testID: string): boolean {
  return Boolean(screen.getByTestId(testID).props.accessibilityState?.selected);
}

describe('App', () => {
  test('zeigt den Prototyp-Hinweis und startet auf Entdecken', async () => {
    await render(<App />);
    expect(screen.getByText('Prototyp · nur fiktive Testprofile')).toBeTruthy();
    expect(selected('tab-entdecken')).toBe(true);
    expect(selected('tab-profil')).toBe(false);
  });

  test('Reiter wechseln', async () => {
    await render(<App />);
    await fireEvent.press(screen.getByTestId('tab-profil'));
    expect(selected('tab-profil')).toBe(true);
    expect(selected('tab-entdecken')).toBe(false);
  });
});
