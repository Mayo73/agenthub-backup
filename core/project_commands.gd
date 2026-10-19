class_name ProjectCommands
extends RefCounted

## Befehle für Projekt-Speichern, -Öffnen und -Abfragen.

var store: ProjectStore
var model: SceneModel
var name := ""
var path := ""
var modules: Array[String] = []


static func register_all(commands: CommandRegistry, project_store: ProjectStore, scene: SceneModel) -> ProjectCommands:
	var cmds: ProjectCommands = ProjectCommands.new()
	cmds.store = project_store
	cmds.model = scene

	## "project.save" – Projekt speichern
	commands.register(
		"project.save",
		"Projekt speichern",
		{"path": "string", "name": "string"},
		func(args: Dictionary) -> CommandResult:
			var p := args["path"] as String
			var n := args["name"] as String
			var result := cmds.store.save(p, n, cmds.model, cmds.modules)
			if result.is_ok():
				cmds.path = p
				cmds.name = n
			return result
	)

	## "project.open" – Projekt öffnen
	commands.register(
		"project.open",
		"Projekt öffnen",
		{"path": "string"},
		func(args: Dictionary) -> CommandResult:
			var p := args["path"] as String
			var result := cmds.store.open(p)
			if result.is_ok():
				var loaded := result.data as Dictionary
				cmds.model.load_from(loaded["scene"].to_dict())
				cmds.name = loaded["name"] as String
				cmds.modules = loaded["modules"] as Array[String]
				cmds.path = p
				return CommandResult.success({"name": cmds.name, "objects": cmds.model.order.size()})
			return result
	)

	## "project.info" – Projektangaben abfragen
	commands.register(
		"project.info",
		"Projektangaben abfragen",
		{},
		func(_args: Dictionary) -> CommandResult:
			return CommandResult.success({
				"name": cmds.name,
				"path": cmds.path,
				"objects": cmds.model.order.size()
			})
	)

	return cmds
