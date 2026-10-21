---
id: T-0511
title: Filter-Logik – Kampfsportart und Erfahrung
project: sparring
priority: 3
---
## Ziel
React-Native-Neustart, Meilenstein „Swipe und Match“ (Soll): Kampfsportart und Erfahrung als einfache Filter für die Testprofile.

## Dateien
- `app/src/logic/filter.ts` – neu
- `app/__tests__/filter.test.ts` – neu

## Akzeptanzkriterien
Vorher `app/src/logic/types.ts` und `app/src/logic/demoData.ts` (`ARTS`, `LEVELS`) lesen.
- `export type Filter = { arts: string[]; levels: Level[] }`
- `export function emptyFilter(): Filter` → beide Listen leer
- `export function applyFilter(profiles: Profile[], f: Filter): Profile[]` → leere `arts` heißt alle Kampfsportarten, leere `levels` alle Erfahrungsstufen; sonst nur Profile, deren `art` in `f.arts` und deren `level` in `f.levels` steht; Reihenfolge bleibt
- `export function isFilterActive(f: Filter): boolean` → eine der Listen ist nicht leer
- `export function toggle<T>(list: T[], value: T): T[]` → neue Liste ohne `value`, wenn es enthalten ist, sonst mit `value` am Ende
- `export function describeFilter(f: Filter): string` → `''`, wenn nicht aktiv; sonst die Kampfsportarten mit `', '` verbunden und die Erfahrungsstufen als Wörter aus `LEVELS` mit `', '` verbunden, beide Teile (wenn vorhanden) mit `' · '` verbunden. Beispiel: `{ arts: ['Jiu-Jitsu', 'MMA'], levels: [0] }` → `'Jiu-Jitsu, MMA · Einsteiger'`

## Tests
`app/__tests__/filter.test.ts` mit `DEMO_PROFILES`:
- `leerer Filter zeigt alle`: 8 Profile, `isFilterActive` falsch, `describeFilter` `''`
- `nach Kampfsportart`: `arts: ['Boxen']` → Mira und Tarek
- `nach Erfahrung`: `levels: [2]` → Sam, Lea, Tarek
- `beides`: `arts: ['Jiu-Jitsu'], levels: [2]` → nur Lea
- `toggle`: `toggle(['a'], 'b')` → `['a', 'b']`, `toggle(['a', 'b'], 'a')` → `['b']`, die Eingabeliste bleibt unverändert
- `Beschreibung`: Beispiel oben, und `{ arts: [], levels: [1, 2] }` → `'Fortgeschritten, Erfahren'`

Review (21.10.2026): gemergt.
