extends "res://tests/base_test.gd"


func _player_info(scene_name: String) -> Dictionary:
	return {
		"position": Vector2.ZERO,
		"radius": CellProgress.radius_for_stage(int(DemoScenes.data(scene_name)["stage"])),
		"diet": str(DemoScenes.data(scene_name)["diet"])
	}


func test_jagd() -> void:
	var d := DemoScenes.data("jagd")
	var ai: Array = d["ai"][0]
	var id: String = ai[0]
	var pos: Vector2 = ai[1]
	var brain := AiBrain.new()
	var wish := brain.decide(pos, SpeciesCatalog.radius_of(id), SpeciesCatalog.data(id)["diet"], [_player_info("jagd")], null)
	check_eq(brain.state, AiBrain.JAGEN, "AiBrain entscheidet JAGEN in 'jagd'")
	check(wish.x < 0.0, "schwillt auf die Spielerzelle zu (wish.x < 0)")


func test_flucht() -> void:
	var d := DemoScenes.data("flucht")
	var ai: Array = d["ai"][0]
	var id: String = ai[0]
	var pos: Vector2 = ai[1]
	var brain := AiBrain.new()
	var wish := brain.decide(pos, SpeciesCatalog.radius_of(id), SpeciesCatalog.data(id)["diet"], [_player_info("flucht")], null)
	check_eq(brain.state, AiBrain.FLIEHEN, "AiBrain entscheidet FLIEHEN in 'flucht'")
	check(wish.x > 0.0, "schwimmt von der Spielerzelle weg (wish.x > 0)")


func test_nahrung() -> void:
	var d := DemoScenes.data("nahrung")
	var ai: Array = d["ai"][0]
	var id: String = ai[0]
	var pos: Vector2 = ai[1]
	var brain := AiBrain.new()
	var food_pos: Vector2 = d["food"][0][1]
	var wish := brain.decide(pos, SpeciesCatalog.radius_of(id), SpeciesCatalog.data(id)["diet"], [], food_pos)
	check_eq(brain.state, AiBrain.SUCHEN, "AiBrain entscheidet SUCHEN in 'nahrung'")
	check(wish.is_equal_approx(Vector2(1, 0)), "schwillt zur Nahrung (wish == Vector2(1, 0))")


func test_ohne_spieler_treiben() -> void:
	var d := DemoScenes.data("jagd")
	var ai: Array = d["ai"][0]
	var id: String = ai[0]
	var pos: Vector2 = ai[1]
	var brain := AiBrain.new()
	var wish := brain.decide(pos, SpeciesCatalog.radius_of(id), SpeciesCatalog.data(id)["diet"], [], null)
	check_eq(wish, Vector2.ZERO, "kein Wunsch ohne Spieler und Nahrung")
	check_eq(brain.state, AiBrain.TREIBEN, "AiBrain entscheidet TREIBEN ohne Ziel")
