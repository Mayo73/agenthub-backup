extends "res://tests/base_test.gd"

var track: KeyframeTrack

func setup() -> void:
	track = KeyframeTrack.new()

func teardown() -> void:
	pass

func test_sortiert() -> void:
	track.add_key(1.0, 10.0)
	track.add_key(0.0, 0.0)
	track.add_key(2.0, 0.0)

	check_eq(track.keys[1]["t"], 1.0, "keys[1][\"t\"] sollte 1.0 sein")
	check_eq(track.length(), 2.0, "length() sollte 2.0 sein")

func test_zwischenwerte() -> void:
	track.add_key(0.0, 0.0)
	track.add_key(1.0, 10.0)

	check_eq(track.sample(0.5), 5.0, "sample(0.5) sollte 5.0 sein")
	check_eq(track.sample(-1.0), 0.0, "sample(-1) sollte 0.0 sein")
	check_eq(track.sample(3.0), 10.0, "sample(3) sollte 10.0 sein")

func test_ersetzen() -> void:
	track.add_key(1.0, 10.0)
	track.add_key(1.0, 20.0)

	check_eq(track.keys.size(), 1, "keys.size() sollte 1 sein")
	check_eq(track.sample(1.0), 20.0, "sample(1) sollte 20.0 sein")

func test_schleife() -> void:
	track.loop = true
	track.add_key(0.0, 0.0)
	track.add_key(2.0, 10.0)

	check_eq(track.sample(3.0), 5.0, "sample(3.0) bei loop=true sollte 5.0 sein")

func test_leer() -> void:
	track = KeyframeTrack.new()
	check_eq(track.sample(1.0), 0.0, "sample(1.0) bei leerer Spur sollte 0.0 sein")
