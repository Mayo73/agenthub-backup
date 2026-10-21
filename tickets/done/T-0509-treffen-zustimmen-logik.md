---
id: T-0509
title: Treffen-Logik – zustimmen, bestätigt, absagen, Status
project: sparring
priority: 2
after: T-0508
---
## Ziel
React-Native-Neustart, Meilenstein „Treffen“: Ein Treffen ist erst bestätigt, wenn beide zugestimmt haben. Absagen ist jederzeit möglich und für beide sichtbar.

## Dateien
- `app/src/logic/meetings.ts` – ergänzen
- `app/__tests__/meetings.test.ts` – Tests ergänzen

## Akzeptanzkriterien
Vorher `app/src/logic/meetings.ts` lesen. Nichts ändert `data` selbst.
- `export function approve(data: AppData, matchId: string, userId: string): AppData` → nur wenn der Vorschlag existiert, nicht abgesagt ist, das Match aktiv ist, `userId` darin vorkommt und noch nicht in `approved` steht: `userId` an `approved` anhängen; sonst unverändert
- `export function isConfirmed(data: AppData, matchId: string): boolean` → Vorschlag existiert, `cancelledBy === ''`, und sowohl `a` als auch `b` des Matches stehen in `approved`
- `export function cancel(data: AppData, matchId: string, by: string): AppData` → nur wenn der Vorschlag existiert, `by` im Match vorkommt und er noch nicht abgesagt ist: `cancelledBy = by`
- `export function meetingStatus(data: AppData, matchId: string, viewerId: string): string`, Namen aus `data.profiles`:
  - kein Vorschlag → `'Noch kein Vorschlag'`
  - abgesagt von `viewerId` → `'Von dir abgesagt'`, sonst `` `Abgesagt von ${name}` ``
  - bestätigt → `'Bestätigt von beiden'`
  - `viewerId` hat zugestimmt → `` `Wartet auf Zustimmung von ${nameDesAnderen}` ``
  - sonst → `'Wartet auf deine Zustimmung'`

## Tests
In `app/__tests__/meetings.test.ts` ergänzen (Hilfen `withMatch()` und `details()` von dort):
- `erst nach beiden Zustimmungen bestätigt`: Vorschlag von p01 → `isConfirmed` falsch; `approve(d, 'm1', 'p02')` → wahr
- `Status aus beiden Perspektiven`: nach dem Vorschlag von p01: für p01 `'Wartet auf Zustimmung von Sam'`, für p02 `'Wartet auf deine Zustimmung'`; nach Zustimmung für beide `'Bestätigt von beiden'`
- `Änderung nach Bestätigung`: bestätigt, dann `propose` von p02 mit anderem Ort → `isConfirmed` falsch, Status für p01 `'Wartet auf deine Zustimmung'`
- `Absage`: bestätigt, dann `cancel(d, 'm1', 'p02')` → `isConfirmed` falsch, Status für p01 `'Abgesagt von Sam'`, für p02 `'Von dir abgesagt'`
- `nach Absage keine Zustimmung`: `approve` nach `cancel` gibt dasselbe Objekt zurück (`toBe`)
- `neuer Vorschlag nach Absage`: `propose` nach `cancel` → `cancelledBy` `''`, `approved` nur der Vorschlagende
- `Unbeteiligte`: `approve` und `cancel` von p03 geben dasselbe Objekt zurück
- `ohne Vorschlag`: `meetingStatus(withMatch(), 'm1', 'p01')` → `'Noch kein Vorschlag'`

Review (21.10.2026): gemergt.
