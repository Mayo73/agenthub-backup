---
id: T-0439
title: Zeitstrahl in der Fischphase weiterführen
project: zellenphase
priority: 4
after: T-0429, T-0437, T-0436
---
## Ziel
Auftrag „Entwicklungszeitstrahl“: In der Fischphase geht der Zeitstrahl weiter (jede Fischgröße, jede Verbesserung), wird mit dem Fisch gespeichert und öffnet sich ebenfalls mit Taste T.

## Dateien
- `scripts/fish_main.gd` – Zeitstrahl führen und anzeigen
- `scripts/fish_save.gd` – Zeitstrahl speichern
- `tests/test_fish_main.gd`, `tests/test_fish_save.gd` – Tests ergänzen

## Akzeptanzkriterien
- `fish_main.gd`: `var timeline := EvolutionTimeline.new()`; in `_ready` aus `FishStart.pending_timeline` laden, wenn nicht leer (`EvolutionTimeline.from_dict`). Hilfsfunktion `func add_timeline(kind: String, label: String) -> void` mit `phase = "fisch"`, Farbe `player.build.color`, Ernährung `player.build.diet`, Zeit aus `stats` (vorher `scripts/fish_stats.gd` lesen; gibt es keine Spielzeit, `0.0`):
  - neue Fischgröße (wo `progress.eat` wahr liefert): `add_timeline(EvolutionTimeline.FISH_SIZE, "Größe %d" % (progress.stage + 1))`
  - `_on_upgraded(slot)`: `add_timeline(EvolutionTimeline.UPGRADE, FishBuild.NAMES[slot])`
- `var timeline_view: TimelineView` auf eigener `CanvasLayer` (`layer = 8`), unsichtbar; Aktion `zeitstrahl` schaltet sie mit `func toggle_timeline() -> void` um
- `fish_save.gd`: `to_dict` bekommt optional `timeline: EvolutionTimeline = null` (unter `"timeline"`), neu `static func read_timeline(data: Dictionary) -> EvolutionTimeline`; `fish_main.gd` speichert und lädt ihn mit

## Tests
- `tests/test_fish_main.gd`: `test_zeitstrahl_verbesserung` (Fischszene laden, `progress.dna = 50`, `evolve.open(player.build, progress)`, `evolve.buttons["schwanz"].pressed.emit()` → letzter Eintrag hat Art `EvolutionTimeline.UPGRADE`); `test_zeitstrahl_taste` (`toggle_timeline()` → `timeline_view.visible`)
- `tests/test_fish_save.gd`: `test_zeitstrahl` (Speichern mit 2 Einträgen und Lesen → 2 Einträge)
