---
id: T-0568
title: Abnahmetest Kriterium 10 – Konflikt, Rückgängig und Checkpoint
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Abnahme“, Kriterium 10: GUI und Agent ändern aus derselben Revision dieselbe Eigenschaft; der Konflikt wird erkannt, nichts wird unbemerkt überschrieben; Rückgängig und Checkpoint-Wiederherstellung funktionieren. Nur ein neuer Test.

## Dateien
- `tests/test_abnahme_konflikt.gd` – neu

## Akzeptanzkriterien
Vorher `core/scene_model.gd`, `core/write_coordinator.gd` und `core/undo_stack.gd` lesen. `UndoStack.record()` wird vor jeder Änderung aufgerufen.

Hinweis Typen: Test erbt von `res://tests/base_test.gd` und nutzt `check`/`check_eq`. Ergebnisse typisiert (`var r: CommandResult = writer.set_property(...)`). Einrückung nur mit Tabs.

## Tests
`tests/test_abnahme_konflikt.gd` (in `setup()`: `model = SceneModel.new()`, `kiste = model.add_object("Node2D", "", {"x": 0.0})`, `writer = WriteCoordinator.new(model)`, `undo = UndoStack.new(model)`):
- `test_konflikt_erkannt`: beide lesen Revision 0. `undo.record()`, `writer.set_property(kiste, "x", 5.0, 0, "gui").code` ist „ok“. Dann `writer.set_property(kiste, "x", 9.0, 0, "agent")` hat Code „conflict“, die Meldung (`message`) enthält „gui“, und `model.get_property(kiste, "x")` ist weiter 5.0
- `test_nach_neu_lesen`: wie oben, dann `writer.set_property(kiste, "x", 9.0, writer.revision, "agent").code` „ok“, Wert 9.0, `writer.history(kiste).size()` 2
- `test_rueckgaengig`: `undo.record()`, Wert über `writer` auf 5.0; `undo.undo()` true → Wert 0.0; `undo.redo()` true → 5.0
- `test_checkpoint`: `undo.checkpoint("vorher")`, `undo.record()`, `model.set_property(kiste, "x", 7.0)`, `model.add_object("Sprite2D", kiste, {})`; `undo.restore("vorher")` true → Wert 0.0 und `model.children(kiste)` leer
