extends "res://tests/base_test.gd"

var plan: Array[Dictionary]


func setup() -> void:
	plan = FishSchool.spawn_plan(FishWorld.START, 7)


func test_anzahl() -> void:
	check(plan.size() == 17, "Plan hat 17 Einträge")
	var silberling := 0
	var grasfisch := 0
	var zackenbarsch := 0
	for entry in plan:
		match entry["id"]:
			"silberling": silberling += 1
			"grasfisch": grasfisch += 1
			"zackenbarsch": zackenbarsch += 1
	check_eq(silberling, 12, "12 silberling")
	check_eq(grasfisch, 3, "3 grasfisch")
	check_eq(zackenbarsch, 2, "2 zackenbarsch")


func test_abstand() -> void:
	for entry in plan:
		var p: Vector3 = entry["position"]
		var dx: float = p.x - FishWorld.START.x
		var dz: float = p.z - FishWorld.START.z
		var dist: float = sqrt(dx * dx + dz * dz)
		check(dist >= 20.0, "Eintrag %s liegt mindestens 20 m entfernt" % entry["id"])
		check_eq(p, FishWorld.clamp_to_water(p), "Position liegt im Wasser")


func test_gleicher_seed() -> void:
	var plan1 := FishSchool.spawn_plan(FishWorld.START, 7)
	var plan2 := FishSchool.spawn_plan(FishWorld.START, 7)
	var plan3 := FishSchool.spawn_plan(FishWorld.START, 8)
	check(plan1 == plan2, "Gleicher Seed ergibt gleichen Plan")
	check(plan1 != plan3, "Verschiedener Seed ergibt anderen Plan")


func test_schwarmmitte() -> void:
	var a := AiFish.new()
	a.setup("silberling", Vector3(0, -20, 0))
	var b := AiFish.new()
	b.setup("silberling", Vector3(4, -20, 0))
	var c := AiFish.new()
	c.setup("grasfisch", Vector3(50, -20, 0))
	var center_ab: Variant = FishSchool.flock_center([a, b, c], "silberling")
	check_eq(center_ab, Vector3(2, -20, 0), "Schwarmmitte der silberlinge")
	var center_c_silberling: Variant = FishSchool.flock_center([c], "silberling")
	check(center_c_silberling == null, "flock_center mit keinem Treffer ist null")
	a.free()
	b.free()
	c.free()
