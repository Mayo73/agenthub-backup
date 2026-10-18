extends "res://tests/base_test.gd"

var fish: AiFish


func setup() -> void:
	fish = AiFish.new()


func teardown() -> void:
	fish.free()


func test_aufsetzen() -> void:
	fish.setup("zackenbarsch", Vector3(5, -20, 0))
	check_eq(fish.species_id, "zackenbarsch", "species_id ist Zackenbarsch")
	check_eq(fish.size, 1.8, "size ist 1.8")
	check_eq(fish.motion.max_speed, 7.0, "max_speed ist 7.0")
	check_eq(fish.health.max_hp, 90.0, "max_hp ist 90.0")
	check_eq(fish.position, Vector3(5, -20, 0), "position stimmt")
	check_eq(fish.model.scale, Vector3.ONE * 1.8, "model.scale ist 1.8-fach")
	check_eq(fish.model.build.level("kiefer"), 2, "kiefer-Level ist 2")


func test_beute_ohne_kiefer() -> void:
	fish.setup("silberling", Vector3(0, -20, 0))
	check_eq(fish.model.build.level("kiefer"), 0, "kiefer-Level ist 0 bei Beutefisch")
	var r := fish.radius()
	check(is_equal_approx(r, 0.3), "radius ist 0.3 (Toleranz 0,001)")


func test_im_wasser() -> void:
	fish.setup("grasfisch", Vector3(0, 5, 0))
	check(fish.motion.position.y < 0.0, "position.y ist unter Wasser")


func test_jagt() -> void:
	fish.setup("zackenbarsch", Vector3(0, -20, 0))
	var player := Vector3(0, -20, -10)
	for i in 20:
		fish.think(0.1, player, 1.0, null)
	check(fish.position.distance_to(player) < 10, "Fisch kommt Jäger auf weniger als 10m")


func test_flieht() -> void:
	fish.setup("grasfisch", Vector3(0, -20, 0))
	var player := Vector3(0, -20, 5)
	for i in 20:
		fish.think(0.1, player, 1.5, null)
	check(fish.position.distance_to(player) > 5, "Fliehender Fisch bleibt mehr als 5m vom Spieler weg")


func test_maul() -> void:
	fish.setup("grasfisch", Vector3(0, -20, 0))
	var p := fish.mouth_point()
	check(is_equal_approx(p.x, 0.0) and is_equal_approx(p.y, -20.0) and is_equal_approx(p.z, -0.8), "mouth_point ist Vector3(0, -20, -0.8)")


func test_laternenfisch_leuchtet() -> void:
	var f := AiFish.new()
	f.setup("laternenfisch", Vector3(0, -50, 0))
	check(f.has_node("Glow"), "Laternenfisch hat Glow-Node")
	var expected_color: Color = FishSpecies.data("laternenfisch")["color"]
	check(f.glow.light_color == expected_color, "Glow-Farbe stimmt mit Art überein")
	f.free()


func test_silberling_ohne_licht() -> void:
	var f := AiFish.new()
	f.setup("silberling", Vector3(0, -20, 0))
	check(not f.has_node("Glow"), "Silberling hat keinen Glow-Node")
	check(f.glow == null, "f.glow ist null bei Silberling")
	f.free()


func test_zweimal_setup() -> void:
	var f := AiFish.new()
	f.setup("laternenfisch", Vector3(0, -50, 0))
	f.setup("laternenfisch", Vector3(0, -50, 0))
	var glow_children := f.get_children().filter(func(c): return c.name.begins_with("Glow"))
	check(glow_children.size() == 1, "genau ein Glow-Kind nach zweimal setup")
	f.free()
