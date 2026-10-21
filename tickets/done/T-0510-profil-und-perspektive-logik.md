---
id: T-0510
title: Profil-Logik – Profil prüfen und ändern, Perspektive wechseln
project: sparring
priority: 2
---
## Ziel
React-Native-Neustart, Meilenstein „Profile“: Das eigene Demoprofil lässt sich mit geprüften Angaben ändern; die aktive Testperson lässt sich wechseln (Demofunktion).

## Dateien
- `app/src/logic/profileEdit.ts` – neu
- `app/src/logic/perspective.ts` – neu
- `app/__tests__/profileEdit.test.ts` – neu

## Akzeptanzkriterien
Vorher `app/src/logic/types.ts` und `app/src/logic/demoData.ts` lesen. Nichts ändert `data` selbst.
`profileEdit.ts`:
- `export function validateProfile(p: Profile): string[]` → Meldungen in dieser Reihenfolge:
  - `'Name muss 2 bis 20 Zeichen haben'`, wenn `p.name.trim()` kürzer als 2 oder länger als 20 ist
  - `'Alter muss zwischen 18 und 99 liegen'`, wenn `age` keine ganze Zahl von 18 bis 99 ist (`Number.isInteger`)
  - `'Trainingsjahre müssen zwischen 0 und 60 liegen'`, wenn `years` keine ganze Zahl von 0 bis 60 ist
  - `'Bitte eine Kampfsportart wählen'`, wenn `art` nicht in `ARTS`
  - `'Beschreibung höchstens 200 Zeichen'`, wenn `bio` länger als 200 ist
- `export function updateProfile(data: AppData, id: string, changes: Partial<Omit<Profile, 'id'>>): AppData` → Profil mit `id` suchen (sonst unverändert), `{ ...profil, ...changes }` bilden, `name` mit `trim()`; hat `validateProfile` Meldungen → unverändert; sonst das Profil in `profiles` ersetzen (Reihenfolge bleibt)

`perspective.ts`:
- `export function switchPerspective(data: AppData, id: string): AppData` → wenn es ein Profil mit `id` gibt: `activeId = id`, sonst unverändert
- `export function activeProfile(data: AppData): Profile` → Profil mit `data.activeId` (gibt es keins, das erste Profil)

## Tests
`app/__tests__/profileEdit.test.ts`:
- `gültiges Demoprofil`: `validateProfile(demoData().profiles[0])` leer
- `ungültige Angaben`: Name `'A'`, Alter 17, Jahre 61, Kampfsportart `'Fechten'`, Beschreibung mit 201 Zeichen → genau diese fünf Meldungen in der Reihenfolge oben
- `Profil ändern`: `updateProfile(d, 'p01', { name: '  Alexa ', years: 5 })` → `profiles[0].name` `'Alexa'`, `years` 5, `id` weiter `'p01'`, andere Profile unverändert
- `ungültige Änderung wird abgelehnt`: `updateProfile(d, 'p01', { age: 12 })` gibt dasselbe Objekt zurück (`toBe`)
- `unbekannte ID`: `updateProfile(d, 'p99', { years: 2 })` gibt dasselbe Objekt zurück
- `Perspektive wechseln`: `switchPerspective(d, 'p02').activeId` `'p02'`, `activeProfile` davon ist Sam; `switchPerspective(d, 'p99')` gibt dasselbe Objekt zurück

Review (21.10.2026): gemergt.
