class_name MarineSnow
extends CPUParticles3D
## Schwebeteilchen im Wasser rund um die Kamera (FishMain setzt die Lage jedes Bild auf die Kamera).

## Größe des Bereichs, in dem Teilchen entstehen, in Metern.
const BOX := Vector3(30, 20, 30)


func _init() -> void:
	amount = 400
	lifetime = 8.0
	preprocess = 8.0
	local_coords = false
	emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	emission_box_extents = BOX * 0.5
	direction = Vector3(0, 1, 0)
	spread = 180.0
	gravity = Vector3(0, -0.05, 0)
	initial_velocity_min = 0.0
	initial_velocity_max = 0.15
	var quad := QuadMesh.new()
	quad.size = Vector2(0.06, 0.06)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.95, 1.0, 0.6)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	quad.material = mat
	mesh = quad

