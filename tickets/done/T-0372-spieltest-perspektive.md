---
id: T-0372
title: Spieltest „perspektive“ – Testperson über die Demo-Leiste wechseln, gegenseitiges Match
project: sparring
priority: 3
after: T-0332
---
## Ziel
Meilenstein „Swipe und Match“ (Abnahmekriterien 3 und 4): Ein Spieltest wechselt die Testperson über die Demo-Leiste wie ein Nutzer, bekundet aus beiden Perspektiven Interesse und prüft, dass erst das gegenseitige Interesse ein Match ergibt. Der Hub führt Spieltests aus; die Agents schreiben sie nur.

## Dateien
- `playtests/perspektive.gd` – neu

## Akzeptanzkriterien
- `extends Playtest`, im `_init()` `scene_path = "res://scenes/main.tscn"`, `describe()` liefert `"Testperson wechseln, gegenseitiges Interesse ergibt ein Match"`. Vorlage für den Aufbau: `playtests/start.gd`.
- Der Test benutzt **nur** die eigene Datei `const STORE := "user://spieltest_perspektive.json"`: zu Beginn `DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))`, dann `scene.use_store(STORE)`. Nie `user://sparring.json` anfassen.
- Ablauf in `run()` (zwischen den Schritten jeweils `await wait(0.3)`), Knöpfe per `pressed.emit()`:
  1. `check(scene.perspective.tag_label.text.contains("DEMO"), "Demo-Leiste beschriftet")`; `check(scene.state.active_id == "p01", "Start als Alex")`; `shot("start")`
  2. Als p01 Interesse an der ersten Karte: `var d := scene.screen as DiscoverScreen`, `check(d.current().id == "p02", "erste Karte ist p02")`, `d.like_button.pressed.emit()` → `check(scene.state.book.matches.is_empty(), "einseitiges Interesse ist kein Match")`
  3. Perspektive wechseln wie ein Nutzer: `scene.perspective.picker.select(1)`, `scene.perspective.picker.item_selected.emit(1)` → `check(scene.state.active_id == "p02", "jetzt Testperson p02")`; `check(scene.perspective.picker.get_item_text(1).begins_with("Du bist: "), "Eintrag beschriftet")`; `shot("perspektive")`
  4. Als p02 sich selbst nicht sehen: `d = scene.screen as DiscoverScreen`, `check(d.current().id != "p02", "eigene Karte wird nicht gezeigt")`
  5. Als p02 Interesse an p01: so oft `d.pass_button.pressed.emit()` (mit `await wait(0.1)`), bis `d.current() == null or d.current().id == "p01"` (höchstens 8 Mal), dann `d.like_button.pressed.emit()` → `check(scene.state.book.matches.size() == 1, "gegenseitiges Interesse ergibt ein Match")`; `check(d.match_label.visible, "Match-Hinweis sichtbar")`; `shot("match")`
  6. Zurückwechseln: `scene.perspective.picker.select(0)`, `scene.perspective.picker.item_selected.emit(0)` → `check(scene.state.active_id == "p01", "wieder Alex")`; `check(scene.state.my_matches().size() == 1, "Match auch aus Sicht von Alex")`
  7. Aufräumen: Datei `STORE` mit `DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))` löschen.
- Kein Netzwerk, keine Wartezeiten über 1 Sekunde.

## Tests
- Keine Unit-Tests; `verify.cmd` lädt die Datei mit und meldet Skriptfehler. Ausgeführt wird der Spieltest im Review (`hub\tools\spieltest.ps1 -Projekt sparring -Test perspektive`).

Review (19.10.2026): gemergt.
