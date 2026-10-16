class_name CellBuild
extends RefCounted
## Aufbau einer Zelle: eingebaute Teile mit Lage und Drehung.
## pos ist relativ zur Zellmitte in Zellradien (Länge 1 = Zellrand), Blickrichtung +x.
## angle ist die Drehung des Teils in Radiant (0 = zeigt nach vorn).
## Jedes Teil ist ein Dictionary {"id": String, "pos": Vector2, "angle": float}.

var parts: Array[Dictionary] = []


## Baut ein Teil ein und gibt seinen Index zurück, -1 bei unbekannter ID.
func add_part(id: String, pos: Vector2, angle: float = 0.0) -> int:
	if not PartCatalog.exists(id):
		return -1
	parts.append({"id": id, "pos": pos, "angle": angle})
	return parts.size() - 1


func remove_part(index: int) -> bool:
	if index < 0 or index >= parts.size():
		return false
	parts.remove_at(index)
	return true


func move_part(index: int, pos: Vector2) -> bool:
	if index < 0 or index >= parts.size():
		return false
	parts[index]["pos"] = pos
	return true


func rotate_part(index: int, angle: float) -> bool:
	if index < 0 or index >= parts.size():
		return false
	parts[index]["angle"] = angle
	return true


func count(id: String) -> int:
	var n := 0
	for p in parts:
		if p["id"] == id:
			n += 1
	return n


## IDs der eingebauten Mundwerkzeuge in Einbaureihenfolge.
func mouths() -> Array[String]:
	var result: Array[String] = []
	for p in parts:
		if PartCatalog.category_of(p["id"]) == "maul":
			result.append(p["id"])
	return result


func total_cost() -> int:
	var total := 0
	for p in parts:
		total += PartCatalog.cost_of(p["id"])
	return total


## Unabhängige Kopie (Änderungen an der Kopie lassen das Original unverändert).
func copy() -> CellBuild:
	var result := CellBuild.new()
	for p in parts:
		result.parts.append(p.duplicate())
	return result


## Startaufbau: Maul vorn, ein Auge. Fleischfresser bekommen den Kiefer, alle anderen das Filtermaul.
static func starter(diet: String) -> CellBuild:
	var build := CellBuild.new()
	build.add_part(Diet.KIEFER if diet == Diet.FLEISCHFRESSER else Diet.FILTERMAUL, Vector2(1, 0))
	build.add_part("knopfauge", Vector2(0.4, 0))
	return build
