class_name ContactLog
extends RefCounted

## Kontakte pro Physikschritt protokollieren
var contacts: Array[Dictionary] = []

## Kontakt hinzufügen. Kennungen werden sortiert gespeichert (a < b).
## Bei Vertauschung wird die Normale umgedreht.
func add(step: int, a: String, b: String, point: Vector2, normal: Vector2, impulse: float = 0.0) -> void:
	if a > b:
		# Vertauschen und Normale umdrehen
		var tmp: String = a
		a = b
		b = tmp
		normal = -normal

	var contact: Dictionary = {
		"step": step,
		"a": a,
		"b": b,
		"point": [point.x, point.y],
		"normal": [normal.x, normal.y],
		"impulse": impulse
	}
	contacts.append(contact)

## Alle Kontakte zwischen zwei Objekten zurückgeben (Reihenfolge der Kennungen egal)
func between(x: String, y: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for c: Dictionary in contacts:
		var obj_a: String = c["a"]
		var obj_b: String = c["b"]
		if (obj_a == x and obj_b == y) or (obj_a == y and obj_b == x):
			result.append(c)
	return result

## Alle Kontakte mit einem bestimmten Objekt zurückgeben
func of(object_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for c: Dictionary in contacts:
		if c["a"] == object_id or c["b"] == object_id:
			result.append(c)
	return result

## Alle Kontakte zu einem bestimmten Schritt zurückgeben
func at_step(step: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for c: Dictionary in contacts:
		if c["step"] == step:
			result.append(c)
	return result

## Kontakt mit dem größten Impuls zurückgeben, bei leerem Protokoll {}
func strongest() -> Dictionary:
	if contacts.is_empty():
		return {}

	var max_impulse: float = -INF
	var strongest_contact: Dictionary = {}

	for c: Dictionary in contacts:
		var impulse: float = c["impulse"]
		if impulse > max_impulse:
			max_impulse = impulse
			strongest_contact = c

	return strongest_contact

## Alle Kontakte mit kleinerem Schritt entfernen, gibt Anzahl zurück
func clear_before(step: int) -> int:
	var count: int = 0
	var remaining: Array[Dictionary] = []

	for c: Dictionary in contacts:
		if c["step"] < step:
			count += 1
		else:
			remaining.append(c)

	contacts = remaining
	return count
