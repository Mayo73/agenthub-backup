---
id: T-0346
title: Abnahmetests der Logik (Kriterien 1–9)
project: sparring
priority: 3
after: T-0337
---
## Ziel
Meilenstein „Abnahme“: Die Abnahmekriterien des Lastenhefts, soweit sie die Logik betreffen, als eigene, gut lesbare Tests an einer Stelle. Nur neue Testdatei, kein Programmcode.

## Dateien
- `tests/test_abnahme.gd` – neu

## Akzeptanzkriterien
- Neue Datei `tests/test_abnahme.gd`, `extends "res://tests/base_test.gd"`, `const PATH := "user://test_abnahme.json"`; `teardown()` löscht die Datei, falls vorhanden (`DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))`).
- Hilfsfunktion `func mutual(state: AppState, a: String, b: String) -> String`: als `a` `like(b)`, `switch_to(b)`, `like(a)` (Rückgabe merken), `switch_to(a)`, Match-ID zurückgeben.
- Gültige Treffangaben als Konstante `const OK := {"place": "Stadtpark, Wiese am Teich", "date": "24.10.2026", "time": "10:30", "form": "Drills"}`.
- Kein Test schreibt nach `user://sparring.json`.

## Tests
- `test_k1_acht_testprofile`: `AppState.demo().profiles.size() >= 8`; unter den Sportarten „Jiu-Jitsu“, „MMA“, „Boxen“; alle `age >= 18`
- `test_k2_profil_nach_neustart`: Profil p01 als Kopie mit `name = "Alexa"` per `update_profile`, `StateStore.save(state, PATH)` → `StateStore.load_state(PATH).profile("p01").name` „Alexa“
- `test_k3_match_erst_gegenseitig`: als p01 `like("p02")` → `""` und `my_matches()` leer; als p02 `my_matches()` leer; als p02 `like("p01")` → nicht leer; genau ein Match in `book.matches`; aus beiden Perspektiven `my_matches().size()` 1
- `test_k4_verschiedene_sportarten`: p01 (Jiu-Jitsu) und p02 (MMA): `mutual` liefert eine Match-ID
- `test_k5_chat_nur_fuer_beteiligte`: Match p01/p02, als p01 `send_message` „Hallo“, als p02 `send_message` „Hi“ → `chat.count_for` 2; als p03 `my_matches()` leer und `send_message(id, "x")` falsch
- `test_k6_treffen_beide_zustimmen`: Match, als p01 `propose_meeting(id, OK)` → `[]`, nicht bestätigt; als p02 `approve_meeting` → bestätigt; als p02 Vorschlag mit `time` „11:00“ → nicht bestätigt; als p01 `approve_meeting` → wieder bestätigt
- `test_k7_beenden_und_absagen`: Match mit bestätigtem Treffen; als p02 `cancel_meeting` → als p01 `meetings.is_cancelled` wahr; als p01 `end_match` → als p02 Match in `my_matches()` mit `ended_by` „p01“, `send_message` falsch, `propose_meeting(id, OK)` gleich `["Match ist beendet"]`
- `test_k9_neustart_und_zuruecksetzen`: Match, Nachricht, bestätigtes Treffen, `save(state, PATH)` → geladen: 1 Match, 1 Nachricht, `meeting_confirmed` wahr; `StateStore.reset(PATH)` → keine Matches, keine Nachrichten, `profile("p01").name` „Alex“, `active_id` „p01“
