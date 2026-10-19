---
id: T-0384
title: Befehle für Rückgängig, Wiederholen und Checkpoints
project: hub-engine
priority: 4
after: T-0374, T-0377
---
## Ziel
Meilenstein „Kern: Befehle, Szenen, Revisionen“ (Lastenheft „gemeinsame Rücknahme und wiederherstellbare Checkpoints“, Abnahmekriterium 10): Rückgängig, Wiederholen und Checkpoints sind Befehle im gemeinsamen Befehlsmodell, damit GUI, CLI und Agenten sie gleich nutzen.

## Dateien
- `core/history_commands.gd` – neu, Klasse `HistoryCommands`
- `tests/test_history_commands.gd` – neu

## Akzeptanzkriterien
`class_name HistoryCommands`, `extends RefCounted`. Nutzt `CommandRegistry` (T-0374) und `UndoStack` (T-0377).
- `var stack: UndoStack`
- `static func register_all(registry: CommandRegistry, undo: UndoStack) -> HistoryCommands`: Instanz anlegen (`stack = undo`), diese Befehle mit Handlern der Instanz registrieren und die Instanz zurückgeben:
  - `history.undo` (keine Parameter, `{}`): `stack.undo()` wahr → `success({"can_undo": stack.can_undo(), "can_redo": stack.can_redo()})`; sonst `CommandResult.error(CommandResult.NOT_FOUND, "Nichts zum Rückgängigmachen")`
  - `history.redo` (`{}`): entsprechend, Meldung „Nichts zum Wiederholen“
  - `history.checkpoint` (`{"name": "string"}`): leerer Name → `INVALID_ARGUMENT`, „Name fehlt“; sonst `stack.checkpoint(name)`, `success({"name": name})`
  - `history.restore` (`{"name": "string"}`): `stack.restore(name)` falsch → `NOT_FOUND`, `"Checkpoint %s gibt es nicht" % name`; sonst `success({"name": name})`
  - `history.checkpoints` (`{}`): `success({"names": stack.checkpoint_names()})`
- Jede Beschreibung ist ein deutscher Satz (nicht leer).

## Tests
`tests/test_history_commands.gd`, in `setup()`: `model = SceneModel.new()`, `stack = UndoStack.new(model)`, `registry = CommandRegistry.new()`, `HistoryCommands.register_all(registry, stack)`.
- `test_rueckgaengig`: `stack.record()`, `model.add_object("Node2D")`; `execute("history.undo", {})` → ok, `model.objects.size()` 0, `data["can_redo"]` wahr; `execute("history.redo", {})` → ok, `model.objects.size()` 1
- `test_nichts`: `execute("history.undo", {})` → Code „not_found“, Meldung „Nichts zum Rückgängigmachen“
- `test_checkpoint`: Objekt anlegen, `execute("history.checkpoint", {"name": "vorher"})` ok; zweites Objekt anlegen; `execute("history.restore", {"name": "vorher"})` → ok, `model.objects.size()` 1
- `test_unbekannt`: `execute("history.restore", {"name": "x"})` → „not_found“, Meldung „Checkpoint x gibt es nicht“
- `test_name_fehlt`: `execute("history.checkpoint", {"name": ""})` → „invalid_argument“
- `test_liste`: Checkpoints „b“ und „a“ → `execute("history.checkpoints", {}).data["names"]` `["a", "b"]`
- `test_verzeichnis`: `registry.capabilities().size()` 5
