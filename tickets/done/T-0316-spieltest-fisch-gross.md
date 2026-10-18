---
id: T-0316
title: Spieltest Fischphase – Raubfisch flieht vor großem Spielerfisch
project: zellenphase
priority: 3
after: T-0310
---
## Ziel
Auftrag „Fischphase – lebendige Welt“: Ein Spieltest zeigt im laufenden Spiel, dass ein Zackenbarsch vor einem ausgewachsenen Spielerfisch flieht (Regel aus T-0310).

## Dateien
- `playtests/fisch_gross.gd` – neu

## Akzeptanzkriterien
Neue Datei `playtests/fisch_gross.gd`, Aufbau wie `playtests/fisch_tod.gd`:
- `extends "res://playtests/playtest.gd"`; in `_init()`: `scene_path = "res://scenes/fish.tscn"`; `describe()` gibt `"Fischphase: Raubfisch flieht vor großem Fisch"` zurück
- `run()`:
  1. `await wait(0.5)`; `scene.intro.close()`; alle KI-Fische entfernen (`for f in scene.fishes.duplicate(): scene.remove_fish(f)`)
  2. `scene.progress.stage = 3`; `scene.player.set_size(scene.progress.size())`
  3. `var hunter = scene.add_fish("zackenbarsch", scene.player.motion.position + Vector3(0, 0, -10))`
  4. `var start_dist: float = hunter.motion.position.distance_to(scene.player.motion.position)`
  5. `await wait(3.0)`
  6. `var end_dist: float = hunter.motion.position.distance_to(scene.player.motion.position)`
  7. `shot("flucht")`
  8. `check(end_dist > start_dist + 3.0, "Der Zackenbarsch schwimmt vom großen Fisch weg")`
  9. `measure("abstand_start", start_dist)`; `measure("abstand_ende", end_dist)`
- Sonst nichts ändern.

## Tests
Keine Unit-Tests: Spieltests laufen nicht in `verify.cmd`. Der Test muss fehlerfrei geladen werden können (keine Skriptfehler).

Review (18.10.2026): gemergt.
