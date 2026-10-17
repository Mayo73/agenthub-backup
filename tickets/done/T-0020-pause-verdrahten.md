---
id: T-0020
title: Pausemenü in die Rennszene einbauen
project: drift
priority: 3
after: T-0016, T-0019
---
## Ziel
Die Rennszene bekommt das Pausemenü aus T-0019. „Neustart“ im Pausemenü startet ein neues Rennen über das vorhandene `restart()`.

## Dateien
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neuen Test anhängen, bestehende nicht ändern
- `scenes/main.tscn` **nicht** ändern, das Menü wird im Code angelegt.

## Akzeptanzkriterien
- Neue Variable in `main.gd`: `var pause_menu: CanvasLayer`
- Am Ende von `_ready()`:
  ```gdscript
  pause_menu = preload("res://scenes/pause_menu.tscn").instantiate()
  add_child(pause_menu)
  pause_menu.restart_requested.connect(restart)
  ```
- Sonst nichts an `main.gd` ändern.

## Tests
In `tests/test_main_wiring.gd` neue Methode `test_pausemenue_ist_verdrahtet` anhängen:
- `main.get_node("PauseMenu") != null` ist wahr
- `main.pause_menu.restart_requested.is_connected(main.restart)` ist wahr
- `main.race.phase = RaceState.Phase.FINISHED`, `main.pause_menu._on_restart()` → `main.race.phase` ist `RaceState.Phase.COUNTDOWN` und `main.get_tree().paused` ist falsch

Review (16.10.2026): gemergt, nachgebessert: Fortsetzungszeilen im Test mit Leerzeichen statt Tabs eingerückt.
