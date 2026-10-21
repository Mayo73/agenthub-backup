extends "res://tests/base_test.gd"

var a: GravityZone3D
var b: GravityZone3D
const standard_g: Vector3 = Vector3(0, -9.8, 0)


func setup() -> void:
	a = GravityZone3D.new(AABB(Vector3(0, 0, 0), Vector3(10, 10, 10)), Vector3.ZERO, 0)
	b = GravityZone3D.new(AABB(Vector3(5, 0, 0), Vector3(10, 10, 10)), Vector3(0, 9.8, 0), 1)


func teardown() -> void:
	a = null
	b = null


func test_zone() -> void:
	# Bei (1, 1, 1) ist nur Zone a aktiv (Zonen überlappen, b beginnt bei x=5)
	var result := GravityZone3D.gravity_at([a, b], Vector3(1, 1, 1), standard_g)
	check_eq(result, Vector3.ZERO, "nur a: expected ZERO gravity")


func test_prioritaet() -> void:
	# Bei (6, 1, 1) sind beide Zonen aktiv; b hat höhere Priorität → Auftrieb
	var result := GravityZone3D.gravity_at([a, b], Vector3(6, 1, 1), standard_g)
	check_eq(result, Vector3(0, 9.8, 0), "b mit höherer Prioritaet: expected Auftrieb")


func test_draussen() -> void:
	# Bei (20, 1, 1) ist keine Zone aktiv → Standard-Schwerkraft
	var result := GravityZone3D.gravity_at([a, b], Vector3(20, 1, 1), standard_g)
	check_eq(result, standard_g, "draussen: expected default gravity")


func test_gleichstand() -> void:
	# Gleichstand der Prioritaeten → erste Zone in Liste gewinnt
	b.priority = 0
	var result := GravityZone3D.gravity_at([a, b], Vector3(6, 1, 1), standard_g)
	check_eq(result, Vector3.ZERO, "Gleichstand: erste Zone (a) gewinnt")
