extends "res://tests/base_test.gd"

var plan: Array[Dictionary]


func setup() -> void:
	plan = FishSchool.spawn_plan(FishWorld.START, 7)


func test_anzahl() -> void:
	check(plan.size() == 22, "Plan hat 22 Einträge")
	var silberling := 0
	var grasfisch := 0
	var kugelfisch := 0
	var laternenfisch := 0
	var zackenbarsch := 0
	for entry in plan:
		match entry["id"]:
			"silberling": silberling += 1
			"grasfisch": grasfisch += 1
			"kugelfisch": kugelfisch += 1
			"laternenfisch": laternenfisch += 1
			"zackenbarsch": zackenbarsch += 1
	check_eq(silberling, 12, "12 silberling")
	check_eq(grasfisch, 3, "3 grasfisch")
	check_eq(kugelfisch, 2, "2 kugelfisch")
	check_eq(laternenfisch, 3, "3 laternenfisch")
	check_eq(zackenbarsch, 2, "2 zackenbarsch")


func test_kugelfische() -> void:
	var count := 0
	for entry in plan:
		if entry["id"] == "kugelfisch":
			count += 1
	check(count == 2, "Genau 2 Kugelfische im Spawn-Plan")


func test_laternenfische_tief() -> void:
	var count := 0
	for entry in plan:
		if entry["id"] == "laternenfisch":
			count += 1
	check(count == 3, "Genau 3 Laternenfische im Spawn-Plan")
	for entry in plan:
		if entry["id"] == "laternenfisch":
			var depth := FishWorld.depth_of(entry["position"])
			check(depth >= 45.0, "Laternenfisch liegt mindestens 45m tief")


func test_laternenfische_im_soll() -> void:
	check_eq(FishSchool.target_counts()["laternenfisch"], 3, "Ziel-Laternenfisch ist 3")


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


## Platzhalter-Fische für Tests.
class Stub:
	var species_id := ""

func stub(id: String) -> Stub:
	var s := Stub.new()
	s.species_id = id
	return s


func test_sollbestand() -> void:
	var counts := FishSchool.target_counts()
	check_eq(counts["silberling"], 12, "ziel silberling ist 12")
	var sum := 0
	for v in counts.values():
		sum += int(v)
	check_eq(sum, plan.size(), "Summe aller Ziele entspricht Plan-größe")


func test_nichts_fehlt() -> void:
	var stubs := []
	for entry in plan:
		stubs.append(stub(entry["id"]))
	var miss := FishSchool.missing(stubs)
	check(miss.is_empty(), "keine fehlenden Fische bei vollständigem Bestand")


func test_fehlende() -> void:
	var stubs := []
	for i in 10:
		stubs.append(stub("silberling"))
	for i in 3:
		stubs.append(stub("grasfisch"))
	for i in 2:
		stubs.append(stub("kugelfisch"))
	for i in 0:
		stubs.append(stub("laternenfisch"))
	stubs.append(stub("zackenbarsch"))
	var miss := FishSchool.missing(stubs)
	check_eq(miss.size(), 6, "sechs Fische fehlen")
	check("silberling" in miss, "silberling fehlt")
	check("laternenfisch" in miss, "laternenfisch fehlt")
	check("zackenbarsch" in miss, "zackenbarsch fehlt")
	miss.sort()
	check_eq(miss, ["laternenfisch", "laternenfisch", "laternenfisch", "silberling", "silberling", "zackenbarsch"], "Fehlende Fische korrekt ermittelt")


func test_zu_viele() -> void:
	var stubs := []
	for i in 5:
		stubs.append(stub("zackenbarsch"))
	var miss := FishSchool.missing(stubs)
	check(!("zackenbarsch" in miss), "keine Überschüsse als fehlend markiert")


func test_nachkommen_abstand() -> void:
	for s in range(1, 21):
		var p := FishSchool.respawn_position(FishWorld.START, s)
		var dist: float = Vector2(p.x - FishWorld.START.x, p.z - FishWorld.START.z).length()
		check(dist >= FishSchool.MIN_DIST, "Seed %d: Abstand mindestens MIN_DIST" % s)
		check(dist <= FishSchool.MAX_DIST + 0.01, "Seed %d: Abstand nicht weiter als MAX_DIST" % s)
		var depth := FishWorld.depth_of(p)
		check(depth >= 5.0 && depth <= 50.0, "Seed %d: Tiefe zwischen 5 und 50" % s)
