class_name ReefView
extends Node3D
## Zeichnet Seegras und Felsen aus ReefLayout. Das Seegras wiegt sich leicht.

var layout := ReefLayout.new()
var weeds: Array[MeshInstance3D] = []
var time := 0.0


func _init() -> void:
	var weed_mat := FishModel.material(Color(0.25, 0.55, 0.3))
	var rock_mat := FishTextures.rock_material()
	for item: Dictionary in layout.items:
		var m := MeshInstance3D.new()
		var h: float = item["height"]
		var p: Vector3 = item["position"]
		if item["kind"] == "seegras":
			var bend: float = item["bend"]
			m.mesh = SeaweedShape.build_mesh(h, bend)
			var mat := weed_mat.duplicate()
			mat.cull_mode = BaseMaterial3D.CULL_DISABLED
			m.material_override = mat
			m.position = p
			weeds.append(m)
		else:
			m.mesh = FishModel.sphere(1.0)
			m.material_override = rock_mat
			m.position = p
			m.scale = Vector3(h, h * 0.6, h * 0.8)
		add_child(m)


## Neigung eines Seegrashalms zum Zeitpunkt t; phase verschiebt jeden Halm etwas.
static func sway(t: float, phase: float) -> float:
	return sin(t * 0.8 + phase) * 0.12


func _process(delta: float) -> void:
	time += delta
	for i in weeds.size():
		weeds[i].rotation.z = sway(time, i * 0.7)
