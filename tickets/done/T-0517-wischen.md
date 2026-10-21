---
id: T-0517
title: Profilkarte wischen (nach rechts Interesse, nach links Überspringen)
project: sparring
priority: 2
after: T-0516
---
## Ziel
React-Native-Neustart, Meilenstein „Swipe und Match“: Die Karte lässt sich mit dem Finger wischen. Wischen und Knöpfe lösen genau dieselben Aktionen aus (Abnahmekriterium 4).

## Dateien
- `app/src/logic/swipe.ts` – neu
- `app/src/components/SwipeCard.tsx` – neu
- `app/src/screens/DiscoverScreen.tsx` – Karte in `SwipeCard` legen
- `app/__tests__/swipe.test.tsx` – neu

## Akzeptanzkriterien
Vorher `app/src/screens/DiscoverScreen.tsx` lesen.
- `swipe.ts`: `export const SWIPE_DISTANCE = 120`; `export function swipeDecision(dx: number, vx: number): 'like' | 'pass' | null` → `'like'`, wenn `dx >= SWIPE_DISTANCE` oder (`dx > 40` und `vx >= 0.8`); `'pass'` spiegelbildlich (`dx <= -SWIPE_DISTANCE` oder (`dx < -40` und `vx <= -0.8`)); sonst `null`
- `SwipeCard` (default export), Props `{ children: React.ReactNode; onLike: () => void; onPass: () => void }`, `testID="swipe-card"`: `PanResponder` (startet bei waagerechter Bewegung über 10 px) und `Animated.ValueXY`; die Karte folgt dem Finger und dreht sich leicht (`rotate` von `-12deg` bis `12deg` über ±200 px). Beim Loslassen `swipeDecision(gesture.dx, gesture.vx)`: bei `'like'` Karte nach rechts hinausschieben (`Animated.timing`, 200 ms), dann `onLike()` und Position auf 0 zurücksetzen; bei `'pass'` nach links, dann `onPass()`; bei `null` mit `Animated.spring` zurück zur Mitte. Während des Wischens ab 40 px ein Stempel „INTERESSE“ (Rahmen `colors.like`, links oben) bzw. „WEITER“ (Rahmen `colors.pass`, rechts oben), Deckkraft je nach Weg
- `DiscoverScreen`: `ProfileCard` in `<SwipeCard key={top.id} onLike={handleLike} onPass={handlePass}>` legen; die Knöpfe rufen weiterhin dieselben `handleLike`/`handlePass`

## Tests
`app/__tests__/swipe.test.tsx`:
- `Entscheidung nach Weg`: `swipeDecision(130, 0)` → `'like'`, `(-130, 0)` → `'pass'`, `(60, 0)` → `null`, `(0, 0)` → `null`
- `Entscheidung nach Tempo`: `(50, 1)` → `'like'`, `(-50, -1)` → `'pass'`, `(30, 2)` → `null`
- `SwipeCard zeigt den Inhalt`: `await render(<SwipeCard onLike={jest.fn()} onPass={jest.fn()}><Text>Karte</Text></SwipeCard>)` → Text `'Karte'` und `swipe-card` vorhanden
- `DiscoverScreen nutzt SwipeCard`: in `AppDataProvider` gerendert → `swipe-card` vorhanden, darin Text `'Sam, 33'`; `btn-like` drücken → weiterhin `swipe-card` mit `'Mira, 26'`

Review (21.10.2026): selbst umgesetzt (der Agent hatte bestehende Tests gelöscht und ProfileCard umgebaut; Typfehler in allen 5 Versuchen).
