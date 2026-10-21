---
id: T-0528
title: Abnahmetest – Treffen, Beenden, Neustart und Zurücksetzen
project: sparring
priority: 2
after: T-0527
---
## Ziel
React-Native-Neustart, Meilenstein „Abnahme“: Ein Test bedient die ganze App und prüft die Abnahmekriterien 2, 6, 7 und 9.

## Dateien
- `app/__tests__/abnahme-treffen.test.tsx` – neu (nur diese Datei; App-Code nur ändern, wenn der Test einen echten Fehler zeigt, dann im Bericht erklären)

## Akzeptanzkriterien
Vorher `app/__tests__/abnahme-match.test.tsx` lesen und dessen Aufbau übernehmen (Speicher in `beforeEach` leeren, `<App />` rendern, nur echte Bedienelemente). Eine Hilfsfunktion `matchHerstellen()` im Test: Alex `btn-like`, Wechsel zu Sam, `btn-like`, `match-close`.

## Tests
`app/__tests__/abnahme-treffen.test.tsx`:
- `K6 Treffen erst nach beiden Zustimmungen, Änderung verlangt neue`: `matchHerstellen()`; als Sam Reiter Matches, `match-row-m1`, `chat-meeting`; Ort, Datum `'24.10.2026'`, Uhrzeit `'10:00'` eingeben, `meet-propose` → `meet-status` `'Wartet auf Zustimmung von Alex'`; zurück (`meet-back`, `chat-back`), Wechsel zu Alex, Matches, `match-row-m1`, `chat-meeting` → `meet-approve` → `'Bestätigt von beiden'`; `meet-time` `'11:00'`, `meet-propose` → `'Wartet auf Zustimmung von Sam'`
- `K7 Absage und Beenden aus beiden Perspektiven`: `matchHerstellen()`, Vorschlag als Sam wie oben, `meet-cancel`, `confirm-yes` → `'Von dir abgesagt'`; Wechsel zu Alex → im Treffen `meet-status` `'Abgesagt von Sam'`; im Chat `chat-end`, `confirm-yes` → `chat-ended`, kein `chat-input`, kein `chat-meeting`; Wechsel zu Sam, Matches → Text `'Beendet'`; `match-row-m1` → `chat-ended-by` `'Von Alex beendet.'`
- `K2 und K9 Neustart behält alles`: `matchHerstellen()`, als Sam im Chat `'Hallo'` senden, Profil bearbeiten: Name `'Samuel'`, `edit-save`; dann `unmount()` und `<App />` neu rendern → Reiter Profil zeigt (nach `findByText`) `'Samuel, 33'`; Reiter Matches → Text `'Hallo'`
- `K9 Zurücksetzen stellt den Ausgangszustand her`: wie oben Daten erzeugen, Reiter Profil, `reset-data`, `confirm-yes` → `'Alex, 29'`; Reiter Matches → `matches-empty`; Reiter Entdecken → `'Sam, 33'`
