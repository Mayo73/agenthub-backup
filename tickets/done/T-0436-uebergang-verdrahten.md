---
id: T-0436
title: Übergang vom Editor zur Fischphase verdrahten
project: zellenphase
priority: 4
after: T-0435, T-0432
---
## Ziel
Auftrag „Übergang zum Fisch im Editor“: Klick auf „Zum Fisch entwickeln“ übernimmt den Aufbau, spielt die Verwandlung ab und wechselt dann in die Fischszene. Der Übergang kommt in den Zeitstrahl.

## Dateien
- `scripts/main.gd` – Ablauf
- `scripts/fish_start.gd` – Zeitstrahl übergeben
- `tests/test_main_wiring.gd` – Tests ergänzen

## Akzeptanzkriterien
- `open_editor()` verbindet `editor.evolve_requested` mit `func evolve_to_fish(build: CellBuild) -> void`:
  - übernimmt den Aufbau wie `close_editor` bei bestätigtem Editor. Dafür die Übernahme aus `close_editor` in eine Hilfsfunktion `apply_editor_result(build: CellBuild) -> void` herausziehen und in beiden Funktionen verwenden (nicht kopieren). Der Editor bleibt dabei offen.
  - `add_timeline(EvolutionTimeline.FISH, "Fisch")`
  - `autosave_now()`, dann `editor.morph_finished` mit `go_to_fish` verbinden und `editor.play_morph()` aufrufen
- `fish_start.gd`: `static var pending_timeline: Dictionary = {}`, in `clear()` leeren. `prepare_fish()` in `main.gd` setzt `FishStart.pending_timeline = timeline.to_dict()`.

## Tests
`tests/test_main_wiring.gd`:
- `test_zum_fisch_zeitstrahl`: Hauptszene laden, Partie starten, `open_editor()`, dann `main.evolve_to_fish(main.player.build)` → letzter Zeitstrahl-Eintrag hat Art `EvolutionTimeline.FISH`; `main.editor.morph.running` ist wahr (der Test endet vor dem Ende der Verwandlung, die Szene wechselt nicht)
- `test_fischstart_zeitstrahl`: `prepare_fish()` → `FishStart.pending_timeline.has("entries")`; danach `FishStart.clear()`

Review (20.10.2026): selbst umgesetzt (Agent hatte das Übernehmen des Aussehens in close_editor abgeschaltet, 4 Tests rot).
