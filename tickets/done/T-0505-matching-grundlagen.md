---
id: T-0505
title: Matching-Logik – Interesse, Überspringen, gegenseitiges Match
project: sparring
priority: 2
---
## Ziel
React-Native-Neustart, Meilenstein „Swipe und Match“: Die reine Logik für Interesse und Überspringen. Ein Match entsteht erst bei gegenseitigem Interesse.

## Dateien
- `app/src/logic/matching.ts` – neu
- `app/__tests__/matching.test.ts` – neu

## Akzeptanzkriterien
Vorher `app/src/logic/types.ts`, `app/src/logic/demoData.ts` und `app/CLAUDE.md` bzw. `CLAUDE.md` lesen. Alle Funktionen ändern `data` nicht, sondern geben ein neues `AppData` zurück; bei nicht erlaubten Aktionen das unveränderte `data`.
- `export function likeKey(from: string, to: string): string` → `` `${from}>${to}` ``
- `export function isBlocked(data: AppData, x: string, y: string): boolean` → `data.blocks` enthält `likeKey(x, y)` oder `likeKey(y, x)`
- `export function hasSwiped(data: AppData, from: string, to: string): boolean` → `likeKey(from, to)` steht in `likes` oder `passes`
- `export function matchBetween(data: AppData, x: string, y: string): Match | undefined` → das Match mit diesen beiden Personen, egal in welcher Reihenfolge (auch beendete)
- `export function like(data: AppData, from: string, to: string): AppData`: unverändert, wenn `from === to`, `isBlocked` oder `hasSwiped(from, to)`. Sonst `likeKey(from, to)` an `likes` anhängen. Steht `likeKey(to, from)` schon in `likes` und gibt es noch kein `matchBetween`, ein Match anhängen: `{ id: 'm' + data.nextMatchNo, a: to, b: from, endedBy: '' }` und `nextMatchNo` um 1 erhöhen.
- `export function pass(data: AppData, from: string, to: string): AppData`: unverändert bei `from === to` oder `hasSwiped`; sonst `likeKey(from, to)` an `passes` anhängen
- `export function matchesOf(data: AppData, userId: string): Match[]` → alle Matches, in denen `a` oder `b` gleich `userId` ist, in ihrer Reihenfolge
- `export function otherId(match: Match, userId: string): string` → die jeweils andere Person
- `export function isActive(match: Match): boolean` → `match.endedBy === ''`

## Tests
`app/__tests__/matching.test.ts` (mit `demoData()` beginnen):
- `einseitiges Interesse ergibt kein Match`: `like(d, 'p01', 'p02')` → `likes` ist `['p01>p02']`, `matches` leer
- `gegenseitiges Interesse ergibt genau ein Match`: p01→p02, dann p02→p01 → ein Match `{ id: 'm1', a: 'p01', b: 'p02', endedBy: '' }`, `nextMatchNo` 2; `matchesOf` für p01 und p02 je 1, für p03 0
- `doppeltes Interesse ändert nichts`: zweimal p01→p02 → `likes` hat 1 Eintrag
- `unterschiedliche Kampfsportarten können matchen`: p01 (Jiu-Jitsu) und p02 (MMA) gegenseitig → 1 Match
- `überspringen verhindert späteres Interesse`: `pass(d, 'p01', 'p03')`, dann `like(d, 'p01', 'p03')` → `likes` leer, `hasSwiped` wahr
- `sich selbst geht nicht`: `like(d, 'p01', 'p01')` und `pass(d, 'p01', 'p01')` geben dasselbe Objekt zurück (`toBe`)
- `blockiert verhindert Interesse`: `d.blocks = ['p02>p01']` (auf einer Kopie), dann `like(d, 'p01', 'p02')` → `likes` leer
- `Original bleibt unverändert`: nach `like(d, 'p01', 'p02')` ist `d.likes` weiter leer
- `otherId und isActive`: `otherId({ id: 'm1', a: 'p01', b: 'p02', endedBy: '' }, 'p02')` → `'p01'`; `isActive` wahr, mit `endedBy: 'p01'` falsch

Review (21.10.2026): gemergt.
