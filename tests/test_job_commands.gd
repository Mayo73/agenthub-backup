extends "res://tests/base_test.gd"

var registry: CommandRegistry
var queue: JobQueue


func setup() -> void:
	registry = CommandRegistry.new()
	queue = JobQueue.new()
	JobCommands.register_all(registry, queue)


func execute(cmd: String, args: Dictionary) -> CommandResult:
	return registry.execute(cmd, args)


func test_anlegen() -> void:
	var result := execute("job.submit", {"kind": "export", "params": {"ziel": "a.exe"}})
	check(result.code == CommandResult.CODE_OK, "Befehl erfolgreich")
	var data: Dictionary = result.data
	check(data.has("id"), "Daten enthalten ID")
	check_eq(data["id"], "j1", "ID ist 'j1'")


func test_status() -> void:
	execute("job.submit", {"kind": "export", "params": {"ziel": "a.exe"}})

	var result := execute("job.status", {"id": "j1"})
	check(result.code == CommandResult.CODE_OK, "Status von vorhandenem Auftrag erfolgreich")
	var data: Dictionary = result.data
	check_eq(data["state"], "queued", "Zustand ist 'queued'")

	result = execute("job.status", {"id": "j9"})
	check(result.code == CommandResult.NOT_FOUND, "Nicht existenter Auftrag liefert NOT_FOUND")


func test_abbrechen() -> void:
	execute("job.submit", {"kind": "export", "params": {"ziel": "a.exe"}})

	var result := execute("job.cancel", {"id": "j1"})
	check(result.code == CommandResult.CODE_OK, "Abbrechen erfolgreich")

	result = execute("job.status", {"id": "j1"})
	var data: Dictionary = result.data
	check_eq(data["state"], "cancelled", "Zustand ist 'cancelled'")

	result = execute("job.cancel", {"id": "j1"})
	check(result.code == CommandResult.INVALID_ARGUMENT, "Zweites Abbrechen liefert INVALID_ARGUMENT")


func test_liste() -> void:
	execute("job.submit", {"kind": "export", "params": {"ziel": "a.exe"}})
	execute("job.submit", {"kind": "test", "params": {}})
	execute("job.cancel", {"id": "j1"})

	var result := execute("job.list", {"state": "queued"})
	check(result.code == CommandResult.CODE_OK, "Liste aufrufen erfolgreich")
	var data: Dictionary = result.data
	check_eq(data["jobs"].size(), 1, "Genau ein queued-Job")

	result = execute("job.list", {"state": ""})
	data = result.data
	check_eq(data["jobs"].size(), 2, "Alle zwei Jobs sichtbar")
