---
id: T-0438
title: Spieltest „zum_fisch“ – vom Editor in die Fischphase
project: zellenphase
priority: 4
after: T-0436, T-0437
---
## Ziel
Auftrag „Übergang zum Fisch im Editor“: Ein Spieltest spielt den neuen Übergang durch, wie ein Spieler es täte.

## Dateien
- `playtests/zum_fisch.gd` – neu (Grundlage `playtests/playtest.gd`; vorher `playtests/editor.gd` und `playtests/fisch.gd` als Vorlage lesen)

## Akzeptanzkriterien
- `scene_path = "res://scenes/main.tscn"`, `describe()` „Zellenphase: im Editor zum Fisch werden“
- Ablauf in `run()`: Partie starten wie in `playtests/editor.gd`; `scene.progress.stage = CellProgress.STAGE_COUNT - 1`; 5 Teile aus `PartCatalog.UNLOCK_ORDER` mit `scene.unlocks.unlock(...)` freischalten; `scene.open_editor()`; `check(scene.editor.evolve_button.disabled, "Knopf mit 5 Teilen gesperrt")`; `shot("gesperrt")`; `scene.editor.cancel()`; ein sechstes Teil freischalten; `scene.open_editor()`; `check(not scene.editor.evolve_button.disabled, "Knopf mit 6 Teilen frei")`; `scene.editor.evolve_button.pressed.emit()`; `await wait(1.2)`; `shot("verwandlung")`; danach `await until(func() -> bool: return scene.get_tree().current_scene != null and scene.get_tree().current_scene.scene_file_path == "res://scenes/fish.tscn", 6.0, "Fischszene geladen")`
- Nach dem Szenenwechsel nur noch über `get_tree().current_scene` prüfen (das alte `scene` ist dann freigegeben)

Review (20.10.2026): gemergt.
