---
id: T-0296
title: Spieltest Fischphase – Verbesserungen wirken spürbar
project: zellenphase
priority: 4
after: T-0293
---
## Ziel
Ein Spieltest prüft im laufenden Spiel, dass Verbesserungen im Entwicklungsmenü wirken: Mit ausgebauter Schwanzflosse schwimmt der Fisch mit gedrückter W-Taste deutlich schneller, bessere Augen lichten den Nebel, und der Hinweis „Verbesserung möglich“ erscheint und verschwindet. (Agents können Spieltests schreiben, aber nicht ausführen; Claude führt sie im Review aus.)

## Dateien
- `playtests/fisch_entwicklung.gd` – neu

## Akzeptanzkriterien
Neue Datei `playtests/fisch_entwicklung.gd`, Aufbau wie `playtests/fisch.gd` (`extends "res://playtests/playtest.gd"`). Wichtig: `scene_path` in `_init()` setzen, nicht in `run()`, sonst wird die Szene nicht geladen:
```gdscript
func _init() -> void:
	scene_path = "res://scenes/fish.tscn"
```
- `describe()` gibt `"Fischphase: Verbesserungen machen schneller und lichten den Nebel"` zurück.
- `run()`:
  1. `await wait(0.5)`; `scene.intro.close()`
  2. `await hold("hoch", 3.0)`; `var vorher: float = scene.player.motion.speed()`; `measure("tempo_vorher", vorher)`; `await wait(2.0)` (ausrollen)
  3. `scene.progress.dna = 65`; `scene.update_upgrade_hint()`; `check(scene.hud.upgrade_label.visible, "Hinweis bei genug DNA")`
  4. `await tap("entwickeln")`; `check(scene.evolve.visible, "E öffnet das Entwicklungsmenü")`; dreimal `scene.evolve.buttons["schwanz"].pressed.emit()`; `check_eq`-artig mit `check(scene.player.build.level("schwanz") == 3, "Schwanzflosse auf Stufe 3")`; `shot("menue")`; `await tap("entwickeln")`; `check(not scene.evolve.visible, "E schließt das Menü")`
  5. `check(not scene.hud.upgrade_label.visible, "Hinweis weg, wenn die DNA nicht mehr reicht")`
  6. `await hold("hoch", 3.0)`; `var nachher: float = scene.player.motion.speed()`; `measure("tempo_nachher", nachher)`; `check(nachher > vorher + 2.0, "Mit ausgebauter Schwanzflosse deutlich schneller")`
  7. `var nebel: float = scene.water.environment.fog_density`; `scene.progress.dna = 10`; `scene.evolve.open(scene.player.build, scene.progress)`; `scene.evolve.buttons["augen"].pressed.emit()`; `scene.evolve.close()`; `check(scene.water.environment.fog_density < nebel, "Bessere Augen lichten den Nebel")`; `shot("klare_sicht")`
- Sonst nichts ändern.

## Tests
Keine Unit-Tests; der Spieltest wird im Review mit `hub\tools\spieltest.ps1 -Projekt zellenphase -Test fisch_entwicklung` ausgeführt. Die Datei muss fehlerfrei laden.

Review (18.10.2026): gemergt.
