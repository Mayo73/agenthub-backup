---
id: T-0506
title: Matching-Logik – Kandidaten, Match beenden, Blockieren
project: sparring
priority: 2
after: T-0505
---
## Ziel
React-Native-Neustart, Meilenstein „Swipe und Match“: Welche Profile die aktive Person noch sieht, und das freiwillige Beenden bzw. Blockieren.

## Dateien
- `app/src/logic/matching.ts` – ergänzen
- `app/__tests__/matching.test.ts` – Tests ergänzen

## Akzeptanzkriterien
Vorher `app/src/logic/matching.ts` lesen und die vorhandenen Funktionen nutzen. Nichts ändert `data` selbst.
- `export function candidates(data: AppData, userId: string): Profile[]` → alle `data.profiles` in ihrer Reihenfolge außer: der Person selbst, Profilen, die `userId` schon bewertet hat (`hasSwiped`), blockierten (`isBlocked`) und Profilen, mit denen es schon ein Match gibt (`matchBetween`, auch beendet)
- `export function endMatch(data: AppData, matchId: string, by: string): AppData` → nur wenn das Match existiert, aktiv ist und `by` darin vorkommt: `endedBy = by`; sonst unverändert
- `export function block(data: AppData, from: string, to: string): AppData` → unverändert bei `from === to` oder wenn `likeKey(from, to)` schon in `blocks` steht. Sonst `likeKey(from, to)` an `blocks` anhängen und ein aktives Match zwischen beiden mit `endedBy = from` beenden

## Tests
In `app/__tests__/matching.test.ts` ergänzen:
- `Kandidaten am Anfang`: `candidates(demoData(), 'p01')` hat 7 Profile, das erste ist p02, p01 ist nicht dabei
- `bewertete fallen weg`: nach `like(d, 'p01', 'p02')` und `pass(d, 'p01', 'p03')` hat `candidates(d, 'p01')` 5 Profile, erstes p04
- `Match fällt weg`: p01→p02 und p02→p01 → p02 nicht in `candidates(d, 'p01')`, p01 nicht in `candidates(d, 'p02')`
- `Match beenden`: nach Match → `endMatch(d, 'm1', 'p02')` → `endedBy` `'p02'`; `endMatch` mit `'p03'` oder unbekannter ID gibt dasselbe Objekt zurück (`toBe`)
- `Blockieren beendet das Match`: nach Match → `block(d, 'p01', 'p02')` → `blocks` `['p01>p02']`, Match `endedBy` `'p01'`, `isBlocked(d, 'p02', 'p01')` wahr
- `Blockierte erscheinen nicht`: `block(demoData(), 'p03', 'p01')` → p03 nicht in `candidates(d, 'p01')` und p01 nicht in `candidates(d, 'p03')`

Review (21.10.2026): gemergt.
