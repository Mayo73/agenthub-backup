---
id: T-0428
title: Zeitstrahl in der Zellenphase aufzeichnen und speichern
project: zellenphase
priority: 4
after: T-0426
---
## Ziel
Auftrag „Entwicklungszeitstrahl“: Die Zellenphase trägt Start, jeden neuen Größenabschnitt und jeden bestätigten Editorbesuch in eine `EvolutionTimeline` ein; der Zeitstrahl wird mit dem Spielstand gespeichert und geladen.

## Dateien
- `scripts/main.gd` – Zeitstrahl führen
- `scripts/save_game.gd` – Zeitstrahl speichern
- `tests/test_save_game.gd`, `tests/test_main_wiring.gd` – Tests ergänzen

## Akzeptanzkriterien
- `main.gd`: `var timeline := EvolutionTimeline.new()`. Hilfsfunktion `func add_timeline(kind: String, label: String) -> void` trägt mit Ernährung `player.diet`, Zeit `stats.play_time` und der Zellfarbe aus `player.look` ein (vorher `scripts/cell_look.gd` lesen und die Farb-Eigenschaft verwenden).
  - `start_new(diet)`: neuer Zeitstrahl, dann `add_timeline(EvolutionTimeline.START, "Start")`
  - Erreicht die Zelle einen neuen Größenabschnitt (dort, wo `stats.record_stage(...)` aufgerufen wird): `add_timeline(EvolutionTimeline.STAGE, "Größe %d" % (progress.stage + 1))`
  - `close_editor`: nur wenn `editor.confirmed`, `add_timeline(EvolutionTimeline.EDITOR, "Editor")`
- `save_game.gd`: `to_dict(...)` bekommt einen optionalen letzten Parameter `timeline: EvolutionTimeline = null`; ist er gesetzt, steht unter `"timeline"` `timeline.to_dict()`. Neu `static func read_timeline(data: Dictionary) -> EvolutionTimeline`: `from_dict(data["timeline"])` oder ein leerer Zeitstrahl. `main.gd` übergibt `timeline` beim Speichern und liest ihn beim Laden (`load_saved`).
- Bestehende Aufrufe von `to_dict` bleiben gültig (der Parameter ist optional).

## Tests
- `tests/test_save_game.gd`: `test_zeitstrahl_speichern` (Zeitstrahl mit 2 Einträgen → `to_dict` → `read_timeline` hat 2 Einträge), `test_zeitstrahl_fehlt` (`read_timeline({})` → 0 Einträge)
- `tests/test_main_wiring.gd`: `test_zeitstrahl_start` (nach `start_new(Diet.PFLANZENFRESSER)` → `main.timeline.size()` 1, erste Art `EvolutionTimeline.START`; Diet-Konstante wie in `scripts/diet.gd`)

Review (20.10.2026): gemergt, nachgebessert: Starteintrag erst nach Ernährung und Aussehen der neuen Zelle (vorher mit der Ernährung der alten Partie).
