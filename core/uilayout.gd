class_name UiLayout
extends RefCounted
## Modell für einfache UI-Elemente eines Spielmenüs.

const KINDS: Array[String] = ["button", "label", "slider"]

var elements: Array[Dictionary] = []


func add(id: String, kind: String, rect: Rect2, text: String = "") -> CommandResult:
	if not KINDS.has(kind):
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Unbekannte Art %s" % kind)
	for e in elements:
		var id_e: String = e["id"]
		if id_e == id:
			return CommandResult.error(CommandResult.CONFLICT, "Element %s gibt es schon" % id)

	var element := {
		"id": id,
		"kind": kind,
		"rect": rect,
		"text": text,
		"enabled": true,
		"value": 0.0
	}
	elements.append(element)
	return CommandResult.success({"id": id})


func find(id: String) -> Dictionary:
	for e in elements:
		var id_e: String = e["id"]
		if id_e == id:
			return e
	return {}


func hit_test(point: Vector2) -> String:
	for i in range(elements.size() - 1, -1, -1):
		var element: Dictionary = elements[i]
		var r: Rect2 = element["rect"]
		var enabled_on: bool = element["enabled"]
		var kind: String = element["kind"]

		if not enabled_on:
			continue
		if kind == "label":
			continue

		if r.has_point(point):
			return element["id"]

	return ""


func set_enabled(id: String, on: bool) -> void:
	for e in elements:
		var id_e: String = e["id"]
		if id_e == id:
			e["enabled"] = on
			return


func set_value(id: String, v: float) -> float:
	for e in elements:
		var id_e: String = e["id"]
		var kind: String = e["kind"]

		if id_e == id and kind == "slider":
			e["value"] = clampf(v, 0.0, 1.0)
			return e["value"]
		elif id_e == id and kind != "slider":
			return -1.0

	return -1.0


func focus_order() -> Array[String]:
	var active_elements: Array[Dictionary] = []
	for e in elements:
		var kind: String = e["kind"]
		var enabled_on: bool = e["enabled"]

		if enabled_on and kind != "label":
			active_elements.append(e)

	# Sortieren nach y (rect.position.y), dann nach x (rect.position.x)
	active_elements.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ay: float = a["rect"].position.y
		var by: float = b["rect"].position.y

		if ay != by:
			return ay < by

		var ax: float = a["rect"].position.x
		var bx: float = b["rect"].position.x
		return ax < bx
	)

	var ids: Array[String] = []
	for e in active_elements:
		ids.append(e["id"])

	return ids
