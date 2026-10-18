extends "res://tests/base_test.gd"


func test_gleich_lang() -> void:
	check_eq(FishMusic.LEAD.size(), 32, "LEAD hat 32 Noten")
	check_eq(FishMusic.BASS.size(), FishMusic.LEAD.size(), "BASS ist gleich lang wie LEAD")


func test_schleife() -> void:
	var s := FishMusic.theme()
	check(s.loop_mode != AudioStreamWAV.LOOP_DISABLED, "loop_mode ist nicht LOOP_DISABLED")
	check(s.data.size() > 0, "data.size() > 0")


func test_laenger_als_zellmusik() -> void:
	check(FishMusic.theme().data.size() > CellMusic.theme().data.size(), "FishMusic-Thema ist länger als CellMusic-Thema")


func test_tiefer() -> void:
	var fish_bass := []
	for n in FishMusic.BASS:
		if n != FishMusic.REST:
			fish_bass.append(n)
	var cell_bass := []
	for n in CellMusic.BASS:
		if n != CellMusic.REST:
			cell_bass.append(n)
	check(fish_bass.min() < cell_bass.min(), "kleinster Wert in FishMusic.BASS ist kleiner als in CellMusic.BASS")
