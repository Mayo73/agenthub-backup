// Navigation ohne Bibliothek: ein Reiter unten plus ein Stapel darübergelegter Bildschirme.

export type Tab = 'entdecken' | 'matches' | 'profil';

export const TABS: { tab: Tab; label: string }[] = [
  { tab: 'entdecken', label: 'Entdecken' },
  { tab: 'matches', label: 'Matches' },
  { tab: 'profil', label: 'Profil' },
];

/** Ein Bildschirm über dem Reiter, z. B. der Chat eines Matches. */
export type Route = { screen: string; matchId?: string };

export type NavState = { tab: Tab; stack: Route[] };

export function initialNav(): NavState {
  return { tab: 'entdecken', stack: [] };
}

/** Reiter wechseln; darübergelegte Bildschirme werden geschlossen. */
export function selectTab(_nav: NavState, tab: Tab): NavState {
  return { tab, stack: [] };
}

export function push(nav: NavState, route: Route): NavState {
  return { tab: nav.tab, stack: [...nav.stack, route] };
}

export function current(nav: NavState): Route | undefined {
  return nav.stack[nav.stack.length - 1];
}

/**
 * Android-Zurück: schließt den obersten Bildschirm, sonst zurück zum Reiter „Entdecken“.
 * handled ist false, wenn nichts mehr zu schließen ist (dann beendet Android die App).
 */
export function back(nav: NavState): { nav: NavState; handled: boolean } {
  if (nav.stack.length > 0) {
    return { nav: { tab: nav.tab, stack: nav.stack.slice(0, -1) }, handled: true };
  }
  if (nav.tab !== 'entdecken') {
    return { nav: { tab: 'entdecken', stack: [] }, handled: true };
  }
  return { nav, handled: false };
}
