extends "res://tests/base_test.gd"

var view: FishFoodView

func setup() -> void:
	view = FishFoodView.new()
	view.field = FishFood.new()

func teardown() -> void:
	view.free()


func test_leer() -> void:
	view.refresh()
	check_eq(view.get_child_count(), 0, "keine Kinder bei leerem Feld")


func test_stuecke() -> void:
	view.field.add_item(Diet.PFLANZE, Vector3(1, -55, 2))
	view.field.add_item(Diet.FLEISCH, Vector3(0, -10, 0))
	view.refresh()
	check_eq(view.get_child_count(), 2, "zwei Kinder nach zwei Stücken")
	var child0 := view.get_child(0) as MeshInstance3D
	var child1 := view.get_child(1) as MeshInstance3D
	check_eq(child0.position, Vector3(1, -55, 2), "Position erstes Kind stimmt")
	check_eq(child1.position, Vector3(0, -10, 0), "Position zweites Kind stimmt")
	check(child0.mesh is SphereMesh, "erstes Kind ist Kugel (Pflanze)")
	check(child1.mesh is BoxMesh, "zweites Kind ist Quader (Fleisch)")


func test_gefressen() -> void:
	view.field.add_item(Diet.PFLANZE, Vector3(1, -55, 2))
	view.field.add_item(Diet.FLEISCH, Vector3(0, -10, 0))
	view.refresh()
	check_eq(view.get_child_count(), 2, "zwei Kinder nach zwei Stücken")
	view.field.items.remove_at(0)
	view.refresh()
	check_eq(view.get_child_count(), 1, "ein Kind nach Entfernen eines Stücks")


func test_ohne_feld() -> void:
	var v := FishFoodView.new()
	v.refresh()
	check_eq(v.get_child_count(), 0, "keine Kinder ohne Feld")
	v.free()
