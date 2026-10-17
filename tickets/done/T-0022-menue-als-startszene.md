---
id: T-0022
title: Hauptmenü als Startszene
project: drift
priority: 3
after: T-0018, T-0021
---
## Ziel
Das Spiel startet ab jetzt im Hauptmenü statt direkt im Rennen.

## Dateien
- `project.godot`: nur die eine Zeile unten ändern (das Ticket verlangt es ausdrücklich)
- `tests/test_main_menu.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- In `project.godot` im Abschnitt `[application]` die Zeile `run/main_scene="res://scenes/main.tscn"` ersetzen durch `run/main_scene="res://scenes/main_menu.tscn"`. Sonst nichts an `project.godot` ändern.

## Tests
In `tests/test_main_menu.gd` neue Methode `test_startszene_ist_menue` anhängen: `ProjectSettings.get_setting("application/run/main_scene")` ist `"res://scenes/main_menu.tscn"`.

Review (16.10.2026): gemergt.
