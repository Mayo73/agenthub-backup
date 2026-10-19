extends "res://tests/base_test.gd"

var model: SceneModel
var stack: UndoStack
var registry: CommandRegistry


func setup() -> void:
	model = SceneModel.new()
	stack = UndoStack.new(model)
	registry = CommandRegistry.new()
	HistoryCommands.register_all(registry, stack)


func execute(name: String, args: Dictionary) -> CommandResult:
	return registry.execute(name, args)


func test_rueckgaengig() -> void:
	stack.record()
	model.add_object("Node2D")

	var result = execute("history.undo", {})
	check(result.is_ok(), "undo sollte erfolgreich sein")
	check_eq(model.objects.size(), 0, "Nach undo sollte kein Objekt vorhanden sein")
	check(result.data.get("can_redo", false), "can_redo sollte wahr sein")

	result = execute("history.redo", {})
	check(result.is_ok(), "redo sollte erfolgreich sein")
	check_eq(model.objects.size(), 1, "Nach redo sollte ein Objekt vorhanden sein")


func test_nichts() -> void:
	var result = execute("history.undo", {})
	check(not result.is_ok(), "undo bei leerem Stack sollte fehlschlagen")
	check(result.code == CommandResult.NOT_FOUND, "Code sollte NOT_FOUND sein")
	check(result.message == "Nichts zum Rückgängigmachen", "Meldung sollte passen")


func test_checkpoint() -> void:
	model.add_object("Node2D")
	var result = execute("history.checkpoint", {"name": "vorher"})
	check(result.is_ok(), "checkpoint sollte erfolgreich sein")

	model.add_object("Node3D")
	result = execute("history.restore", {"name": "vorher"})
	check(result.is_ok(), "restore sollte erfolgreich sein")
	check_eq(model.objects.size(), 1, "Nach restore auf vorheriger Checkpoint soll nur ein Objekt übrig sein")


func test_unbekannt() -> void:
	var result = execute("history.restore", {"name": "x"})
	check(not result.is_ok(), "restore bei unbekanntem Namen sollte fehlschlagen")
	check(result.code == CommandResult.NOT_FOUND, "Code sollte NOT_FOUND sein")
	check(result.message == "Checkpoint x gibt es nicht", "Meldung sollte passen")


func test_name_fehlt() -> void:
	var result = execute("history.checkpoint", {"name": ""})
	check(not result.is_ok(), "checkpoint ohne Namen sollte fehlschlagen")
	check(result.code == CommandResult.INVALID_ARGUMENT, "Code sollte INVALID_ARGUMENT sein")


func test_liste() -> void:
	model.add_object("Node2D")
	execute("history.checkpoint", {"name": "b"})
	execute("history.checkpoint", {"name": "a"})

	var result = execute("history.checkpoints", {})
	check(result.is_ok(), "checkpoints sollte erfolgreich sein")
	var names: Array[String] = result.data.get("names", [])
	check(names.size() == 2, "sollte zwei Namen haben")
	check(names[0] == "a", "erster Name sollte 'a' sein")
	check(names[1] == "b", "zweiter Name sollte 'b' sein")


func test_verzeichnis() -> void:
	var caps = registry.capabilities()
	check(caps.size() == 5, "sollte 5 Fähigkeiten haben")
