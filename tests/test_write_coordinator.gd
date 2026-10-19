extends "res://tests/base_test.gd"

var model: SceneModel
var id: String
var wc: WriteCoordinator


func setup() -> void:
	model = SceneModel.new()
	id = model.add_object("RigidBody2D", "", {"mass": 1.0, "friction": 0.5})
	wc = WriteCoordinator.new(model)


func test_aendern() -> void:
	var result = wc.set_property(id, "mass", 2.0, 0, "gui")
	check(result.is_ok(), "set_property sollte ok sein")
	check_eq(int(result.data["revision"]), 1, "Revision sollte 1 sein")
	check_eq(model.get_property(id, "mass"), 2.0, "mass sollte jetzt 2.0 sein")


func test_konflikt() -> void:
	var result1 = wc.set_property(id, "mass", 2.0, 0, "gui")
	check(result1.is_ok(), "erster Aufruf sollte ok sein")

	var result2 = wc.set_property(id, "mass", 3.0, 0, "agent")
	check(not result2.is_ok(), "zweiter Aufruf mit gleicher Basis soll Konflikt melden")
	check_eq(result2.code, CommandResult.CONFLICT, "Code sollte CONFLICT sein")
	check("Konflikt: %s.mass wurde in Revision 1 von gui geändert" % id in result2.message, "Meldung sollte Konflikt beschreiben")
	check_eq(result2.data["current"], 2.0, "current im data sollte 2.0 sein")
	check_eq(result2.data["revision"], 1, "revision im data sollte 1 sein")
	check_eq(model.get_property(id, "mass"), 2.0, "Modell sollte unverändert 2.0 bleiben")


func test_kein_konflikt_andere_eigenschaft() -> void:
	wc.set_property(id, "mass", 2.0, 0, "gui")

	var result = wc.set_property(id, "friction", 0.8, 0, "agent")
	check(result.is_ok(), "Änderung anderer Eigenschaft soll ok sein")
	check_eq(int(wc.revision), 2, "Revision sollte jetzt 2 sein")


func test_aktuelle_basis() -> void:
	wc.set_property(id, "mass", 2.0, 0, "gui")

	var result = wc.set_property(id, "mass", 3.0, 1, "agent")
	check(result.is_ok(), "Änderung mit aktueller Basis soll ok sein")
	check_eq(int(wc.revision), 2, "Revision sollte jetzt 2 sein")


func test_fehlt() -> void:
	var result = wc.set_property("o9", "mass", 1.0, 0, "gui")
	check(not result.is_ok(), "Aufruf für nicht existierendes Objekt soll fehlschlagen")
	check_eq(result.code, CommandResult.NOT_FOUND, "Code sollte NOT_FOUND sein")
	check_eq(int(wc.revision), 0, "Revision sollte unverändert 0 bleiben")


func test_verlauf() -> void:
	wc.set_property(id, "mass", 2.0, 0, "gui")
	wc.set_property(id, "mass", 3.0, 1, "agent")

	var hist = wc.history(id)
	check_eq(hist.size(), 2, "Verlauf sollte zwei Einträge haben")
	var first_entry: Dictionary = hist[0]
	check_eq(first_entry["old"], 1.0, "alter Wert sollte 1.0 sein")
	check_eq(first_entry["new"], 2.0, "neuer Wert sollte 2.0 sein")
	check_eq(first_entry["author"], "gui", "Autor sollte 'gui' sein")
