---
id: T-0518
title: Match-Hinweis nach gegenseitigem Interesse
project: sparring
priority: 2
after: T-0517, T-0515
---
## Ziel
React-Native-Neustart, Meilenstein „Swipe und Match“: Entsteht durch ein Interesse ein Match, erscheint ein Match-Bildschirm mit dem Weg in den Chat.

## Dateien
- `app/src/components/MatchOverlay.tsx` – neu
- `app/src/screens/DiscoverScreen.tsx` – Hinweis anzeigen, Prop `onOpenChat`
- `app/App.tsx` – `onOpenChat` übergeben
- `app/__tests__/MatchOverlay.test.tsx` – neu

## Akzeptanzkriterien
Vorher `app/App.tsx`, `app/src/navigation.ts`, `app/src/screens/DiscoverScreen.tsx` und `app/src/components/ConfirmDialog.tsx` (Modal-Vorlage) lesen.
- `MatchOverlay` (default export), Props `{ visible: boolean; me: Profile; other: Profile; onChat: () => void; onClose: () => void }`: `Modal` (`transparent`, `onRequestClose={onClose}`), dunkler Hintergrund, Überschrift „Match!“ in `colors.accent` (`sizes.hero`), Text `` `Du und ${other.name} habt gegenseitig Interesse.` ``, beide `Avatar` (`size` 96) nebeneinander, Knopf `testID="match-chat"` „Nachricht schreiben“ (Hintergrund `colors.accent`) → `onChat`, Knopf `testID="match-close"` „Weiter entdecken“ → `onClose`; `testID="match-overlay"` auf der inneren Fläche
- `DiscoverScreen` bekommt Props `{ onOpenChat: (matchId: string) => void }`. `handleLike()` berechnet `next = like(data, me, top.id)`, ruft `update(() => next)` und zeigt den Hinweis, wenn `matchBetween(next, me, top.id)` existiert und `matchBetween(data, me, top.id)` noch nicht (State `matchId: string | null`). „Nachricht schreiben“ → Hinweis schließen, `onOpenChat(matchId)`; „Weiter entdecken“ → schließen
- `App.tsx`: `<DiscoverScreen onOpenChat={id => setNav(push(nav, { screen: 'chat', matchId: id }))} />` (`push` importieren)

## Tests
`app/__tests__/MatchOverlay.test.tsx` (in `AppDataProvider` mit einem Map-Speicher):
- `Knöpfe`: `MatchOverlay` direkt mit `DEMO_PROFILES[0]`/`[1]` und `jest.fn()` rendern → Text `'Match!'`, `'Du und Sam habt gegenseitig Interesse.'`; `match-chat` → `onChat` einmal; `match-close` → `onClose` einmal
- `kein Match bei einseitigem Interesse`: `DiscoverScreen` mit `onOpenChat={jest.fn()}`, `btn-like` drücken → kein `match-overlay` (`queryByTestId` ist `null`)
- `Match bei gegenseitigem Interesse`: Speicher vorher mit `saveData({ ...demoData(), likes: ['p02>p01'] }, store)` füllen, rendern, warten bis `'Sam, 33'` erscheint (`findByText`), `btn-like` drücken → `match-overlay` vorhanden; `match-chat` drücken → `onOpenChat` mit `'m1'` aufgerufen

Review (2026-10-21): fehlgeschlagen in 5 Versuchen (Pflicht-Prop onOpenChat brach bestehende Tests, render ohne await, Speicher-Attrappe ohne removeItem). Von Claude selbst umgesetzt: MatchOverlay, Hinweis im DiscoverScreen (onOpenChat optional), Einbau in App.tsx, 3 Tests.
