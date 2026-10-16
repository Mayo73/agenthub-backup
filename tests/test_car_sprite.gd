extends "res://tests/base_test.gd"

var car: Node2D


func setup() -> void:
	car = load("res://scenes/car.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(car)


func teardown() -> void:
	car.free()


func test_bild_beim_start() -> void:
	check(car.sprite != null, "sprite soll initialisiert sein")
	check(car.sprite.texture != null, "texture soll geladen sein")
	check(car.get_node("Body").visible == false, "Body soll unsichtbar sein wenn Sprite da ist")
	check(car.get_node("Shadow").visible == true, "Shadow soll sichtbar bleiben")


func test_bild_wechselt() -> void:
	car.apply_car("grip")
	check(car.sprite.texture.resource_path == "res://assets/cars/car_grip.png",
		"Texture soll auf car_grip.png setzen")


func test_unbekannt_aendert_nichts() -> void:
	var path_bevor: String = car.sprite.texture.resource_path
	car.apply_car("gibtsnicht")
	check(car.sprite.texture.resource_path == path_bevor,
		"Bei unbekannter ID soll sich die Texture nicht ändern")
