class_name TemplateCommands
extends RefCounted

static var ProjectTemplates: GDScript = load("res://core/project_templates.gd")
static var CommandRegistry: GDScript = load("res://core/command_registry.gd")
static var CommandResult: GDScript = load("res://core/command_result.gd")
static var SceneModel: GDScript = load("res://core/scene_model.gd")


static func register_all(commands: CommandRegistry, scene: SceneModel) -> void:
	## Alle Template-Befehle registrieren.

	var list_handler := func(args: Dictionary) -> CommandResult:
		return _handle_list(commands)

	commands.register(
		"template.list",
		"Projektvorlagen auflisten",
		{},
		list_handler
	)

	var apply_handler := func(args: Dictionary) -> CommandResult:
		return _handle_apply(commands, scene, args)

	commands.register(
		"template.apply",
		"Szene aus einer Vorlage anlegen",
		{"name": "string"},
		apply_handler
	)


static func _handle_list(_registry: CommandRegistry) -> CommandResult:
	var templates := []
	for name in ProjectTemplates.names():
		templates.append(ProjectTemplates.describe(name))
	return CommandResult.success({"templates": templates})


static func _handle_apply(registry: CommandRegistry, scene: SceneModel, args: Dictionary) -> CommandResult:
	var name: String = args.get("name", "")
	var new_model: SceneModel = ProjectTemplates.create(name)

	if new_model == null:
		return CommandResult.error(
			CommandResult.NOT_FOUND,
			"Vorlage %s gibt es nicht" % name
		)

	scene.load_from(new_model.to_dict())
	return CommandResult.success({"name": name, "objects": scene.order.size()})
