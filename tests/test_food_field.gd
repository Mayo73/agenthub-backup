extends "res://tests/base_test.gd"

func test_verteilen() -> void:
	var field := FoodField.new(5)
	field.spawn_around(Vector2(100, 0), 50, 60.0, 900.0, 0.3)
	check_eq(field.items.size(), 50, "items.size() ist 50")
	for item in field.items:
		var dist := item.position.distance_to(Vector2(100, 0))
		check(dist >= 59.99 and dist <= 900.01, "Abstand zwischen 59.99 und 900.01, war " + str(dist))


func test_nur_pflanzen() -> void:
	var field := FoodField.new(5)
	field.spawn_around(Vector2.ZERO, 20, 10.0, 50.0, 0.0)
	check_eq(field.count_kind(Diet.FLEISCH), 0, "count_kind(Diet.FLEISCH) ist 0")
	check_eq(field.count_kind(Diet.PFLANZE), 20, "count_kind(Diet.PFLANZE) ist 20")


func test_nur_fleisch() -> void:
	var field := FoodField.new(5)
	field.spawn_around(Vector2.ZERO, 10, 10.0, 50.0, 1.0)
	for item in field.items:
		check(item.kind == Diet.FLEISCH, "kind ist Fleisch")
		check_eq(item.value, 2, "value ist 2")


func test_reproduzierbar() -> void:
	var field1 := FoodField.new(5)
	field1.spawn_around(Vector2.ZERO, 3, 10.0, 50.0, 0.5)
	var field2 := FoodField.new(5)
	field2.spawn_around(Vector2.ZERO, 3, 10.0, 50.0, 0.5)
	check_eq(field1.items[0].position, field2.items[0].position, "items[0].position ist gleich")
	check_eq(field1.items[2].position, field2.items[2].position, "items[2].position ist gleich")


func test_hinzufuegen() -> void:
	var field := FoodField.new(5)
	field.add_item(Diet.PFLANZE, Vector2(10, 0))
	check_eq(field.items[0].value, 1, "value ist 1")
	check_eq(field.items[0].radius, 5.0, "radius ist 5.0")
	check_eq(field.items.size(), 1, "items.size() ist 1")


func test_naechstes() -> void:
	var field := FoodField.new(5)
	field.add_item(Diet.PFLANZE, Vector2(100, 0))
	field.add_item(Diet.FLEISCH, Vector2(50, 0))
	field.add_item(Diet.PFLANZE, Vector2(200, 0))
	check_eq(field.nearest(Vector2.ZERO, Diet.PFLANZE).position, Vector2(100, 0), "nearest Pflanze ist (100, 0)")
	check(field.nearest(Vector2.ZERO, Diet.FLEISCH, 40.0) == null, "nearest Fleisch mit 40.0 ist null")


func test_entfernen() -> void:
	var field := FoodField.new(5)
	field.add_item(Diet.PFLANZE, Vector2(100, 0))
	field.add_item(Diet.FLEISCH, Vector2(50, 0))
	field.add_item(Diet.PFLANZE, Vector2(200, 0))
	var removed := field.remove_far(Vector2.ZERO, 150.0)
	check_eq(removed, 1, "remove_far gibt 1 zurück")
	check_eq(field.items.size(), 2, "items.size() ist 2 danach")
