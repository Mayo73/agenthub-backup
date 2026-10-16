extends "res://tests/base_test.gd"


func test_bilder() -> void:
	check(FoodView.texture_for(Diet.PFLANZE) != null, "Pflanzentextur sollte nicht null sein")
	check(FoodView.texture_for(Diet.FLEISCH) != null, "Fleischtextur sollte nicht null sein")
	check(FoodView.texture_for(Diet.PFLANZE) != FoodView.texture_for(Diet.FLEISCH), "Pflanze- und Fleischtextur sollten unterschiedlich sein")


func test_rechteck() -> void:
	var item := FoodItem.new(Diet.PFLANZE, Vector2(10, 20), 1, 5.0)
	var r := FoodView.sprite_rect(item)
	check_eq(r.position, Vector2(3, 13), "position sollte (3, 13) sein")
	check_eq(r.size, Vector2(14, 14), "size sollte (14, 14) sein")


func test_mitte() -> void:
	var item := FoodItem.new(Diet.FLEISCH, Vector2(-4, 8), 2, 6.0)
	var center := FoodView.sprite_rect(item).get_center()
	check_eq(center, Vector2(-4, 8), "sprite_rect sollte das Nahrungsstück mittig umschließen")
