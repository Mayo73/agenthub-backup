---
id: T-0377
title: UndoStack – Rückgängig, Wiederholen und Checkpoints für das Szenenmodell
project: hub-engine
priority: 4
after: T-0373
---
## Ziel
Meilenstein „Kern: Befehle, Szenen, Revisionen“ (Lastenheft Muss 3 „Rückgängig/Wiederholen“, Muss 8 „wiederherstellbare Checkpoints“, Abnahmekriterium 10).

## Dateien
- `core/undo_stack.gd` – neu, Klasse `UndoStack`
- `tests/test_undo_stack.gd` – neu

## Akzeptanzkriterien
`class_name UndoStack`, `extends RefCounted`. Arbeitet mit Schnappschüssen (`SceneModel.to_dict()` und `SceneModel.load_from()`):
- `var model: SceneModel`, `var undo_list: Array[Dictionary] = []`, `var redo_list: Array[Dictionary] = []`, `var checkpoints: Dictionary = {}`
- `const LIMIT := 100` – ältere Schnappschüsse fallen vorne weg
- `func _init(scene: SceneModel) -> void`
- `func record() -> void`: **vor** einer Änderung aufrufen; legt `model.to_dict().duplicate(true)` auf `undo_list`, leert `redo_list`
- `func can_undo() -> bool`, `func can_redo() -> bool`
- `func undo() -> bool`: aktuellen Stand auf `redo_list`, letzten Schnappschuss laden; `false`, wenn leer
- `func redo() -> bool`: umgekehrt
- `func checkpoint(name: String) -> void`, `func restore(name: String) -> bool` (`false` bei unbekanntem Namen; `restore` ruft vorher `record()`, damit es selbst rückgängig gemacht werden kann), `func checkpoint_names() -> Array[String]` sortiert

## Tests
`tests/test_undo_stack.gd`, in `setup()` `model = SceneModel.new()`, `stack = UndoStack.new(model)`:
- `test_rueckgaengig`: `record()`, `add_object("Node2D")`; `undo()` wahr → `model.objects.size()` 0; `redo()` wahr → 1
- `test_leer`: `undo()` und `redo()` falsch
- `test_neue_aenderung_leert_redo`: record/anlegen, `undo()`, record/anlegen → `can_redo()` falsch
- `test_eigenschaft`: Objekt mit `mass` 1.0, `record()`, `set_property(..., "mass", 5.0)`, `undo()` → `mass` 1.0
- `test_checkpoint`: zwei Objekte, `checkpoint("vorher")`, `record()`, beide entfernen, `restore("vorher")` → 2 Objekte; `undo()` → 0 Objekte; `restore("gibts")` falsch; `checkpoint_names()` `["vorher"]`
- `test_limit`: 105-mal `record()` → `undo_list.size()` 100

Review (19.10.2026): gemergt.
