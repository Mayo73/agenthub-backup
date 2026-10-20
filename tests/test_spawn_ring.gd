extends "res://tests/base_test.gd"

var spawn_ring: SpawnRing
var floor: SeafloorHeight
var center := Vector3(1000.0, -20.0, -400.0)


func setup() -> void:
	spawn_ring = SpawnRing.new(5)
	floor = SeafloorHeight.new(7)


func teardown() -> void:
	pass  # RefCounted-Objekte werden automatisch verwaltet


func test_abstand() -> void:
	for i in 50:
		var pos := spawn_ring.next_position(center, floor)
		var dist := SpawnRing.flat_distance(pos, center)
		check(dist >= 40.0 and dist <= 110.0, "Abstand bei Aufruf %d ist %f, muss zwischen 40 und 110 liegen" % [i, dist])


func test_im_wasser() -> void:
	for i in 50:
		var pos := spawn_ring.next_position(center, floor)
		check(FloorClamp.is_in_water(pos, floor), "Position bei Aufruf %d ist nicht im Wasser: %s" % [i, pos])


func test_bodennah() -> void:
	for i in 50:
		var pos := spawn_ring.near_floor_position(center, floor)
		var height := FloorClamp.height_above_floor(pos, floor)
		check(is_equal_approx(height, 1.5), "Höhe bei Aufruf %d ist %f, soll ungefähr 1.5 sein" % [i, height])


func test_gleicher_seed() -> void:
	var ring1 := SpawnRing.new(5)
	var ring2 := SpawnRing.new(5)

	var pos1 := ring1.next_position(center, floor)
	var pos2 := ring2.next_position(center, floor)

	check(is_equal_approx(pos1.x, pos2.x), "Erster x-Wert stimmt nicht überein")
	check(is_equal_approx(pos1.y, pos2.y), "Erster y-Wert stimmt nicht überein")
	check(is_equal_approx(pos1.z, pos2.z), "Erster z-Wert stimmt nicht überein")


func test_weit_weg() -> void:
	check(SpawnRing.is_far(Vector3(0.0, -10.0, 200.0), Vector3.ZERO), "Position (0, -10, 200) soll weit sein")
	check(!SpawnRing.is_far(Vector3(0.0, -10.0, 100.0), Vector3.ZERO), "Position (0, -10, 100) soll nicht weit sein")
	check(is_equal_approx(SpawnRing.flat_distance(Vector3(3.0, -50.0, 4.0), Vector3.ZERO), 5.0), "flat_distance sollte 5.0 sein")
