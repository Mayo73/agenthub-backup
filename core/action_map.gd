class_name ActionMap
extends RefCounted
## Verwaltet Eingabeaktionen mit Tasten und Maustasten.
## Aktionen sind Textnamen, Eingaben sind "taste:<name>" oder "maus:<seite>".

var actions: Dictionary = {}  # Aktion -> Array Eingaben

const VALID_MOUSE_BUTTONS := ["links", "rechts", "mitte"]


static func is_valid_input(input: String) -> bool:
	"""Prüft, ob input eine gültige Taste oder Maustaste ist."""
	if not input or input.is_empty():
		return false

	if input.begins_with("maus:"):
		var name := input.substr(5)
		return name in VALID_MOUSE_BUTTONS

	if input.begins_with("taste:"):
		var keycode := OS.find_keycode_from_string(input.substr(6))
		return keycode != 0

	return false


func add_action(name: String) -> bool:
	"""Fügt eine neue Aktion hinzu. False bei leerem Namen oder vorhanden."""
	if name.is_empty():
		return false
	if actions.has(name):
		return false

	actions[name] = []
	return true


func bind(action: String, input: String) -> CommandResult:
	"""Bindet eine Eingabe an eine Aktion. Rückgabe bei fehlgeschlagenen Aktionen."""
	if not actions.has(action):
		return CommandResult.error(CommandResult.NOT_FOUND, "Aktion %s gibt es nicht" % [action])

	if not is_valid_input(input):
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Eingabe %s ist ungültig" % [input])

	var inputs := actions[action] as Array
	if input in inputs:
		return CommandResult.success({"action": action, "inputs": _to_list(inputs)})

	inputs.append(input)
	actions[action] = inputs
	return CommandResult.success({"action": action, "inputs": _to_list(inputs)})


func unbind(action: String, input: String) -> bool:
	"""Entfernt eine Eingabe von einer Aktion. False bei fehlender Aktion oder Eingabe."""
	if not actions.has(action):
		return false

	var inputs := actions[action] as Array
	if not input in inputs:
		return false

	inputs.erase(input)
	actions[action] = inputs
	return true


func actions_for(input: String) -> Array:
	"""Gibt alle Aktionen zurück, die diese Eingabe haben (sortiert)."""
	var result := []
	for action_name in actions.keys():
		if input in actions[action_name]:
			result.append(action_name)
	result.sort()
	return result


func to_dict() -> Dictionary:
	"""Konvertiert den ActionMap-Zustand in ein Dictionary."""
	var result := {}
	for key in actions.keys():
		result[key] = []
		for input in actions[key]:
			result[key].append(str(input))
	return result


static func from_dict(d: Dictionary) -> ActionMap:
	"""Erstellt einen ActionMap aus einem Dictionary. Ungültige Eingaben werden weggelassen."""
	var map := ActionMap.new()
	for key in d.keys():
		map.add_action(key)
		for input in d[key]:
			if is_valid_input(str(input)):
				map.actions[key].append(str(input))
	return map


func _to_list(arr: Array) -> Array:
	"""Kopiert ein Array von Eingaben."""
	var result := []
	for s in arr:
		result.append(s)
	return result
