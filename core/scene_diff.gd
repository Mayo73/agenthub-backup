class_name SceneDiff
extends RefCounted

## Vergleicht zwei Schnappschüsse des Szenenmodells und liefert die Änderungen.
## Ein Schnappschuss hat die Form von SceneModel.to_dict().


static func diff(before: Dictionary, after: Dictionary) -> Array[Dictionary]:
	var changes: Array[Dictionary] = []

	var before_objs: Array = before.get("objects", [])
	var after_objs: Array = after.get("objects", [])

	# Listen in Dictionaries umwandeln: id -> obj
	var before_dict := {}
	for obj: Dictionary in before_objs:
		var oid: String = obj["id"]
		before_dict[oid] = obj
	var after_dict := {}
	for obj: Dictionary in after_objs:
		var oid: String = obj["id"]
		after_dict[oid] = obj

	# Kennungen beider Stände sammeln und sortiert durchgehen
	var all_ids: Array[String] = []
	for id in before_dict.keys():
		all_ids.append(id)
	for id in after_dict.keys():
		if not all_ids.has(id):
			all_ids.append(id)
	all_ids.sort()

	var changed_entries: Array[Dictionary] = []

	for id: String in all_ids:
		var has_before := before_dict.has(id)
		var has_after := after_dict.has(id)

		if not has_before and has_after:
			# nur in after → added
			var after_obj: Dictionary = after_dict[id]
			changed_entries.append({"op": "added", "id": id, "type": after_obj["type"] as String})
		elif has_before and not has_after:
			# nur in before → removed
			var before_obj: Dictionary = before_dict[id]
			changed_entries.append({"op": "removed", "id": id, "type": before_obj["type"] as String})
		else:
			# in beiden: auf parent und props prüfen
			var before_obj: Dictionary = before_dict[id]
			var after_obj: Dictionary = after_dict[id]

			var old_parent: String = before_obj.get("parent", "")
			var new_parent: String = after_obj.get("parent", "")

			if old_parent != new_parent:
				changed_entries.append({"op": "moved", "id": id, "old": old_parent, "new": new_parent})

			# jede Eigenschaft (Schlüssel beider props zusammen, sortiert)
			var all_props: Array[String] = []
			for key in before_obj.get("props", {}):
				if not all_props.has(key):
					all_props.append(key)
			for key in after_obj.get("props", {}):
				if not all_props.has(key):
					all_props.append(key)
			all_props.sort()

			for prop_key: String in all_props:
				var has_old: bool = before_obj.get("props", {}).has(prop_key)
				var has_new: bool = after_obj.get("props", {}).has(prop_key)

				if not has_old and has_new:
					changed_entries.append({"op": "changed", "id": id, "key": prop_key, "old": null, "new": after_obj["props"][prop_key]})
				elif has_old and not has_new:
					changed_entries.append({"op": "changed", "id": id, "key": prop_key, "old": before_obj["props"][prop_key], "new": null})
				elif has_old and has_new:
					var old_val = before_obj["props"][prop_key]
					var new_val = after_obj["props"][prop_key]
					if old_val != new_val:
						changed_entries.append({"op": "changed", "id": id, "key": prop_key, "old": old_val, "new": new_val})

	# changed_entries werden in der Reihenfolge hinzugefügt (moved zuerst, dann props)
	for entry: Dictionary in changed_entries:
		changes.append(entry)

	return changes


static func summary(changes: Array[Dictionary]) -> String:
	var added := 0
	var removed := 0
	var moved := 0
	var changed := 0

	for change: Dictionary in changes:
		match change.get("op", ""):
			"added":
				added += 1
			"removed":
				removed += 1
			"moved":
				moved += 1
			"changed":
				changed += 1

	return "%d neu, %d entfernt, %d verschoben, %d geändert" % [added, removed, moved, changed]
