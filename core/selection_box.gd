class_name SelectionBox
extends RefCounted


## Statische Funktion zum Überprüfen, welche Objekte in einem Rechteck ausgewählt werden.
## @param rects: Dictionary mit String-Kennungen als Schlüssel und Rect2-Werten als Werte
## @param area: Auswahlrechteck (kann rückwärts aufgezogen sein)
## @param mode: "touch" für Schnittpunkte, "inside" für vollständige Einschließung
## @return: Alphabetisch sortiertes Array mit den Kennungen der ausgewählten Objekte
static func pick(rects: Dictionary, area: Rect2, mode: String = "touch") -> Array:
	area = area.abs()
	var result: Array[String] = []

	for key in rects:
		var rect: Rect2 = rects[key]
		if mode == "touch" and area.intersects(rect):
			result.append(key)
		elif mode == "inside" and area.encloses(rect):
			result.append(key)

	result.sort()
	return result
