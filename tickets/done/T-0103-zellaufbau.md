---
id: T-0103
title: Zellaufbau mit eingebauten Teilen (CellBuild)
project: zellenphase
priority: 3
after: T-0102
---
## Ziel
Der Aufbau einer Zelle: welche Teile wo eingebaut sind. Der Zelleditor und die Spielwerte bauen darauf auf. Lagen sind in Zellradien angegeben, damit sie beim Wachsen mitwachsen.

## Dateien
- `scripts/cell_build.gd`: neu
- `tests/test_cell_build.gd`: neu

## Akzeptanzkriterien
`scripts/cell_build.gd` genau so:
```gdscript
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
```

## Tests
`tests/test_cell_build.gd` mit `extends "res://tests/base_test.gd"`, `var b: CellBuild`, `setup()`: `b = CellBuild.new()`.
- `test_einbauen`: `b.add_part("stachel", Vector2(-1, 0))` ist 0; `b.add_part("geissel", Vector2(0, 1), 0.5)` ist 1; `b.add_part("gibtsnicht", Vector2.ZERO)` ist -1; `b.parts.size()` ist 2; `b.parts[1]["angle"]` ist 0.5
- `test_verschieben_drehen`: ein Stachel eingebaut; `b.move_part(0, Vector2(0.5, 0.5))` wahr und `b.parts[0]["pos"]` ist (0.5, 0.5); `b.rotate_part(0, 1.0)` wahr und `b.parts[0]["angle"]` ist 1.0; `b.move_part(5, Vector2.ZERO)` falsch; `b.rotate_part(-1, 0.0)` falsch
- `test_entfernen`: Stachel und Geißel eingebaut; `b.remove_part(0)` wahr, `b.parts.size()` 1, `b.parts[0]["id"]` ist `"geissel"`; `b.remove_part(3)` falsch
- `test_zaehlen_und_maeuler`: einbauen `"kiefer"`, `"stachel"`, `"stachel"`, `"filtermaul"` (Lage beliebig) → `b.count("stachel")` ist 2; mit `var erwartet: Array[String] = ["kiefer", "filtermaul"]` ist `b.mouths()` gleich `erwartet`
- `test_startaufbau`: `CellBuild.starter(Diet.PFLANZENFRESSER)` → `parts[0]["id"]` ist `"filtermaul"`, `parts[0]["pos"]` ist (1, 0), `total_cost()` ist 15; `CellBuild.starter(Diet.FLEISCHFRESSER).parts[0]["id"]` ist `"kiefer"`
- `test_kopie_unabhaengig`: `var s := CellBuild.starter(Diet.PFLANZENFRESSER)`, `var c := s.copy()`, `c.move_part(0, Vector2(9, 9))`, `c.add_part("stachel", Vector2(-1, 0))` → `s.parts[0]["pos"]` ist weiterhin (1, 0), `s.parts.size()` ist 2, `c.parts.size()` ist 3

Review (16.10.2026): gemergt.
