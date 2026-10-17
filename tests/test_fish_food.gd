extends "res://tests/base_test.gd"

var food: FishFood


func setup() -> void:
	food = FishFood.new()


func test_hinzufuegen() -> void:
	check_eq(food.add_item(Diet.PFLANZE, Vector3(1, -50, 0))["value"], 2, "Pflanze hat Wert 2")
	check_eq(food.add_item(Diet.FLEISCH, Vector3(0, -10, 0))["value"], 3, "Fleisch hat Wert 3")
	check_eq(food.items.size(), 2, "Es gibt 2 Items")
	check_eq(food.count_kind(Diet.FLEISCH), 1, "Es gibt 1 Fleisch-Item")


func test_fressen() -> void:
	food.add_item(Diet.PFLANZE, Vector3(0, -20, -1))
	food.add_item(Diet.PFLANZE, Vector3(0, -20, -5))
	var t := food.take_at(Vector3(0, -20, -0.8), 0.5, Diet.PFLANZENFRESSER)
	check_eq(t.size(), 1, "Nur ein Pflanzenteile wird gefressen")
	check_eq(food.items.size(), 1, "Nur noch ein Item bleibt übrig")


func test_ernaehrung() -> void:
	food.add_item(Diet.FLEISCH, Vector3(0, -20, 0))
	check_eq(food.take_at(Vector3(0, -20, 0), 0.5, Diet.PFLANZENFRESSER).size(), 0, "Pflanzenfresser frisst kein Fleisch")
	check_eq(food.take_at(Vector3(0, -20, 0), 0.5, Diet.ALLESFRESSER).size(), 1, "Allesfresser frisst Fleisch")


func test_streuen() -> void:
	food.spawn_around(Vector3(0, -20, 0), 50, 5.0, 40.0, 0.4)
	check_eq(food.items.size(), 50, "Es werden 50 Items erzeugt")
	for item in food.items:
		check(item["position"].y < 0.0, "Position y ist unter der Oberfläche")
		check(item["position"].y > -FishWorld.DEPTH, "Position y ist über dem Boden")
	for item in food.items:
		if item["kind"] == Diet.PFLANZE:
			check(item["position"].y <= -FishWorld.DEPTH + 4.0, "Pflanze liegt maximal 4m über dem Boden")
	check(food.count_kind(Diet.FLEISCH) > 0, "Es gibt Fleisch-Items")
	check(food.count_kind(Diet.PFLANZE) > 0, "Es gibt Pflanzenteile")


func test_entfernen() -> void:
	food.add_item(Diet.PFLANZE, Vector3(10, -50, 0))
	food.add_item(Diet.PFLANZE, Vector3(100, -50, 0))
	check_eq(food.remove_far(Vector3(0, -20, 0), 50.0), 1, "Ein Item wird entfernt")
	check_eq(food.items.size(), 1, "Nur noch ein Item bleibt übrig")
