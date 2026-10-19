---
id: T-0367
title: StateStore – Zustand speichern, laden, zurücksetzen (2. Anlauf)
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

## Hinweise aus dem ersten Anlauf (T-0327)
- **Fehler im Test:** `like()` liefert die Match-ID erst beim *zweiten*, gegenseitigen Like. Das erste `state.like("p02")` als p01 gibt "" zurück. In `test_neustart_behaelt_alles` also: als p01 `state.like("p02")`, dann `state.switch_to("p02")` und `var m1 := state.like("p01")` (jetzt "m1"). Danach als p02 `state.send_message(m1, "Hallo")`, Treffen als p02 mit `{"place": "Stadtpark", "date": "15.11.2026", "time": "18:00", "form": "Techniktraining", "intensity": "locker", "rules": ""}` vorschlagen, `switch_to("p01")`, `approve_meeting(m1)`, `switch_to("p02")`, dann speichern.
- **Datei löschen im `teardown()`:** einfach `DirAccess.remove_absolute(PATH)` (keine Prüfung über `DirAccess.open` nötig).
- Keine Datei `test_debug.gd` im Projektordner anlegen; nur die Dateien unter „Dateien“ und, falls nötig, die genannten `from_dict`-Stellen.

Review (18.10.2026): selbst umgesetzt (Agent-Läufe scheiterten an Ollama: Vulkan-Speicher beim Laden des Modells voll), StateStore mit 5 Tests, dazu Gewichtsklasse nach JSON-Laden repariert.
