---
id: T-0361
title: Spieltest „wischen“ – Wischen und Knöpfe verhalten sich gleich
project: sparring
priority: 3
after: T-0338
---
## Ziel
Meilenstein „Abnahme“ (Abnahmekriterium 4): Ein Spieltest bedient den Entdecken-Bildschirm abwechselnd per Wischgeste und per Knopf und prüft, dass beides dasselbe bewirkt; zum Schluss matchen sich Jiu-Jitsu (Alex) und MMA (Sam). Der Hub führt Spieltests aus; die Agents schreiben sie nur.

## Dateien
- `playtests/wischen.gd` – neu

## Akzeptanzkriterien
- `extends Playtest`, `scene_path = "res://scenes/main.tscn"` (in `_init()`), `describe()` liefert `"Wischen und Knöpfe bewirken dasselbe, Jiu-Jitsu und MMA matchen"`. Vorlage für den Aufbau: `playtests/start.gd`.
- Eigene Datei `const STORE := "user://spieltest_wischen.json"`: zu Beginn von `run()` löschen, falls vorhanden (`DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))`), dann `scene.use_store(STORE)`; am Ende wieder löschen. Nie `user://sparring.json` anfassen.
- Ablauf in `run()`, zwischen den Schritten `await wait(0.3)`; `var d := scene.screen as DiscoverScreen` nach jedem Bildschirmwechsel neu holen:
  1. Als Alex (p01): `d.swipe(Vector2(100, 600), Vector2(450, 610))` → `check(scene.state.book.likes.has("p01>p02"), "Wischen nach rechts = Interesse")`
  2. `d.swipe(Vector2(450, 600), Vector2(100, 600))` → `check(scene.state.book.passes.has("p01>p03"), "Wischen nach links = Überspringen")`
  3. `d.like_button.pressed.emit()` → `check(scene.state.book.likes.has("p01>p04"), "Knopf Interesse")`
  4. `d.pass_button.pressed.emit()` → `check(scene.state.book.passes.has("p01>p05"), "Knopf Überspringen")`
  5. Kurzes Wischen `d.swipe(Vector2(100, 600), Vector2(140, 600))` → `check(d.current().id == "p06", "Kurzes Wischen ändert nichts")`; `shot("entdecken")`
  6. `scene._on_switched("p02")`; neu holen; so oft `pass_button` drücken, bis `d.current().id == "p01"` (höchstens 8-mal); dann `d.swipe(Vector2(100, 600), Vector2(450, 610))` → `check(scene.state.my_matches().size() == 1, "Jiu-Jitsu und MMA matchen per Wischen")`, `check(d.match_label.visible, "Match-Hinweis sichtbar")`; `shot("match")`
- Keine Wartezeiten über 1 Sekunde.

## Tests
- Keine Unit-Tests; `verify.cmd` lädt die Datei mit und meldet Skriptfehler. Ausgeführt wird der Spieltest im Review (`hub\tools\spieltest.ps1 -Projekt sparring -Test wischen`).

Review (19.10.2026): gemergt.
