class_name ModuleCommands
extends RefCounted
## Befehle zur Verwaltung von Modulen.

static func register_all(commands: CommandRegistry, modules: ModuleRegistry) -> void:
	"""Drei Module-Befehle registrieren: list, enable, disable."""

	# module.list – alle Module auflisten
	commands.register(
		"module.list",
		"Module mit Version, Abhängigkeiten und Zustand auflisten",
		{},
		func(args: Dictionary) -> CommandResult:
			return CommandResult.success({"modules": modules.list()})
	)

	# module.enable – Modul aktivieren
	commands.register(
		"module.enable",
		"Modul aktivieren",
		{"id": "string"},
		func(args: Dictionary) -> CommandResult:
			var id: String = str(args["id"])
			return modules.enable(id)
	)

	# module.disable – Modul abschalten
	commands.register(
		"module.disable",
		"Modul abschalten",
		{"id": "string"},
		func(args: Dictionary) -> CommandResult:
			var id: String = str(args["id"])
			return modules.disable(id)
	)
