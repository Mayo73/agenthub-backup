class_name AssetCommands
extends RefCounted
## Asset-Befehle für das gemeinsame Befehlsmodell.


static func register_all(commands: CommandRegistry, library: AssetLibrary) -> void:
	## Alle Asset-Befehle registrieren.

	commands.register(
		"asset.add",
		"Asset aufnehmen",
		{"path": "string", "name": "string"},
		func(args: Dictionary) -> CommandResult:
			var result := library.add(args["path"], args["name"])
			return result
	)

	commands.register(
		"asset.list",
		"Assets auflisten",
		{"kind": "string"},
		func(args: Dictionary) -> CommandResult:
			var kind: String = args["kind"]
			return CommandResult.success({"assets": library.list(kind)})
	)

	commands.register(
		"asset.find",
		"Assets suchen",
		{"text": "string"},
		func(args: Dictionary) -> CommandResult:
			var text: String = args["text"]
			return CommandResult.success({"ids": library.find(text)})
	)

	commands.register(
		"asset.remove",
		"Asset entfernen",
		{"id": "string"},
		func(args: Dictionary) -> CommandResult:
			var id: String = args["id"]
			if not library.remove(id):
				return CommandResult.error(
					CommandResult.NOT_FOUND,
					"Asset %s gibt es nicht" % id
				)
			return CommandResult.success({"id": id})
	)

	commands.register(
		"asset.formats",
		"Unterstützte Formate",
		{},
		func(_args: Dictionary) -> CommandResult:
			return CommandResult.success({"text": AssetLibrary.supported_text()})
	)
