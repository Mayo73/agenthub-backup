class_name FishTextures
extends RefCounted
## Texturen der Fischphase: Sandboden und Felsen (Higgsfield, A-0017 und A-0018).

const SAND := preload("res://assets/fish/sand.png")
const ROCK := preload("res://assets/fish/fels.png")
## So oft wiederholt sich die Sandtextur über die ganze Bodenfläche (300 m).
const SAND_REPEAT := 60.0


## Boden: Sand, oft wiederholt, von beiden Seiten sichtbar.
static func floor_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = SAND
	mat.uv1_scale = Vector3(SAND_REPEAT, SAND_REPEAT, 1.0)
	mat.texture_repeat = true
	mat.roughness = 0.95
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat


## Felsen: Steintextur, triplanar über die ganze Form gelegt.
static func rock_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = ROCK
	mat.uv1_triplanar = true
	mat.uv1_scale = Vector3.ONE * 0.5
	mat.roughness = 0.9
	return mat
