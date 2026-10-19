class_name JobCommands
extends RefCounted
## Verwaltet Befehle für Job-Operationen über CommandRegistry.

static func register_all(commands: CommandRegistry, queue: JobQueue) -> void:
	"""Befehle zur Verwaltung von Jobs registrieren."""

	commands.register(
		"job.submit",
		"Auftrag anlegen",
		{"kind": "string", "params": "dict"},
		func(args: Dictionary) -> CommandResult:
			var kind: String = str(args["kind"])
			var params: Dictionary = args["params"]
			var id := queue.submit(kind, params)
			return CommandResult.success({"id": id})
	)

	commands.register(
		"job.status",
		"Zustand eines Auftrags abfragen",
		{"id": "string"},
		func(args: Dictionary) -> CommandResult:
			var id: String = str(args["id"])
			var job := queue.get_job(id)
			if job.is_empty():
				return CommandResult.error(
					CommandResult.NOT_FOUND,
					"Auftrag %s gibt es nicht" % id
				)
			return CommandResult.success(job)
	)

	commands.register(
		"job.cancel",
		"Auftrag abbrechen",
		{"id": "string"},
		func(args: Dictionary) -> CommandResult:
			var id: String = str(args["id"])
			return queue.cancel(id)
	)

	commands.register(
		"job.list",
		"Aufträge auflisten",
		{"state": "string"},
		func(args: Dictionary) -> CommandResult:
			var state: String = str(args["state"])
			return CommandResult.success({"jobs": queue.list(state)})
	)
