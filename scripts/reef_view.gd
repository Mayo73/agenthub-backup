class_name ReefView
extends Node3D
## Zeichnet Seegras und Felsen aus ReefLayout. Das Seegras wiegt sich leicht.

var layout := ReefLayout.new()
var weeds: Array[MeshInstance3D] = []
var time := 0.0


func _init() -> void:
	var weed_mat := FishModel.material(Color(0.25, 0.55, 0.3))
	var rock_mat := FishModel.material(Color(0.42, 0.4, 0.38))
	for item: Dictionary in layout.items:
		var m := MeshInstance3D.new()
		var h: float = item["height"]
		var p: Vector3 = item["position"]
		if item["kind"] == "seegras":
			var c := CylinderMesh.new()
			c.top_radius = 0.05
			c.bottom_radius = 0.18
			c.height = h
			m.mesh = c
			m.material_override = weed_mat
			m.position = p + Vector3(0.0, h * 0.5, 0.0)
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
