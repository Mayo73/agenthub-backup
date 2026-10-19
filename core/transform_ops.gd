class_name TransformOps
extends RefCounted
## Verschieben, Drehen und Skalieren von Objekten im Szenenmodell.
## Eigenschaften wie in Godot: position, rotation_degrees, scale.
## Ein Objekt ist 3D, wenn sein Typ auf „3D“ endet, sonst 2D.


static func is_3d(model: SceneModel, id: String) -> bool:
	var obj: Dictionary = model.get_object(id)
	var type: String = obj.get("type", "")
	return type.ends_with("3D")


static func _vec(values: Array, three: bool) -> Variant:
	if three:
		return Vector3(float(values[0]), float(values[1]), float(values[2]))
	return Vector2(float(values[0]), float(values[1]))


static func _list(v: Variant) -> Array:
	if v is Vector3:
		return [v.x, v.y, v.z]
	return [v.x, v.y]


static func _missing(id: String) -> CommandResult:
	return CommandResult.error(CommandResult.NOT_FOUND, "Objekt %s gibt es nicht" % id)


static func _wrong_count(n: int) -> CommandResult:
	return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Erwartet %d Werte" % n)


static func move(model: SceneModel, id: String, delta: Array) -> CommandResult:
	if not model.has_object(id):
		return _missing(id)
	var three := is_3d(model, id)
	var n: int = 3 if three else 2
	if delta.size() != n:
		return _wrong_count(n)
	var start: Variant = Vector3.ZERO if three else Vector2.ZERO
	var pos: Variant = model.get_property(id, "position", start) + _vec(delta, three)
	model.set_property(id, "position", pos)
	return CommandResult.success({"position": _list(pos)})


static func rotate(model: SceneModel, id: String, degrees: Array) -> CommandResult:
	if not model.has_object(id):
		return _missing(id)
	var three := is_3d(model, id)
	var n: int = 3 if three else 1
	if degrees.size() != n:
		return _wrong_count(n)
	if three:
		var rot3: Vector3 = model.get_property(id, "rotation_degrees", Vector3.ZERO)
		rot3 += _vec(degrees, true)
		model.set_property(id, "rotation_degrees", rot3)
		return CommandResult.success({"rotation_degrees": _list(rot3)})
	var rot: float = float(model.get_property(id, "rotation_degrees", 0.0)) + float(degrees[0])
	model.set_property(id, "rotation_degrees", rot)
	return CommandResult.success({"rotation_degrees": rot})


static func scale_by(model: SceneModel, id: String, factor: float) -> CommandResult:
	if not model.has_object(id):
		return _missing(id)
	if factor <= 0.0:
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Faktor muss größer als 0 sein")
	var one: Variant = Vector3.ONE if is_3d(model, id) else Vector2.ONE
	var scale: Variant = model.get_property(id, "scale", one) * factor
	model.set_property(id, "scale", scale)
	return CommandResult.success({"factor": factor})


static func register_all(commands: CommandRegistry, model: SceneModel) -> void:
	commands.register(
		"transform.move",
		"Verschiebt ein Objekt um die angegebenen Werte.",
		{"id": "string", "delta": "array"},
		func(args: Dictionary) -> CommandResult:
			var delta: Array = args["delta"]
			return move(model, str(args["id"]), delta)
	)
	commands.register(
		"transform.rotate",
		"Dreht ein Objekt um die angegebenen Grad.",
		{"id": "string", "degrees": "array"},
		func(args: Dictionary) -> CommandResult:
			var degrees: Array = args["degrees"]
			return rotate(model, str(args["id"]), degrees)
	)
	commands.register(
		"transform.scale",
		"Skaliert ein Objekt mit einem Faktor.",
		{"id": "string", "factor": "number"},
		func(args: Dictionary) -> CommandResult:
			return scale_by(model, str(args["id"]), float(args["factor"]))
	)
