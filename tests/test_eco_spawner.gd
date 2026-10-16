extends "res://tests/base_test.gd"


var spawner: EcoSpawner


func setup() -> void:
	spawner = EcoSpawner.new(3)


func test_arten_passend() -> void:
	var near0 := SpeciesCatalog.ids_near_stage(0)
	# Alle 200-mal gezogenen IDs müssen in ids_near_stage(0) sein
	var gezogen := []
	for i in range(200):
		var id := spawner.pick_species(0)
		check(id in near0, "gezogene ID %s nicht in ids_near_stage(0)" % id)
		gezogen.append(id)
	# Jede der drei IDs muss mindestens einmal vorkommen
	for id in near0:
		check(id in gezogen, "ID %s wurde nie gezogen" % id)


func test_grosse_zelle() -> void:
	var gezogen := []
	for i in range(100):
		var id := spawner.pick_species(4)
		gezogen.append(id)
	# blasenling darf nie gezogen werden (Stage 0, zu weit von Stage 4 entfernt)
	check("blasenling" not in gezogen, "blasenling wurde bei Stage 4 gezogen")


func test_ring() -> void:
	# 50-mal mit scale=1.0: Abstand muss zwischen 700 und 1300 liegen
	for i in range(50):
		var pos := spawner.spawn_position(Vector2.ZERO, 1.0)
		var dist := pos.length()
		check(dist > 699.9 and dist < 1300.1, "Abstand %.2f nicht im Bereich [700, 1300]" % dist)
	# 50-mal mit scale=2.0: Abstand muss zwischen 1400 und 2600 liegen
	for i in range(50):
		var pos := spawner.spawn_position(Vector2.ZERO, 2.0)
		var dist := pos.length()
		check(dist > 1399.8 and dist < 2600.2, "Abstand %.2f nicht im Bereich [1400, 2600]" % dist)


func test_fehlende() -> void:
	check_eq(EcoSpawner.missing(10), 20, "missing(10) ist 20")
	check_eq(EcoSpawner.missing(40), 0, "missing(40) ist 0")


func test_massstab() -> void:
	# PlayerCell.radius = 24.0, CellProgress.radius_for_stage(0) = 12.0, also 24.0 / 12.0 = 2.0
	check_eq(EcoSpawner.view_scale(24.0), 2.0, "view_scale(24.0) ist 2.0")
	check(EcoSpawner.is_too_far(Vector2.ZERO, Vector2(1900.0, 0.0), 1.0), "is_too_far bei 1900 mit scale=1.0")
	check(not EcoSpawner.is_too_far(Vector2.ZERO, Vector2(1700.0, 0.0), 1.0), "is_too_far bei 1700 mit scale=1.0")
