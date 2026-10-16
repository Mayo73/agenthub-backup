class_name PartUnlocks
extends RefCounted
## Welche Teile der Spieler schon im Zelleditor verwenden darf.

var unlocked: Array[String] = []


func _init() -> void:
	for id in PartCatalog.STARTER:
		unlocked.append(id)


func is_unlocked(id: String) -> bool:
	return unlocked.has(id)


## Schaltet ein Teil frei. false, wenn es unbekannt oder schon frei ist.
func unlock(id: String) -> bool:
	if not PartCatalog.exists(id) or unlocked.has(id):
		return false
	unlocked.append(id)
	return true


## Das nächste noch gesperrte Teil laut PartCatalog.UNLOCK_ORDER, "" wenn alle frei sind.
func next_locked() -> String:
	for id in PartCatalog.UNLOCK_ORDER:
		if not unlocked.has(id):
			return id
	return ""


func all_unlocked() -> bool:
	return next_locked() == ""
