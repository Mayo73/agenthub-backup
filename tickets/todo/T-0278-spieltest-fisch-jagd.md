---
id: T-0278
title: Spieltest Fischphase – Beute fressen und Raubfisch
project: zellenphase
priority: 4
after: T-0277, T-0268
---
## Ziel
Ein Spieltest prüft das Leben im Meer im laufenden Spiel: Ein Raubfisch nähert sich einem kleinen Spielerfisch und beißt ihn; ein Fleischfresser-Fisch frisst einen Silberling vor seinem Maul. (Agents können Spieltests schreiben, aber nicht ausführen; Claude führt sie im Review aus.)

## Dateien
- `playtests/fisch_jagd.gd` – neu

## Akzeptanzkriterien
- Neue Datei `playtests/fisch_jagd.gd`, Aufbau wie `playtests/fisch.gd` und die übrigen Spieltests:
  - `scene_path = "res://scenes/fish.tscn"`; `describe()` gibt `"Fischphase: Raubfisch greift an, Beute wird gefressen"` zurück
  - `run()`:
    1. `await wait(0.5)`; `scene.intro.close()`; alle KI-Fische entfernen (`for f in scene.fishes.duplicate(): scene.remove_fish(f)`)
    2. `var r = scene.add_fish("zackenbarsch", scene.player.motion.position + Vector3(0, 0, -12))`; `await until(func() -> bool: return scene.player_health.hp < 100.0, 8.0, "Der Zackenbarsch greift an und beißt")`; `measure("gesundheit", scene.player_health.hp)`; `shot("raubfisch")`; danach `scene.remove_fish(r)`
    3. `scene.player.build.diet = Diet.FLEISCHFRESSER`; `var dna: int = scene.progress.dna`; `var s = scene.add_fish("silberling", scene.player.mouth_point())`; `s.health.hp = 5.0`; `await wait(0.3)`; `check(not scene.fishes.has(s), "Der Silberling vor dem Maul wird gefressen")`; `check(scene.progress.dna > dna, "Fressen bringt DNA")`
- Sonst nichts ändern.

## Tests
Keine Unit-Tests; der Spieltest wird im Review mit `hub\tools\spieltest.ps1 -Projekt zellenphase -Test fisch_jagd` ausgeführt. Die Datei muss fehlerfrei laden.
