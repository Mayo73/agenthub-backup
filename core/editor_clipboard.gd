class_name EditorClipboard
extends RefCounted

## Struktur: {"key": String, "type": String, "parent_key": String, "props": Dictionary}
var items: Array[Dictionary] = []


## Objekte mit Kennungen ids kopieren. parent_key ist "" für Wurzeln.
func copy(model: SceneModel, ids: Array[String]) -> int:
	items.clear()

	# Rekursiv alle Unterobjekte sammeln und Eltern vor Kindern speichern
	# Mappe alte IDs auf neue Schlüssel (die beim Kopieren vergeben werden)
	var seen_ids: Dictionary = {}

	for id in ids:
		if not model.has_object(id):
			continue
		_collect_for_copy(model, id, "", seen_ids)

	return items.size()


## Rekursiv Objekte für die Zwischenablage sammeln (Tiefe-first, aber Eltern zuerst)
func _collect_for_copy(model: SceneModel, id: String, parent_key: String, seen_ids: Dictionary) -> void:
	if seen_ids.has(id):
		return

	var obj: Dictionary = model.get_object(id)
	if obj.is_empty():
		return

	# neuen Schlüssel vergeben (der im item gespeichert wird)
	var key: String = "clip_%d" % items.size()

	items.append({
		"key": key,
		"type": obj["type"],
		"parent_key": parent_key,
		"props": obj["props"].duplicate(true)
	})

	seen_ids[id] = true

	# Kinder rekursiv verarbeiten
	var child_ids: Array[String] = model.children(id)
	for cid in child_ids:
		_collect_for_copy(model, cid, key, seen_ids)


## Einträge einfügen. parent_id ist die Ziel-ID für Wurzeln.
## Rückgabe: neue Kennungen der Wurzeln.
func paste(model: SceneModel, parent_id: String = "") -> Array[String]:
	if is_empty():
		return []

	if not parent_id.is_empty() and not model.has_object(parent_id):
		return []

	var new_ids: Array[String] = []
	var old_to_new: Dictionary = {}

	# Einträge der Reihe nach verarbeiten
	for item in items:
		var obj_type: String = item["type"]
		var parent_key: String = item["parent_key"]

		var target_parent: String = ""
		if parent_key.is_empty():
			target_parent = parent_id
		else:
			# Parent war kein Wurzelelement, neue ID daraus holen
			var old_parent_item: Dictionary = _find_item_by_key(parent_key)
			if old_parent_item.is_empty():
				continue
			target_parent = old_to_new.get(old_parent_item["key"], "")

		# Neues Objekt anlegen
		var new_id: String = model.add_object(obj_type, target_parent, item["props"].duplicate(true))
		old_to_new[item["key"]] = new_id

		if parent_key.is_empty():
			new_ids.append(new_id)

	return new_ids


## Item im items-Array nach key finden
func _find_item_by_key(key: String) -> Dictionary:
	for item in items:
		if item["key"] == key:
			return item
	return {}


## Rückgabe, ob die Zwischenablage leer ist.
func is_empty() -> bool:
	return items.is_empty()
