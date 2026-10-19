extends "res://tests/base_test.gd"

var registry: CommandRegistry
var model: SceneModel


func setup() -> void:
	registry = CommandRegistry.new()
	model = SceneModel.new()
	model.add_object("Sprite2D", "", {"position": Vector2(1, 2)})  # o1
	model.add_object("MeshInstance3D")                               # o2


func test_verschieben_2d() -> void:
	var result: CommandResult = TransformOps.move(model, "o1", [3, 4])
	check(result.is_ok(), "move sollte erfolgreich sein")
	var actual_pos: Variant = model.get_property("o1", "position")
	check_eq(actual_pos, Vector2(4, 6), "Position sollte Vector2(4, 6) sein")


func test_verschieben_3d() -> void:
	var result: CommandResult = TransformOps.move(model, "o2", [1, 2, 3])
	check(result.is_ok(), "move 3D sollte erfolgreich sein")
	var actual_pos: Variant = model.get_property("o2", "position")
	check_eq(actual_pos, Vector3(1, 2, 3), "Position sollte Vector3(1, 2, 3) sein")

	# Falsche Anzahl von Werten für 3D
	result = TransformOps.move(model, "o2", [1, 2])
	check(not result.is_ok(), "move mit falscher Wertezahl sollte fehlschlagen")
	check(result.code == CommandResult.INVALID_ARGUMENT, "Code soll INVALID_ARGUMENT sein")


func test_drehen() -> void:
	var result: CommandResult = TransformOps.rotate(model, "o1", [90])
	check(result.is_ok(), "erste rotation sollte erfolgreich sein")
	result = TransformOps.rotate(model, "o1", [90])
	check(result.is_ok(), "zweite rotation sollte erfolgreich sein")
	var rot_val: float = model.get_property("o1", "rotation_degrees", -1.0) as float
	check_eq(rot_val, 180.0, "rotation_degrees soll 180.0 sein")


func test_skalieren() -> void:
	var result: CommandResult = TransformOps.scale_by(model, "o2", 2.0)
	check(result.is_ok(), "scale sollte erfolgreich sein")
	var actual_scale: Variant = model.get_property("o2", "scale")
	check_eq(actual_scale, Vector3(2, 2, 2), "scale soll Vector3(2, 2, 2) sein")

	result = TransformOps.scale_by(model, "o1", 0.0)
	check(not result.is_ok(), "scale mit Faktor 0 sollte fehlschlagen")
	check(result.code == CommandResult.INVALID_ARGUMENT, "Code soll INVALID_ARGUMENT sein")


func test_befehl() -> void:
	TransformOps.register_all(registry, model)

	# Testet nicht-existierendes Objekt via Befehl
	var result: CommandResult = registry.execute("transform.move", {"id": "o9", "delta": [1, 1]})
	check(not result.is_ok(), "Befehl für nicht-existierendes Objekt sollte fehlschlagen")
	check(result.code == CommandResult.NOT_FOUND, "Code soll NOT_FOUND sein")


func test_drehen_3d_und_rueckgabe() -> void:
	var result: CommandResult = TransformOps.rotate(model, "o2", [0, 45, 0])
	check(result.is_ok(), "3D-Drehung klappt")
	check_eq(model.get_property("o2", "rotation_degrees"), Vector3(0, 45, 0), "rotation_degrees in 3D")
	var moved: CommandResult = TransformOps.move(model, "o1", [1, 1])
	check_eq(moved.data["position"], [2.0, 3.0], "Position als Liste")
