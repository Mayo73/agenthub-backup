---
id: T-0016
title: Geisterauto in main.gd verdrahten
project: drift
priority: 3
after: T-0015
---
## Ziel
Während des Rennens wird jede Runde aufgenommen. Ist eine Runde schneller als die bisher beste Aufnahme, wird sie zum Geisterauto, das ab der nächsten Runde mitfährt. Die beste Aufnahme bleibt auch nach einem Neustart erhalten.

## Dateien
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neuen Test anhängen, bestehende nicht ändern
- `scenes/main.tscn` **nicht** ändern, der Node wird im Code angelegt.

## Akzeptanzkriterien
- Neue Variablen in `main.gd`: `var ghost: Node2D`, `var ghost_best: GhostLap = null`, `var ghost_recording := GhostLap.new()`
- Am Ende von `_ready()`:
  ```gdscript
  ghost = preload("res://scripts/ghost_car.gd").new()
  ghost.name = "Ghost"
  world.add_child(ghost)
  world.move_child(ghost, car.get_index())
  ```
- In `_physics_process`, im Block `if race.phase == RaceState.Phase.RACING:` **nach** `lap_timer.update(...)`:
  ```gdscript
  ghost_recording.record(lap_timer.current_time, car.physics.position, car.physics.heading)
  ```
- Direkt nach diesem `if`-Block (also in jeder Phase): `ghost.show_at(ghost_best, lap_timer.current_time)`
- In `_on_lap_completed(_lap_number, time, _is_best)` vor `race.on_lap(time)`:
  ```gdscript
  if ghost_best == null or time < ghost_best.duration():
  	ghost_best = ghost_recording
  ghost_recording = GhostLap.new()
  ```
- In `restart()` zusätzlich: `ghost_recording = GhostLap.new()` (`ghost_best` bleibt erhalten)
- Sonst nichts an `main.gd` ändern.

## Tests
In `tests/test_main_wiring.gd` neue Methode `test_geisterauto_ist_verdrahtet` anhängen:
- `main.get_node("World/Ghost") != null` ist wahr
- `main.ghost_best == null` ist wahr
- `main.ghost_recording.record(0.0, Vector2.ZERO, 0.0)`, dann `main._on_lap_completed(1, 30.0, true)` → `main.ghost_best != null` ist wahr und `main.ghost_recording.is_empty()` ist wahr
- `var first: GhostLap = main.ghost_best`, dann `main.restart()` → `main.ghost_best == first` ist wahr

Review (16.10.2026): gemergt.
