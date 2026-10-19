class_name WriteCommands
extends RefCounted

var registry: CommandRegistry
var coordinator: WriteCoordinator


static func register_all(commands: CommandRegistry, coordinator: WriteCoordinator) -> void:
	## Alle Schreib-Befehle registrieren.
	var write_set_handler: Callable = func(args: Dictionary) -> CommandResult:
		var id: String = str(args["id"])
		var key: String = str(args["key"])
		var value: Variant = args["value"]
		var base: int = int(args["base"])
		var author: String = str(args["author"])
		return coordinator.set_property(id, key, value, base, author)

	var write_revision_handler: Callable = func(_args: Dictionary) -> CommandResult:
		return CommandResult.success({"revision": coordinator.revision})

	var write_history_handler: Callable = func(args: Dictionary) -> CommandResult:
		var id: String = str(args["id"])
		return CommandResult.success({"entries": coordinator.history(id)})

	commands.register("write.set", "Eigenschaft mit Ausgangsrevision ändern", {
		"id": "string",
		"key": "string",
		"value": "any",
		"base": "number",
		"author": "string"
	}, write_set_handler)

	commands.register("write.revision", "Aktuelle Revision abfragen", {}, write_revision_handler)

	commands.register("write.history", "Änderungsverlauf eines Objekts", {
		"id": "string"
	}, write_history_handler)


func _init(reg: CommandRegistry, coord: WriteCoordinator) -> void:
	registry = reg
	coordinator = coord
