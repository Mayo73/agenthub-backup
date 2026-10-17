---
id: T-0268
title: Spieltest Fischphase – schwimmen, tauchen, drehen, entwickeln
project: zellenphase
priority: 4
after: T-0267
---
## Ziel
Ein Spieltest bedient die Fischphase wie ein Spieler über die echten Eingabeaktionen: vorwärts schwimmen, auf- und abtauchen, drehen und das Entwicklungsmenü öffnen. So muss das niemand mehr von Hand ausprobieren. (Agents können Spieltests schreiben, aber nicht ausführen; Claude führt sie im Review aus.)

## Dateien
- `playtests/fisch.gd` – neu

## Akzeptanzkriterien
- Neue Datei `playtests/fisch.gd`. Vorher ansehen, wie die vorhandenen Spieltests in `playtests/` aufgebaut sind (`extends`, `scene_path`, `describe()`, `run()`, `await wait()`, `hold()`, `tap()`, `press()`/`release()`, `check()`, `measure()`, `shot()`) und genauso schreiben:
  - `scene_path = "res://scenes/fish.tscn"`
  - `describe()` gibt `"Fischphase: schwimmen, tauchen, drehen, entwickeln"` zurück
  - `run()`:
    1. `await wait(0.5)`; den Übergangsbildschirm schließen: `scene.intro.close()`
    2. Startlage merken (`var start: Vector3 = scene.player.motion.position`); `await hold("hoch", 2.0)`; `check(scene.player.motion.position.distance_to(start) > 5.0, "W schwimmt vorwärts")`; `measure("tempo", scene.player.motion.speed())`
    3. Tiefe merken; `press("hoch")`; `await hold("abtauchen", 1.5)`; `release("hoch")`; `check(scene.player.motion.depth() > tiefe + 1.0, "Umschalt taucht ab")`
    4. Tiefe neu merken; genauso mit `"auftauchen"`; `check(scene.player.motion.depth() < tiefe - 1.0, "Leertaste taucht auf")`
    5. `yaw` merken; `press("hoch")`; `await hold("links", 1.0)`; `release("hoch")`; `check(scene.player.motion.yaw > yaw + 0.5, "A dreht nach links")`
    6. `await tap("entwickeln")`; `check(scene.evolve.visible, "E öffnet das Entwicklungsmenü")`; `shot("entwicklung")`; `await tap("entwickeln")`; `check(not scene.evolve.visible, "E schließt das Menü wieder")`
- Sonst nichts ändern. Keine Spielstände oder Einstellungen des Nutzers anfassen.

## Tests
Keine Unit-Tests; der Spieltest wird im Review mit `hub\tools\spieltest.ps1 -Projekt zellenphase -Test fisch` ausgeführt. Die Datei muss fehlerfrei laden (`verify.cmd` lädt alle Skripte).
