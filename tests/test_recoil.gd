extends "res://tests/base_test.gd"

func setup() -> void:
	pass

func teardown() -> void:
	pass

func test_schuesse() -> void:
	var recoil: Recoil = Recoil.new()
	recoil.fire()
	recoil.fire()
	recoil.fire()
	check_eq(recoil.pitch, 6.0, "nach drei Schüssen pitch = 6.0")
	recoil.step(0.1)
	check_eq(recoil.pitch, 5.0, "nach step(0.1) pitch = 5.0")

func test_grenze() -> void:
	var recoil: Recoil = Recoil.new()
	for i in range(10):
		recoil.fire()
	check_eq(recoil.pitch, 10.0, "nach zehn Schüssen pitch = max_pitch = 10.0")

func test_erholung() -> void:
	var recoil: Recoil = Recoil.new()
	recoil.fire()
	recoil.step(2.0)
	check_eq(recoil.pitch, 0.0, "nach step(2.0) pitch = 0.0")

	var recoil2: Recoil = Recoil.new()
	recoil2.fire()
	recoil2.reset()
	check_eq(recoil2.pitch, 0.0, "nach reset() pitch = 0.0")
