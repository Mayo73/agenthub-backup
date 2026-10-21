---
id: T-0508
title: Treffen-Logik – Vorschlag prüfen und anlegen
project: sparring
priority: 2
---
## Ziel
React-Native-Neustart, Meilenstein „Treffen“: Ein Outdoor-Ort, Datum, Uhrzeit und Trainingsform werden vorgeschlagen. Jede Änderung eines Vorschlags setzt die Zustimmung zurück.

## Dateien
- `app/src/logic/meetings.ts` – neu
- `app/__tests__/meetings.test.ts` – neu

## Akzeptanzkriterien
Vorher `app/src/logic/types.ts` und `app/src/logic/demoData.ts` (`FORMS`, `INTENSITIES`) lesen. Zum Nachlesen: `scripts/meeting_book.gd` (alte Godot-Fassung). Diese Datei importiert nichts aus `matching.ts`, sondern sucht Matches selbst in `data.matches`. Nichts ändert `data` selbst.
- `export type MeetingDetails = { place: string; date: string; time: string; form: string; intensity: string; rules: string }`
- `export function emptyDetails(): MeetingDetails` → `place`, `date`, `time`, `rules` leer, `form: FORMS[0]`, `intensity: INTENSITIES[0]`
- `export function missingFields(details: MeetingDetails): string[]` → in dieser Reihenfolge: `'Ort'`, wenn `place.trim()` leer; `'Datum'`, wenn `date` nicht `TT.MM.JJJJ` ist (`/^\d{2}\.\d{2}\.\d{4}$/`, Tag 1–31, Monat 1–12); `'Uhrzeit'`, wenn `time` nicht `HH:MM` ist (Stunde 0–23, Minute 0–59); `'Trainingsform'`, wenn `form` nicht in `FORMS`; `'Intensität'`, wenn `intensity` nicht in `INTENSITIES`
- `export function meetingOf(data: AppData, matchId: string): Meeting | undefined`
- `export function propose(data: AppData, matchId: string, by: string, details: MeetingDetails): AppData`: unverändert, wenn `missingFields` nicht leer ist, das Match nicht existiert, beendet ist oder `by` nicht darin vorkommt. Felder vorher mit `trim()` säubern. Gibt es noch keinen Vorschlag: neuen `Meeting` anhängen mit `proposedBy: by`, `approved: [by]`, `cancelledBy: ''`. Gibt es einen: sind alle sechs Felder gleich und ist er nicht abgesagt → unverändert; sonst ersetzen mit den neuen Feldern, `proposedBy: by`, `approved: [by]`, `cancelledBy: ''`

## Tests
`app/__tests__/meetings.test.ts`. Hilfen im Test: `withMatch()` = `demoData()` mit Match `{ id: 'm1', a: 'p01', b: 'p02', endedBy: '' }`; `details()` = `{ place: 'Stadtpark, große Wiese', date: '24.10.2026', time: '10:00', form: 'Techniktraining', intensity: 'locker', rules: 'Nur Technik, kein Vollkontakt' }`.
- `vollständige Angaben`: `missingFields(details())` leer
- `fehlende Angaben`: `missingFields(emptyDetails())` → `['Ort', 'Datum', 'Uhrzeit']`
- `ungültige Werte`: Datum `'32.10.2026'`, `'1.10.2026'`, Uhrzeit `'24:00'`, `'9:5'` werden je gemeldet
- `Vorschlag anlegen`: `propose(withMatch(), 'm1', 'p01', details())` → `meetingOf` hat `approved: ['p01']`, `proposedBy: 'p01'`, `cancelledBy: ''`
- `unvollständig wird abgelehnt`: `propose` mit `emptyDetails()` gibt dasselbe Objekt zurück (`toBe`)
- `Unbeteiligte und beendete Matches`: Vorschlag von p03 bzw. bei `endedBy: 'p01'` → dasselbe Objekt
- `Änderung setzt Zustimmung zurück`: Vorschlag von p01, dann `approved` auf einer Kopie `['p01', 'p02']` setzen, dann `propose` von p02 mit `time: '11:00'` → `approved` `['p02']`, `time` `'11:00'`, weiterhin nur ein Meeting
- `gleicher Vorschlag ändert nichts`: zweimal derselbe Vorschlag von p01 → beim zweiten dasselbe Objekt

Review (21.10.2026): gemergt, nachgebessert: meetings.ts exportiert MeetingDetails (lag nur in types.ts).
