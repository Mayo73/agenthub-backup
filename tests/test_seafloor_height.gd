extends "res://tests/base_test.gd"

var seafloor: SeafloorHeight


func setup() -> void:
	seafloor = SeafloorHeight.new()


func test_gleich() -> void:
	var other := SeafloorHeight.new(7)
	check_eq(seafloor.height_at(12.5, -40.0), other.height_at(12.5, -40.0), "zwei Instanzen mit gleichem Seed → height_at(12.5, -40.0) gleich")


func test_anderer_seed() -> void:
	var seafloor_a := SeafloorHeight.new(7)
	var seafloor_b := SeafloorHeight.new(8)

	var unterscheidende_stellen := 0
	for i in range(10):
		var x := i * 37.0
		var z := i * 11.0
		if seafloor_a.height_at(x, z) != seafloor_b.height_at(x, z):
			unterscheidende_stellen += 1

	check(unterscheidende_stellen >= 1, "Seeds 7 und 8 unterscheiden sich an mindestens einer von 10 Stellen")


func test_bereich() -> void:
	var min_val := -FishWorld.DEPTH - SeafloorHeight.TRENCH - 0.01
	var max_val := -FishWorld.DEPTH + SeafloorHeight.RELIEF + 0.01

	for i in range(200):
		var x := i * 13.0 - 1000.0
		var z := i * 7.0
		var h := seafloor.height_at(x, z)
		check(h >= min_val && h <= max_val, "höhe an stelle " + str(i) + " liegt im erwarteten bereich")


func test_abwechslung() -> void:
	var hoehen: Array[float] = []
	for i in range(200):
		var x := i * 13.0 - 1000.0
		var z := i * 7.0
		hoehen.append(seafloor.height_at(x, z))

	var kleinste: float = hoehen[0]
	var groesste: float = hoehen[0]
	for h in hoehen:
		if h < kleinste:
			kleinste = h
		if h > groesste:
			groesste = h

	check(groesste - kleinste >= 3.0, "an 200 stellen ist unterschied zwischen größter und kleinster höhe mindestens 3 m")
