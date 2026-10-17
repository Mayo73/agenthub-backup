class_name FishFoodView
extends Node3D
## Zeichnet die Nahrung aus FishFood: grüne Algenbüschel und rote Krebschen, ein Knoten je Stück.

var field: FishFood
var plant_mesh := FishModel.sphere(0.3)
var meat_mesh := FishModel.box(Vector3(0.35, 0.2, 0.25))
var plant_mat := FishModel.material(Color(0.42, 0.8, 0.37))
var meat_mat := FishModel.material(Color(0.85, 0.33, 0.31))


## Gleicht Anzahl, Form und Lage der Knoten mit field.items ab.
func refresh() -> void:
	if field == null:
		return
	while get_child_count() < field.items.size():
		add_child(MeshInstance3D.new())
	while get_child_count() > field.items.size():
		var last := get_child(get_child_count() - 1)
		remove_child(last)
		last.free()
	for i in field.items.size():
		var item: Dictionary = field.items[i]
		var m := get_child(i) as MeshInstance3D
		var plant: bool = item["kind"] == Diet.PFLANZE
		m.mesh = plant_mesh if plant else meat_mesh
		m.material_override = plant_mat if plant else meat_mat
		m.position = item["position"]


func _process(_delta: float) -> void:
	refresh()
