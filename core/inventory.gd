extends RefCounted
class_name Inventory

## Stapelgrenzen für Gegenstände (Gegenstand → maximale Menge)
var limits: Dictionary = {}
## Gesammelte Gegenstände (Gegenstand → aktuelle Menge)
var slots: Dictionary = {}
## Maximal verschiedene Gegenstände (0 = unbegrenzt)
var capacity: int = 0

## Limit für einen Gegenstand setzen
func set_limit(item: String, max_count: int) -> void:
	limits[item] = max_count

## Aktuelle Anzahl eines Gegenstands abrufen (0 wenn nicht vorhanden)
func count(item: String) -> int:
	var have: int = int(slots.get(item, 0))
	return have

## Gegenstand hinzufügen. Gibt tatsächlich hinzugefügte Menge zurück.
func add(item: String, amount: int = 1) -> int:
	# amount <= 0 → nichts hinzufügen
	if amount <= 0:
		return 0

	# Prüfen ob capacity erreicht ist (neuer Gegenstand)
	var current_count: int = int(slots.get(item, 0))
	if capacity > 0 and current_count == 0:
		var distinct_items: int = slots.size()
		if distinct_items >= capacity:
			return 0

	# Prüfe Stapelgrenze
	var limit: int = int(limits.get(item, -1))
	var can_add: int = amount
	if limit > 0:
		var current: int = int(slots.get(item, 0))
		var free_space: int = limit - current
		if free_space < amount:
			can_add = free_space

	if can_add <= 0:
		return 0

	# Hinzufügen und zurückgeben
	slots[item] = current_count + can_add
	return can_add

## Gegenstand entfernen. Gibt true wenn erfolgreich.
func remove(item: String, amount: int = 1) -> bool:
	if amount <= 0:
		return false

	var current: int = int(slots.get(item, 0))
	if current < amount:
		return false

	slots[item] = current - amount
	if slots[item] == 0:
		slots.erase(item)

	return true

## Sortierte Liste aller Gegenstände als Array
func items() -> Array[String]:
	var result: Array[String] = []
	for key in slots.keys():
		result.append(key)
	result.sort()
	return result

## Prüfen ob das Inventar leer ist
func is_empty() -> bool:
	return slots.size() == 0

## Ins Dictionary für JSON Serialisierung
func to_dict() -> Dictionary:
	return {
		"slots": slots,
		"limits": limits,
		"capacity": capacity
	}

## Aus Dictionary laden (statisch)
static func from_dict(d: Dictionary) -> Inventory:
	var inv := Inventory.new()
	inv.slots = d.get("slots", {})
	inv.limits = d.get("limits", {})
	inv.capacity = int(d.get("capacity", 0))
	return inv
