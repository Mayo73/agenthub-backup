---
id: T-0523
title: Treffen – zustimmen, absagen und Status anzeigen
project: sparring
priority: 2
after: T-0522
---
## Ziel
React-Native-Neustart, Meilenstein „Treffen“: Beide Testpersonen sehen den Stand des Vorschlags, stimmen zu oder sagen ab. Bestätigt ist ein Treffen erst nach beiden Zustimmungen (Abnahmekriterium 6).

## Dateien
- `app/src/screens/MeetingScreen.tsx` – Status, Zustimmen, Absagen
- `app/src/screens/ChatScreen.tsx` – Statuszeile im Kopf
- `app/__tests__/MeetingFlow.test.tsx` – neu

## Akzeptanzkriterien
Vorher `app/src/screens/MeetingScreen.tsx`, `app/src/screens/ChatScreen.tsx`, `app/src/logic/meetings.ts` und `app/src/components/ConfirmDialog.tsx` lesen.
- `MeetingScreen` oben unter dem Kopf: `testID="meet-status"` mit `meetingStatus(data, matchId, me)`; bei `isConfirmed` grün (`colors.like`) mit zusätzlicher Zeile „Die Teilnahme bleibt freiwillig.“
- Knopf `testID="meet-approve"` „Zustimmen“ (Hintergrund `colors.like`), nur sichtbar, wenn ein Vorschlag existiert, er nicht abgesagt ist und `me` noch nicht in `approved` steht → `update(d => approve(d, matchId, me))`
- Knopf `testID="meet-cancel"` „Treffen absagen“ (Text `colors.pass`), nur sichtbar bei vorhandenem, nicht abgesagtem Vorschlag → `ConfirmDialog` (Titel „Treffen absagen?“, Text „Die andere Person sieht die Absage.“, `confirmLabel` „Absagen“) → `update(d => cancel(d, matchId, me))`
- Ist das Match beendet: Formular und Knöpfe ausblenden, stattdessen „Dieses Match wurde beendet.“
- Nach dem Speichern einer Änderung an einem bestehenden Vorschlag aktualisiert sich `meet-status` (kommt aus den Daten, nicht aus dem Formular)
- `ChatScreen`: unter dem Namen im Kopf eine kleine Zeile `testID="chat-meeting-status"` mit `meetingStatus(data, matchId, me)`, nur wenn ein Vorschlag existiert

## Tests
`app/__tests__/MeetingFlow.test.tsx` (in `AppDataProvider`; Speicher: `demoData()` mit Match `m1` p01–p02 und Meeting `{ matchId: 'm1', place: 'Uferweg', date: '24.10.2026', time: '10:00', form: 'Drills', intensity: 'locker', rules: '', proposedBy: 'p01', approved: ['p01'], cancelledBy: '' }`):
- `wartet auf die andere Person`: aktiv p01 → `meet-status` `'Wartet auf Zustimmung von Sam'`, kein `meet-approve`
- `zustimmen bestätigt`: aktiv p02 → `meet-status` `'Wartet auf deine Zustimmung'`; `meet-approve` drücken → `'Bestätigt von beiden'` und Text `'Die Teilnahme bleibt freiwillig.'`
- `Änderung verlangt neue Zustimmung`: aktiv p02, Meeting mit `approved: ['p01', 'p02']`; in `meet-time` `'11:00'` eingeben, `meet-propose` → `meet-status` `'Wartet auf Zustimmung von Alex'`
- `absagen`: aktiv p01, `meet-cancel`, dann `confirm-yes` → `meet-status` `'Von dir abgesagt'`, kein `meet-cancel`
- `Status im Chat`: `ChatScreen` mit aktiv p02 → `chat-meeting-status` `'Wartet auf deine Zustimmung'`

Review (21.10.2026): nach 5 Fehlversuchen von Claude selbst umgesetzt (Agent scheiterte an Typfehlern im Test und veränderte demoData.ts). 149 Tests grün.
