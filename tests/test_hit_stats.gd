extends "res://tests/base_test.gd"


func test_zaehlen() -> void:
	var s := HitStats.new()

	s.shot("gewehr")
	s.shot("gewehr")
	s.shot("gewehr")
	s.shot("gewehr")
	s.hit("gewehr")
	s.hit("gewehr")
	s.hit("gewehr")
	s.shot("bogen")
	s.shot("bogen")

	check_eq(s.shots(), 6, "total shots = 6")
	check_eq(s.hits(), 3, "total hits = 3")
	check_eq(s.accuracy("gewehr"), 0.75, "accuracy gewehr = 0.75")
	check_eq(s.accuracy(), 0.5, "overall accuracy = 0.5")


func test_leer() -> void:
	var s := HitStats.new()

	check_eq(s.accuracy(), 0.0, "accuracy leer = 0.0")
	check(s.weapons().size() == 0, "weapons leer = []")


func test_waffen() -> void:
	var s := HitStats.new()

	s.shot("zange")
	s.shot("axt")

	var w := s.weapons()
	check_eq(w.size(), 2, "weapons size = 2")
	check_eq(w[0], "axt", "first weapon sorted = axt")
	check_eq(w[1], "zange", "second weapon sorted = zange")


func test_speichern() -> void:
	var s := HitStats.new()

	s.shot("gewehr")
	s.shot("gewehr")
	s.shot("gewehr")
	s.shot("gewehr")
	s.hit("gewehr")
	s.hit("gewehr")
	s.hit("gewehr")
	s.shot("bogen")
	s.shot("bogen")

	var as_dict := s.to_dict()
	var restored := HitStats.from_dict(as_dict)

	check_eq(restored.shots(), 6, "restored shots = 6")
	check_eq(restored.hits(), 3, "restored hits = 3")
	check_eq(restored.accuracy("gewehr"), 0.75, "restored accuracy gewehr = 0.75")

	s.reset()
	check_eq(s.shots(), 0, "after reset shots = 0")
