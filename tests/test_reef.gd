extends "res://tests/base_test.gd"


func setup() -> void:
	pass


func teardown() -> void:
	pass


func test_anzahl() -> void:
	var l := ReefLayout.new()
	check_eq(l.items.size(), 200, "Gesamtanzahl sollte 200 sein")
	check_eq(l.count("seegras"), 160, "Seegras-Anzahl sollte 160 sein")
	check_eq(l.count("fels"), 40, "Fels-Anzahl sollte 40 sein")


func test_am_boden() -> void:
	var l := ReefLayout.new()
	for item in l.items:
		check(item["position"].y == -FishWorld.DEPTH, "position.y sollte -FishWorld.DEPTH sein")
		check(absf(item["position"].x) <= FishWorld.HALF_SIZE - 5.0, "absf(position.x) sollte <= FishWorld.HALF_SIZE - 5.0 sein")


func test_gleicher_seed() -> void:
	var items_3a := ReefLayout.new(3).items
	var items_3b := ReefLayout.new(3).items
	var items_4 := ReefLayout.new(4).items
	check(items_3a == items_3b, "gleicher Seed sollte gleiche items ergeben")
	check(items_3a != items_4, "verschiedener Seed sollte verschiedene items ergeben")


func test_ansicht() -> void:
	var v := ReefView.new()
	check_eq(v.get_child_count(), 200, "Gesamtanzahl Kinder sollte 200 sein")
	check_eq(v.weeds.size(), 160, "weeds size sollte 160 sein")
	var first: Dictionary = v.layout.items[0]
	var expected_pos: Vector3 = first["position"] + Vector3(0.0, first["height"] * 0.5, 0.0)
	check((v.get_child(0) as MeshInstance3D).position.is_equal_approx(expected_pos), "erste Position sollte stimmen")
	v.free()


func test_wiegen() -> void:
	check_eq(ReefView.sway(0.0, 0.0), 0.0, "sway(0.0, 0.0) sollte 0.0 sein")
	var v := ReefView.new()
	v._process(1.0)
	var expected = sin(0.8) * 0.12
	check_eq(v.weeds[0].rotation.z, expected, "rotation.z sollte nach _process(1.0) stimmen")
	v.free()
