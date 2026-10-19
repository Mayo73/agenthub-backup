class_name SceneCommands
extends RefCounted
## Befehle zur Bearbeitung des Szenenmodells. Wird über CommandRegistry registriert,
## um die GUI, CLI und Agenten gleich anzusteuern.

var model: SceneModel


static func register_all(registry: CommandRegistry, scene: SceneModel) -> SceneCommands:
	"""Legt eine Instanz an, setzt das Modell und registriert alle Szenenbefehle."""
	var cmds := SceneCommands.new()
	cmds.model = scene

	registry.register(
		"scene.add",
		"Legt ein Objekt in der Szene an.",
		{"type": "string", "parent": "string", "props": "dict"},
		func(args: Dictionary) -> CommandResult:
			var type_str := args["type"] as String
			var parent_id := args["parent"] as String
			var props: Dictionary = args["props"]

			if type_str.is_empty():
				return CommandResult.error(CommandResult.NOT_FOUND, "Kein Typ angegeben")

			var id: String = cmds.model.add_object(type_str, parent_id, props)
			if id.is_empty():
				if not cmds.model.has_object(parent_id):
					return CommandResult.error(
						CommandResult.NOT_FOUND,
						"Elternobjekt %s gibt es nicht" % parent_id
					)
				return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Leere Kennung")

			return CommandResult.success({"id": id})
	)

	registry.register(
		"scene.remove",
		"Entfernt ein Objekt aus der Szene.",
		{"id": "string"},
		func(args: Dictionary) -> CommandResult:
			var id := args["id"] as String
			if not cmds.model.has_object(id):
				return CommandResult.error(
					CommandResult.NOT_FOUND,
					"Objekt %s gibt es nicht" % id
				)

			cmds.model.remove_object(id)
			return CommandResult.success({"id": id})
	)

	registry.register(
		"scene.set",
		"Setzt eine Eigenschaft eines Objekts.",
		{"id": "string", "key": "string", "value": "any"},
		func(args: Dictionary) -> CommandResult:
			var id := args["id"] as String
			var key := args["key"] as String
			var value: Variant = args["value"]

			if not cmds.model.has_object(id):
				return CommandResult.error(
					CommandResult.NOT_FOUND,
					"Objekt %s gibt es nicht" % id
				)

			cmds.model.set_property(id, key, value)
			return CommandResult.success({"id": id, "key": key, "value": value})
	)

	registry.register(
		"scene.get",
		"Liest ein Objekt aus der Szene.",
		{"id": "string"},
		func(args: Dictionary) -> CommandResult:
			var id := args["id"] as String
			if not cmds.model.has_object(id):
				return CommandResult.error(
					CommandResult.NOT_FOUND,
					"Objekt %s gibt es nicht" % id
				)

			var obj := cmds.model.get_object(id)
			return CommandResult.success(obj)
	)

	registry.register(
		"scene.list",
		"Gibt die Kindobjekte eines Elternobjekts zurück.",
		{"parent": "string"},
		func(args: Dictionary) -> CommandResult:
			var parent_id := args["parent"] as String
			var child_ids: Array[String] = cmds.model.children(parent_id)
			return CommandResult.success({"ids": child_ids})
	)

	registry.register(
		"scene.duplicate",
		"Dupliziert ein Objekt in der Szene.",
		{"id": "string"},
		func(args: Dictionary) -> CommandResult:
			var id := args["id"] as String
			if not cmds.model.has_object(id):
				return CommandResult.error(
					CommandResult.NOT_FOUND,
					"Objekt %s gibt es nicht" % id
				)

			var new_id: String = cmds.model.duplicate_object(id)
			if new_id.is_empty():
				return CommandResult.error(CommandResult.EXEC_FAILED, "Duplizierung fehlgeschlagen")

			return CommandResult.success({"id": new_id})
	)

	return cmds
