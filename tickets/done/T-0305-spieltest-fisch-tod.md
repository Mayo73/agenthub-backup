---
id: T-0305
title: Spieltest Fischphase – vom Raubfisch gefressen und Wiedereinstieg
project: zellenphase
priority: 3
---
## Ziel
Ein Spieltest prüft wie ein Spieler, dass der Spielerfisch stirbt, wenn ein Zackenbarsch ihn beißt, und danach an der Startstelle mit voller Gesundheit und unveränderter DNA weiterschwimmt. Die Agents schreiben den Test, ausgeführt wird er im Review.

## Dateien
- `playtests/fisch_tod.gd` – neu

## Akzeptanzkriterien
Neue Datei `playtests/fisch_tod.gd`, Aufbau wie `playtests/fisch_jagd.gd`:
- `extends "res://playtests/playtest.gd"`; in `_init()`: `scene_path = "res://scenes/fish.tscn"`; `describe()` gibt `"Fischphase: vom Raubfisch gefressen, Wiedereinstieg"` zurück
- `run()`:
  1. `await wait(0.5)`; `scene.intro.close()`; alle KI-Fische entfernen (`for f in scene.fishes.duplicate(): scene.remove_fish(f)`)
  2. `scene.progress.dna = 25`; `scene.player.motion.position = FishWorld.START + Vector3(40, 0, 0)`; `scene.player.sync()`; `scene.player_health.hp = 10.0`
  3. `scene.add_fish("zackenbarsch", scene.player.motion.position + Vector3(0, 0, -12))`
  4. `await until(func() -> bool: return scene.deaths >= 1, 10.0, "Der Zackenbarsch frisst den Spielerfisch")`
  5. `shot("wiedereinstieg")`
  6. `check(scene.player.motion.position.distance_to(FishWorld.START) < 3.0, "Der Fisch taucht an der Startstelle wieder auf")`
  7. `check(scene.player_health.hp > 90.0, "Nach dem Wiedereinstieg volle Gesundheit")`
  8. `check(scene.progress.dna == 25, "DNA bleibt nach dem Tod erhalten")`
  9. `measure("tode", scene.deaths)`
- Sonst nichts ändern.

## Tests
Keine Unit-Tests: Spieltests laufen nicht in `verify.cmd`. Der Test muss fehlerfrei geladen werden können (keine Skriptfehler), sonst scheitert die Prüfung.

Review (18.10.2026): gemergt.
