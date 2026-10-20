import { back, current, initialNav, push, selectTab } from '../src/navigation';

describe('navigation', () => {
  test('Start auf Entdecken ohne Stapel', () => {
    expect(initialNav()).toEqual({ tab: 'entdecken', stack: [] });
  });

  test('push und zurück', () => {
    const n = push(selectTab(initialNav(), 'matches'), { screen: 'chat', matchId: 'm1' });
    expect(current(n)).toEqual({ screen: 'chat', matchId: 'm1' });
    const r = back(n);
    expect(r.handled).toBe(true);
    expect(r.nav).toEqual({ tab: 'matches', stack: [] });
  });

  test('zurück von einem anderen Reiter führt zu Entdecken', () => {
    const r = back(selectTab(initialNav(), 'profil'));
    expect(r).toEqual({ nav: { tab: 'entdecken', stack: [] }, handled: true });
  });

  test('zurück auf Entdecken ist nicht behandelt', () => {
    expect(back(initialNav()).handled).toBe(false);
  });

  test('Reiterwechsel schließt den Stapel', () => {
    const n = push(initialNav(), { screen: 'chat', matchId: 'm1' });
    expect(selectTab(n, 'profil').stack).toEqual([]);
  });
});
