extends "res://tests/base_test.gd"

func test_texturen_geladen() -> void:
	check_eq(FishTextures.SAND.get_width(), 512, "Sand-Textur hat Breite 512")
	check_eq(FishTextures.ROCK.get_width(), 512, "Fels-Textur hat Breite 512")


func test_boden() -> void:
	var m := FishTextures.floor_material()
	check(m.albedo_texture == FishTextures.SAND, "Boden verwendet Sand-Textur")
	check_eq(m.uv1_scale.x, 60.0, "Boden UV-Scale x ist 60.0")
	check_eq(m.cull_mode, BaseMaterial3D.CULL_DISABLED, "Boden CullMode ist DISABLED")


func test_fels() -> void:
	var m := FishTextures.rock_material()
	check(m.albedo_texture == FishTextures.ROCK, "Felsen verwendet Fels-Textur")
	check(m.uv1_triplanar == true, "Felsen hat triplanar UVs")
