extends "res://tests/base_test.gd"

var reef: ReefView


func setup() -> void:
	reef = ReefView.new()


func teardown() -> void:
	reef.free()


func test_felsen_textur() -> void:
	var has_rock_material := false
	for child in reef.get_children():
		if child is MeshInstance3D and (child as MeshInstance3D).mesh is SphereMesh:
			var mat := (child as MeshInstance3D).material_override
			if mat is StandardMaterial3D and (mat as StandardMaterial3D).albedo_texture == FishTextures.ROCK:
				has_rock_material = true
				break
	check(has_rock_material, "Mindestens ein Felsen hat ROCK-Textur")


func test_seegras_gebogen() -> void:
	var has_bent_seagrass := false
	for child in reef.get_children():
		if child is MeshInstance3D and (child as MeshInstance3D).mesh is ArrayMesh:
			has_bent_seagrass = true
			break
	check(has_bent_seagrass, "Das erste Seegras hat ein ArrayMesh")
