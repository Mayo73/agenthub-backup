---
id: T-0327
title: StateStore – Zustand speichern, laden, zurücksetzen
project: sparring
priority: 3
after: T-0326
---
## Ziel
Meilenstein „Demodaten und Profil“: Profiländerungen, Interessen, Matches, Nachrichten und Termine bleiben nach einem Neustart erhalten (Abnahmekriterien 2 und 9). Zurücksetzen stellt die ursprünglichen Testdaten wieder her.

## Dateien
- `scripts/state_store.gd` – neu, Klasse `StateStore`
- `tests/test_state_store.gd` – neu

## Akzeptanzkriterien
`class_name StateStore`, `extends RefCounted`:
- `const DEFAULT_PATH := "user://sparring.json"`
- `static func save(state: AppState, path: String = DEFAULT_PATH) -> bool`: `JSON.stringify(state.to_dict(), "\t")` mit `FileAccess.open(path, FileAccess.WRITE)` schreiben; `false`, wenn die Datei nicht geöffnet werden kann.
- `static func load_state(path: String = DEFAULT_PATH) -> AppState`: Datei lesen und mit `JSON.parse_string` einlesen. Fehlt die Datei, ist sie kaputt (kein Dictionary) oder ist `version` nicht 1 → `AppState.demo()`. Sonst `AppState.from_dict(...)`.
- `static func reset(path: String = DEFAULT_PATH) -> AppState`: Datei löschen, falls vorhanden (`DirAccess.remove_absolute`), dann `AppState.demo()` speichern und zurückgeben.
- Wichtig: JSON liefert Zahlen als `float`. `from_dict` der Klassen wandelt mit `int(...)` um; falls dabei in `AppState`, `MatchBook`, `ChatLog`, `MeetingBook` oder `SparProfile` etwas fehlt, dort ergänzen, damit die Tests unten grün sind.

## Tests
`tests/test_state_store.gd` mit `const PATH := "user://test_state_store.json"`; `teardown()` löscht die Datei mit `DirAccess.remove_absolute(PATH)`:
- `test_ohne_datei_demo`: `load_state(PATH)` → 8 Profile, `active_id` „p01“
- `test_neustart_behaelt_alles` (Kriterien 2 und 9): Demo-Zustand; Profil p01 mit `name = "Alexa"` und `bio = "Neu"` per `update_profile`; Match p01/p02 (beide liken über `switch_to`); als p02 Nachricht „Hallo“; Treffen vorschlagen und von beiden bestätigen; `save(state, PATH)`. Dann `load_state(PATH)`: Name „Alexa“, Bio „Neu“, `my_matches().size()` 1 (als p02), `chat.count_for("m1")` 1, `meeting_confirmed("m1")` wahr, `active_id` „p02“, `profile("p01").level` ist vom Typ `int` (`typeof(...) == TYPE_INT`)
- `test_kaputte_datei`: Text „kein json“ in die Datei schreiben → `load_state(PATH)` liefert Demo-Zustand
- `test_zuruecksetzen` (Kriterium 9): veränderten Zustand speichern, `reset(PATH)` → Rückgabe hat keine Matches und `profile("p01").name` „Alex“; `load_state(PATH)` ebenso
