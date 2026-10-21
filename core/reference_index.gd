class_name ReferenceIndex
extends RefCounted
## Verzeichnet Objekte, welche auf andere verweisen, damit Löschen/Umbenennen keine kaputten
## Referenzen hinterlässt. Einträge haben die Form {"from": String, "prop": String, "to": String}.

## Alle gespeicherten Referenzen in Einfügereihenfolge.
var refs: Array[Dictionary] = []


## Eine neue Referenz hinzufügen: von `from_id` über Eigenschaft `prop` nach `to_id`.
## Wenn es schon einen Eintrag mit gleichem `from` und `prop` gibt, wird nur `to` ersetzt;
## sonst wird ein neuer Eintrag angehängt.
func link(from_id: String, prop: String, to_id: String) -> void:
	for r in refs:
		if r["from"] == from_id and r["prop"] == prop:
			r["to"] = to_id
			return
	refs.append({"from": from_id, "prop": prop, "to": to_id})


## Referenz(en) von `from_id` über Eigenschaft `prop` entfernen.
## Gibt `true` zurück, wenn mindestens ein Eintrag entfernt wurde, sonst `false`.
func unlink(from_id: String, prop: String) -> bool:
	var before_size := refs.size()
	refs.erase(func(r: Dictionary) -> bool:
		return r["from"] == from_id and r["prop"] == prop
	)
	return refs.size() < before_size


## Alle `to`-IDs zurückgeben, auf die `from_id` verweist (über beliebige Eigenschaften).
## Ergebnisse sind sortiert und enthalten keine Duplikate.
func targets_of(from_id: String) -> Array[String]:
	var result: Array[String] = []
	for r in refs:
		if r["from"] == from_id:
			var to: String = str(r["to"])
			if not result.has(to):
				result.append(to)
	result.sort()
	return result


## Alle `from`-IDs zurückgeben, die auf `to_id` verweisen (über beliebige Eigenschaften).
## Ergebnisse sind sortiert und enthalten keine Duplikate.
func referrers_of(to_id: String) -> Array[String]:
	var result: Array[String] = []
	for r in refs:
		if r["to"] == to_id:
			var from: String = str(r["from"])
			if not result.has(from):
				result.append(from)
	result.sort()
	return result


## Alle Referenz-Einträge entfernen, bei denen `id` als `from` oder `to` vorkommt.
## Gibt die Anzahl entfernter Einträge zurück.
func remove_object(id: String) -> int:
	var before_size := refs.size()
	refs = refs.filter(func(r: Dictionary) -> bool:
		return r["from"] != id and r["to"] != id
	)
	return before_size - refs.size()


## Alle Referenzen mit alter ID `old_id` umbenennen in `new_id`, sowohl bei `from` als auch `to`.
func rename(old_id: String, new_id: String) -> void:
	for r in refs:
		if r["from"] == old_id:
			r["from"] = new_id
		if r["to"] == old_id:
			r["to"] = new_id


## Alle verwaisten Referenzen zurückgeben: Einträge, deren `to`-Wert nicht in `existing` steht.
## Werden in Einfügereihenfolge zurückgegeben.
func dangling(existing: Array[String]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for r in refs:
		if not existing.has(r["to"]):
			result.append(r)
	return result


## Den Index als Dictionary serialisieren (nur die `refs`-Array).
func to_dict() -> Dictionary:
	return {"refs": refs}


## Einen Index aus einem serialized Dictionary rekonstruieren.
## Werte werden mit `str(...)` gelesen, um Typen zu garantieren.
static func from_dict(d: Dictionary) -> ReferenceIndex:
	var idx := ReferenceIndex.new()
	if d.has("refs"):
		for item in d["refs"]:
			idx.refs.append({
				"from": str(item.get("from", "")),
				"prop": str(item.get("prop", "")),
				"to": str(item.get("to", ""))
			})
	return idx
