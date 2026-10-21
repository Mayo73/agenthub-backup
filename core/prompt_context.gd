class_name PromptContext
extends RefCounted

const MAX_OBJECTS := 30

static func object_line(model: SceneModel, id: String) -> String:
	var obj: Dictionary = model.get_object(id)
	if obj.is_empty():
		return ""
	var typ: String = obj["type"]
	var line: String = "%s (%s)" % [id, typ]
	var props: Dictionary = obj.get("props", {})
	if not props.is_empty():
		var keys: Array = props.keys()
		keys.sort()
		var prop_parts: Array[String] = []
		for key in keys:
			prop_parts.append("%s=%s" % [key, str(props[key])])
		line += ": " + ", ".join(prop_parts)
	return line

static func scene_lines(model: SceneModel) -> Array[String]:
	var result: Array[String] = []
	var count: int = model.order.size()
	result.append("Szene: %d Objekte" % count)
	var limit: int = min(count, MAX_OBJECTS)
	for i: int in range(limit):
		var oid: String = model.order[i]
		result.append("- " + object_line(model, oid))
	if count > MAX_OBJECTS:
		var rest: int = count - MAX_OBJECTS
		result.append("… und %d weitere" % rest)
	return result

static func build(model: SceneModel, selected: String = "", last_error: String = "") -> Array[String]:
	var lines: Array[String] = scene_lines(model)
	if model.has_object(selected):
		lines.append("Ausgewählt: " + object_line(model, selected))
	if not last_error.is_empty():
		lines.append("Letzter Fehler: " + last_error)
	return lines

static func as_text(lines: Array[String]) -> String:
	return "\n".join(lines)
