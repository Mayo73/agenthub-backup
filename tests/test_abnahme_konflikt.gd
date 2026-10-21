extends "res://tests/base_test.gd"

var model: SceneModel
var kiste: String
var writer: WriteCoordinator
var undo: UndoStack


func setup():
	model = SceneModel.new()
	kiste = model.add_object("Node2D", "", {"x": 0.0})
	writer = WriteCoordinator.new(model)
	undo = UndoStack.new(model)


func test_konflikt_erkannt():
	# beide lesen Revision 0
	undo.record()
	var r1: CommandResult = writer.set_property(kiste, "x", 5.0, 0, "gui")
	check_eq(r1.code, "ok")

	var r2: CommandResult = writer.set_property(kiste, "x", 9.0, 0, "agent")
	check_eq(r2.code, "conflict")
	check(r2.message.contains("gui"), "Meldung enthält 'gui': %s" % r2.message)
	check_eq(model.get_property(kiste, "x"), 5.0)


func test_nach_neu_lesen():
	# wie oben, dann auf neuer Revision setzen
	undo.record()
	writer.set_property(kiste, "x", 5.0, 0, "gui")

	var r: CommandResult = writer.set_property(kiste, "x", 9.0, writer.revision, "agent")
	check_eq(r.code, "ok")
	check_eq(model.get_property(kiste, "x"), 9.0)
	check_eq(writer.history(kiste).size(), 2)


func test_rueckgaengig():
	undo.record()
	writer.set_property(kiste, "x", 5.0, writer.revision, "gui")

	check(undo.undo())
	check_eq(model.get_property(kiste, "x"), 0.0)

	check(undo.redo())
	check_eq(model.get_property(kiste, "x"), 5.0)


func test_checkpoint():
	undo.checkpoint("vorher")
	undo.record()
	model.set_property(kiste, "x", 7.0)
	model.add_object("Sprite2D", kiste, {})

	check(undo.restore("vorher"))
	check_eq(model.get_property(kiste, "x"), 0.0)
	check(model.children(kiste).is_empty())
