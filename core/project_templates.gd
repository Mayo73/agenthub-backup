class_name ProjectTemplates
extends RefCounted

## Statische Vorlagen für neue 2D- und 3D-Projekte.
## Nur statische Funktionen, keine Instanzerzeugung nötig.


static func names() -> Array[String]:
	return ["leer_2d", "leer_3d"]


static func title(name: String) -> String:
	match name:
		"leer_2d":
			return "Leeres 2D-Projekt"
		"leer_3d":
			return "Leeres 3D-Projekt"
		_:
			return ""


static func create(name: String) -> SceneModel:
	if name == "leer_2d":
		var model: SceneModel = SceneModel.new()
		model.add_object("Node2D", "", {"name": "Welt"})
		model.add_object("Camera2D", "o1", {"name": "Kamera", "position": Vector2(0, 0)})
		model.add_object("StaticBody2D", "o1", {"name": "Boden", "position": Vector2(0, 300)})
		return model
	elif name == "leer_3d":
		var model: SceneModel = SceneModel.new()
		model.add_object("Node3D", "", {"name": "Welt"})
		model.add_object("Camera3D", "o1", {"name": "Kamera", "position": Vector3(0, 2, 6)})
		model.add_object("DirectionalLight3D", "o1", {"name": "Sonne", "rotation_degrees": Vector3(-45, 30, 0)})
		model.add_object("StaticBody3D", "o1", {"name": "Boden", "position": Vector3(0, 0, 0)})
		return model
	else:
		return null


static func describe(name: String) -> Dictionary:
	var result: Dictionary = {}
	if title(name).is_empty():
		return result
	result["name"] = name
	result["title"] = title(name)
	result["objects"] = create(name).order.size()
	return result
