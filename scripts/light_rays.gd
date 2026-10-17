class_name LightRays
extends Node3D
## Lichtstrahlen von der Wasseroberfläche (LightRayLayout). Folgen der Kamera in x und z.

var rays: Array[MeshInstance3D] = []
var offsets: Array[Vector3] = []
var material: StandardMaterial3D
var time := 0.0


func _init() -> void:
	material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(0.75, 0.95, 1.0, LightRayLayout.MAX_ALPHA)
	offsets = LightRayLayout.offsets(LightRayLayout.COUNT, 5)
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.4
	mesh.bottom_radius = 1.8
	mesh.height = LightRayLayout.LENGTH
	for i in offsets.size():
		var m := MeshInstance3D.new()
		m.name = "Ray%d" % i
		m.mesh = mesh
		m.material_override = material
		m.position = offsets[i] + Vector3(0.0, -LightRayLayout.LENGTH * 0.5, 0.0)
		add_child(m)
		rays.append(m)


## Ein Schritt: der Kamera waagrecht folgen, Strahlen neigen, Deckkraft nach Tiefe der Kamera.
func update(camera_pos: Vector3, delta: float) -> void:
	time += delta
	position = Vector3(camera_pos.x, 0.0, camera_pos.z)
	for i in rays.size():
		rays[i].rotation.z = LightRayLayout.tilt(time, i)
	material.albedo_color.a = LightRayLayout.alpha_for_depth(FishWorld.depth_of(camera_pos))
