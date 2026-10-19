---
id: T-0349
title: Spieltest „zuruecksetzen“ – Profil nach Neustart, Zurücksetzen mit Rückfrage
project: sparring
priority: 3
after: T-0342
---
## Ziel
Meilenstein „Abnahme“ (Abnahmekriterien 2 und 9): Ein Spieltest ändert das eigene Profil, startet die App neu und prüft, dass die Änderung erhalten bleibt. Danach setzt er die Demo über den Profil-Reiter mit Rückfrage zurück und prüft den Ausgangszustand. Der Hub führt Spieltests aus; die Agents schreiben sie nur.

## Dateien
- `playtests/zuruecksetzen.gd` – neu

## Akzeptanzkriterien
- `extends Playtest`, `scene_path = "res://scenes/main.tscn"`, `describe()` liefert `"Profil nach Neustart, Zurücksetzen mit Rückfrage"`. Vorlage für den Aufbau: `playtests/start.gd`.
- Der Test benutzt **nur** die eigene Datei `const STORE := "user://spieltest_zuruecksetzen.json"`: zu Beginn `DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))` (falls vorhanden), dann `scene.use_store(STORE)`. Nie `user://sparring.json` anfassen.
- Ablauf in `run()` (zwischen den Schritten jeweils `await wait(0.3)`), Knöpfe per `pressed.emit()`:
  1. Profil ändern: `scene.show_screen("profil")`, `(scene.screen as ProfileScreen).name_edit.text = "Alexa"`, `save_button` → `check(scene.state.active().name == "Alexa", "Name geändert")`; `shot("profil")`
  2. Ein Match anlegen: `scene.state.like("p02")`, `scene._on_switched("p02")`, `scene.state.like("p01")`, `scene._on_switched("p01")`, `scene.save()`
  3. Neustart: `await reload_scene()`, danach `scene.use_store(STORE)` → `check(scene.state.profile("p01").name == "Alexa", "Profiländerung nach Neustart erhalten")`; `check(scene.state.book.matches.size() == 1, "Match nach Neustart erhalten")`
  4. Zurücksetzen abbrechen: `scene.show_screen("profil")`, `reset_button` → `check((scene.screen as ProfileScreen).dialog.visible, "Rückfrage erscheint")`; `shot("rueckfrage")`; `dialog.cancel_button` → `check(scene.state.book.matches.size() == 1, "Abbrechen ändert nichts")`
  5. Zurücksetzen bestätigen: `reset_button`, `dialog.ok_button` → `check(scene.state.profile("p01").name == "Alex", "Name wieder Alex")`; `check(scene.state.book.matches.is_empty(), "keine Matches mehr")`; `check(scene.state.active_id == "p01", "aktive Person wieder Alex")`; `check(scene.current_screen == "entdecken", "zurück im Entdecken")`
  6. Leerzustand: `scene.show_screen("matches")` → `check((scene.screen as MatchesScreen).empty_label.visible, "Leerzustand ohne Matches")`; `shot("leer")`
  7. Aufräumen: Datei `STORE` löschen.
- Kein Netzwerk, keine Wartezeiten über 1 Sekunde.

## Tests
- Keine Unit-Tests; `verify.cmd` lädt die Datei mit und meldet Skriptfehler. Ausgeführt wird der Spieltest im Review (`hub\tools\spieltest.ps1 -Projekt sparring -Test zuruecksetzen`).

Review (19.10.2026): gemergt.
