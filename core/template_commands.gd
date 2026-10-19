class_name TemplateCommands
extends RefCounted
## Befehle für Projektvorlagen: auflisten und eine Szene aus einer Vorlage anlegen.


static func register_all(commands: CommandRegistry, scene: SceneModel) -> void:
	commands.register(
		"template.list",
		"Projektvorlagen auflisten",
		{},
		func(_args: Dictionary) -> CommandResult:
			var liste: Array[Dictionary] = []
			for name: String in ProjectTemplates.names():
				liste.append(ProjectTemplates.describe(name))
			return CommandResult.success({"templates": liste})
	)

	commands.register(
		"template.apply",
		"Szene aus einer Vorlage anlegen",
		{"name": "string"},
		func(args: Dictionary) -> CommandResult:
			var name: String = str(args["name"])
			var neu: SceneModel = ProjectTemplates.create(name)
			if neu == null:
				return CommandResult.error(CommandResult.NOT_FOUND, "Vorlage %s gibt es nicht" % name)
			scene.load_from(neu.to_dict())
			return CommandResult.success({"name": name, "objects": scene.order.size()})
	)
