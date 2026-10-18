---
id: T-0319
title: Spieltest Fischphase – Laternenfische in der Tiefe
project: zellenphase
priority: 3
after: T-0318, T-0312
---
## Ziel
Auftrag „Fischphase – lebendige Welt“: Ein Spieltest taucht in die Tiefe und prüft, dass dort leuchtende Laternenfische schwimmen. Das Standbild dient als Material zum Ansehen.

## Dateien
- `playtests/fisch_tiefsee.gd` – neu

## Akzeptanzkriterien
Neue Datei `playtests/fisch_tiefsee.gd`, Aufbau wie `playtests/fisch_tod.gd`:
- `extends "res://playtests/playtest.gd"`; in `_init()`: `scene_path = "res://scenes/fish.tscn"`; `describe()` gibt `"Fischphase: Laternenfische in der Tiefe"` zurück
- `run()`:
  1. `await wait(0.5)`; `scene.intro.close()`
  2. `var lanterns: Array = scene.fishes.filter(func(f) -> bool: return f.species_id == "laternenfisch")`
  3. `check(lanterns.size() == 3, "Drei Laternenfische im Meer")`
  4. Wenn `lanterns` leer ist: `return`
  5. `scene.player.motion.position = lanterns[0].motion.position + Vector3(0, 2, 6)`; `scene.player.sync()`
  6. `await wait(1.5)`
  7. `shot("tiefsee")`
  8. `check(scene.player.motion.depth() > 40.0, "Der Spielerfisch ist in der Tiefe")`
  9. `check(lanterns[0].has_node("Glow"), "Der Laternenfisch leuchtet")`
  10. `measure("tiefe", scene.player.motion.depth())`
- Sonst nichts ändern.

## Tests
Keine Unit-Tests: Spieltests laufen nicht in `verify.cmd`. Der Test muss fehlerfrei geladen werden können (keine Skriptfehler).

Review (18.10.2026): gemergt.
