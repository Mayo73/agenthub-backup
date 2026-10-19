extends "res://tests/base_test.gd"

var model: SceneModel
var stack: UndoStack


func setup() -> void:
	model = SceneModel.new()
	stack = UndoStack.new(model)


## test_rueckgaengig: record(), add_object → undo() wahr, size 0; redo() wahr, size 1
func test_rueckgaengig() -> void:
	stack.record()
	var id: String = model.add_object("Node2D")
	check(stack.undo(), "undo sollte möglich sein")
	check_eq(model.objects.size(), 0, "nach undo keine Objekte")
	check(stack.redo(), "redo sollte möglich sein")
	check_eq(model.objects.size(), 1, "nach redo wieder 1 Objekt")


## test_leer: undo() und redo() falsch wenn leer
func test_leer() -> void:
	check(not stack.undo(), "undo bei leerer Liste soll false zurückgeben")
	check(not stack.redo(), "redo bei leerer Liste soll false zurückgeben")


## test_neue_aenderung_leert_redo: record/anlegen, undo(), record/anlegen → can_redo() falsch
func test_neue_aenderung_leert_redo() -> void:
	stack.record()
	model.add_object("Node2D")
	check(stack.undo(), "undo sollte funktionieren")
	stack.record()
	model.add_object("Node2D")
	check(not stack.can_redo(), "neue Änderung soll redo-Liste leeren")


## test_eigenschaft: Objekt mit mass 1.0, record(), set_property(..., "mass", 5.0), undo() → mass 1.0
func test_eigenschaft() -> void:
	var id: String = model.add_object("Node2D", "", {"mass": 1.0})
	stack.record()
	model.set_property(id, "mass", 5.0)
	check(stack.undo(), "undo sollte möglich sein")
	check_eq(model.get_property(id, "mass", -1.0), 1.0, "mass nach undo soll 1.0 sein")


## test_checkpoint: zwei Objekte, checkpoint("vorher"), record(), beide entfernen, restore("vorher") → 2 Objekte; undo() → 0; restore("gibts") falsch; checkpoint_names() ["vorher"]
func test_checkpoint() -> void:
	var id1: String = model.add_object("Node2D")
	var id2: String = model.add_object("Node2D")
	stack.checkpoint("vorher")
	stack.record()
	model.remove_object(id1)
	model.remove_object(id2)
	check(stack.restore("vorher"), "restore sollte funktionieren")
	check_eq(model.objects.size(), 2, "nach restore wieder 2 Objekte")
	check(stack.undo(), "undo nach restore soll möglich sein")
	check_eq(model.objects.size(), 0, "nach undo keine Objekte")
	check(not stack.restore("gibts"), "unbekannter Checkpoint soll false zurückgeben")
	var names: Array[String] = stack.checkpoint_names()
	check_eq(names.size(), 1, "ein Checkpoint gespeichert")
	check_eq(names[0], "vorher", "korrekter Checkpoint-Name")


## test_limit: 105-mal record() → undo_list.size() 100
func test_limit() -> void:
	for i in range(105):
		stack.record()
	check_eq(stack.undo_list.size(), 100, "maximal 100 Einträge auf undo_list")
