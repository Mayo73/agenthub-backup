---
id: T-0459
title: Spieltest „zeitstrahl_fisch“
project: zellenphase
priority: 4
after: T-0439, T-0456
---
## Ziel
Auftrag „Entwicklungszeitstrahl“: Ein Spieltest prüft wie ein Spieler, dass der Zeitstrahl in der Fischphase mit Taste T und über das Pausemenü aufgeht und neue Fischgrößen festhält.

## Dateien
- `playtests/zeitstrahl_fisch.gd` – neuer Spieltest

## Akzeptanzkriterien
Vorher `playtests/fisch.gd` (Aufbau eines Fisch-Spieltests) und `playtests/playtest.gd` (Hilfen) lesen. Der Spieltest wird nicht von `verify.cmd` ausgeführt, sondern im Review.
- `extends "res://playtests/playtest.gd"`, in `_init()` `scene_path = "res://scenes/fish.tscn"`, `describe()` liefert „Fischphase: Zeitstrahl mit T und im Pausemenü“
- Ablauf in `run()`: `await wait(0.5)`, `scene.intro.close()`; `await tap("zeitstrahl")` → `check` Zeitstrahl sichtbar, `shot("zeitstrahl")`; nochmal `await tap("zeitstrahl")` → `check` unsichtbar
- Dann so viel Nahrung über `scene.progress` geben, dass die nächste Größe erreicht wird (vorher `scripts/fish_progress.gd` und in `scripts/fish_main.gd` die Stelle lesen, an der `progress.eat` aufgerufen wird; dieselbe Funktion von `fish_main.gd` verwenden, damit der Zeitstrahl-Eintrag entsteht), `await wait(0.5)` → `check` der letzte Eintrag in `scene.timeline.entries` hat `"kind"` gleich `EvolutionTimeline.FISH_SIZE`
- `await tap("pause")`, `scene.pause_menu.timeline_button.pressed.emit()`, `await wait(0.3)` → `check` Zeitstrahl sichtbar und `scene.paused` falsch; `shot("aus_pause")`; `measure("eintraege", scene.timeline.size())`

Review (21.10.2026): gemergt.
