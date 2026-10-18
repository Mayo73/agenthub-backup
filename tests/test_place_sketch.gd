extends "res://tests/base_test.gd"

var place_sketch: PlaceSketch


func setup() -> void:
	place_sketch = PlaceSketch.new()


## Test 1: Erkennung von Ortsarten aus Text
func test_erkennung() -> void:
	check_eq("Park", place_sketch.kind_for("Stadtpark"), "Stadtpark → Park")
	check_eq("Wiese", place_sketch.kind_for("Wiese am Teich"), "Wiese am Teich → Wiese")
	check_eq("Sportplatz", place_sketch.kind_for("Sportplatz an der Schule"), "Sportplatz an der Schule → Sportplatz")
	check_eq("Sportplatz", place_sketch.kind_for("Bolzplatz"), "Bolzplatz → Sportplatz")
	check_eq("Wald", place_sketch.kind_for("Waldweg"), "Waldweg → Wald")
	check_eq("Strand", place_sketch.kind_for("Rheinufer"), "Rheinufer → Strand")


## Test 2: Groß-/Kleinschreibung wird ignoriert
func test_gross_klein() -> void:
	check_eq("Strand", place_sketch.kind_for("STRAND"), "STRAND → Strand")


## Test 3: Unbekannte Texten → "Draußen"
func test_unbekannt() -> void:
	check_eq("Draußen", place_sketch.kind_for(""), "leerer String → Draußen")
	check_eq("Draußen", place_sketch.kind_for("Hinterhof"), "Hinterhof → Draußen")


## Test 4: Anzahl der Formen pro Art
func test_anzahl() -> void:
	check_eq(5, place_sketch.shapes("Park").size(), "Park hat 5 Formen")
	check_eq(3, place_sketch.shapes("Wiese").size(), "Wiese hat 3 Formen")
	check_eq(2, place_sketch.shapes("Strand").size(), "Strand hat 2 Formen")
	check_eq(3, place_sketch.shapes("Sportplatz").size(), "Sportplatz hat 3 Formen")
	check_eq(6, place_sketch.shapes("Wald").size(), "Wald hat 6 Formen")
	check_eq(2, place_sketch.shapes("Draußen").size(), "Draußen hat 2 Formen")
	check_eq(2, place_sketch.shapes("Mond").size(), "unbekannte Art (Mond) → 2 Formen")


## Test 5: Erste Form ist immer Hintergrund-rect mit pos ZERO und size ONE
func test_hintergrund_zuerst() -> void:
	for kind in PlaceSketch.KINDS:
		var shapes: Array[Dictionary] = place_sketch.shapes(kind)
		check(shapes.size() > 0, "Kinds '%s' hat mindestens eine Form" % kind)
		var first: Dictionary = shapes[0]
		check(first.get("type", "") == "rect", "%s: erste Form ist rect" % kind)
		check_eq(Vector2(0.0, 0.0), first["pos"], "%s: erste Form hat pos (0,0)" % kind)
		check_eq(Vector2(1.0, 1.0), first["size"], "%s: erste Form hat size (1,1)" % kind)


## Test 6: Alle Positionen im Rahmen 0–1
func test_im_rahmen() -> void:
	for kind in PlaceSketch.KINDS:
		var shapes: Array[Dictionary] = place_sketch.shapes(kind)
		for form: Dictionary in shapes:
			var pos: Vector2 = form["pos"] as Vector2
			check(pos.x >= 0.0 and pos.x <= 1.0, "%s: alle x-Werte im Bereich 0–1" % kind)
			check(pos.y >= 0.0 and pos.y <= 1.0, "%s: alle y-Werte im Bereich 0–1" % kind)


## Test 7: Beschriftungen korrekt
func test_beschriftung() -> void:
	check_eq(
		"Skizze: Park (schematisch, keine Karte)",
		place_sketch.caption("Park"),
		"caption für Park"
	)
	check_eq(
		"Skizze: draußen (schematisch, keine Karte)",
		place_sketch.caption("Draußen"),
		"caption für Draußen"
	)
