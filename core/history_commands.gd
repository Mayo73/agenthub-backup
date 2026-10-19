class_name HistoryCommands
extends RefCounted
## Verwaltet die Befehle history.undo, history.redo, history.checkpoint, history.restore und history.checkpoints.

var stack: UndoStack
var registry: CommandRegistry


static func register_all(registry: CommandRegistry, undo: UndoStack) -> HistoryCommands:
	var hc := HistoryCommands.new()
	hc.registry = registry
	hc.stack = undo

	var undo_handler: Callable = hc._create_undo_handler()
	var redo_handler: Callable = hc._create_redo_handler()
	var checkpoint_handler: Callable = hc._create_checkpoint_handler()
	var restore_handler: Callable = hc._create_restore_handler()
	var list_handler: Callable = hc._create_list_handler()

	registry.register("history.undo", "Rückt die letzte Änderung zurück, wenn möglich.", {}, undo_handler)
	registry.register("history.redo", "Wiederholt eine zuvor rückgängig gemachte Änderung, falls möglich.", {}, redo_handler)
	registry.register("history.checkpoint", "Legt einen benannten Checkpoint des aktuellen Zustands an.", {"name": "string"}, checkpoint_handler)
	registry.register("history.restore", "Stellt den Zustand eines gespeicherten Checkpoints wieder her.", {"name": "string"}, restore_handler)
	registry.register("history.checkpoints", "Listet alle verfügbaren Checkpoint-Namen auf.", {}, list_handler)

	return hc


func _create_undo_handler() -> Callable:
	return func(_args: Dictionary) -> CommandResult:
		if stack.undo():
			return CommandResult.success({
				"can_undo": stack.can_undo(),
				"can_redo": stack.can_redo()
			})
		else:
			return CommandResult.error(CommandResult.NOT_FOUND, "Nichts zum Rückgängigmachen")


func _create_redo_handler() -> Callable:
	return func(_args: Dictionary) -> CommandResult:
		if stack.redo():
			return CommandResult.success({
				"can_undo": stack.can_undo(),
				"can_redo": stack.can_redo()
			})
		else:
			return CommandResult.error(CommandResult.NOT_FOUND, "Nichts zum Wiederholen")


func _create_checkpoint_handler() -> Callable:
	return func(args: Dictionary) -> CommandResult:
		var name: String = args.get("name", "")
		if name.is_empty():
			return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Name fehlt")
		stack.checkpoint(name)
		return CommandResult.success({"name": name})


func _create_restore_handler() -> Callable:
	return func(args: Dictionary) -> CommandResult:
		var name: String = args.get("name", "")
		if not stack.restore(name):
			return CommandResult.error(CommandResult.NOT_FOUND, "Checkpoint %s gibt es nicht" % name)
		return CommandResult.success({"name": name})


func _create_list_handler() -> Callable:
	return func(_args: Dictionary) -> CommandResult:
		var names: Array[String] = stack.checkpoint_names()
		return CommandResult.success({"names": names})
