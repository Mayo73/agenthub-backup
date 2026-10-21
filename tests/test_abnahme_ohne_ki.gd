extends "res://tests/base_test.gd"

var reg: ProviderRegistry


func setup() -> void:
	reg = ProviderRegistry.new()
	reg.add("ollama", "Ollama", ProviderRegistry.KIND_LOKAL, 1)
	reg.add("claude", "Claude", ProviderRegistry.KIND_HUB, 2)
	reg.set_available("ollama", false)
	reg.set_available("claude", false)


func test_meldung() -> void:
	var r: CommandResult = reg.active()
	check_eq(r.code, CommandResult.DEPENDENCY, "code muss dependency sein")
	check(r.message.contains("Kein KI-Anbieter erreichbar"), "Meldung muss 'Kein KI-Anbieter erreichbar' enthalten")
	check(r.message.contains("Manuelles Bearbeiten"), "Meldung muss 'Manuelles Bearbeiten' enthalten")


func test_status() -> void:
	var text := reg.status_text()
	check_eq(text.count("nicht erreichbar"), 2, "status_text muss zwei Mal 'nicht erreichbar' enthalten")


func test_bearbeiten_geht() -> void:
	var model: SceneModel = SceneModel.new()
	var id := model.add_object("Node2D")
	check(model.has_object(id), "Objekt wurde erstellt")

	var stack: UndoStack = UndoStack.new(model)
	stack.record()

	var ok := model.set_property(id, "x", 3.0)
	check(ok, "set_property muss true zurückgeben")

	ok = stack.undo()
	check(ok, "undo muss true zurückgeben")

	check(model.get_property(id, "x") != 3.0, "Wert nach undo darf nicht 3.0 sein")


func test_speichern_geht() -> void:
	var model: SceneModel = SceneModel.new()
	var id := model.add_object("Node2D")
	model.set_property(id, "x", 3.0)

	var d: Dictionary = JSON.parse_string(JSON.stringify(model.to_dict()))
	var restored := SceneModel.from_dict(d)

	var val: float = restored.get_property(id, "x")
	check_eq(val, 3.0, "Wert muss nach Ladevorgang 3.0 sein")


func test_wieder_da() -> void:
	reg.set_available("ollama", true)
	var r: CommandResult = reg.active()
	check_eq(r.code, "ok", "code muss ok sein")
	var data: Dictionary = r.data
	check_eq(data["id"], "ollama", "id muss ollama sein")
