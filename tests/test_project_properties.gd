extends "res://tests/base_test.gd"
## Tests für ProjectProperties.

var project: ProjectProperties


func setup() -> void:
	project = ProjectProperties.new()


func test_standard() -> void:
	check_eq(project.get_value("physics_hz"), 120, "Standard physics_hz")
	check_eq(project.get_value("dimension"), "2d", "Standard dimension")


func test_setzen() -> void:
	var result := project.set_value("gravity", 20)
	check(result.code == "ok", "set_value gravity erfolgreich")
	check_eq(project.get_value("gravity"), 20.0, "gravity wurde gesetzt")


func test_fehler() -> void:
	# Unbekannte Eigenschaft
	var r1 := project.set_value("farbe", 1)
	check(r1.code == "not_found", "unbekannte Eigenschaft gibt not_found")

	# Falscher Typ für int (String statt Zahl)
	var r2 := project.set_value("physics_hz", "schnell")
	check(r2.code == "invalid_argument", "falscher Typ für physics_hz")

	# Außerhalb des Bereichs
	var r3 := project.set_value("physics_hz", 500)
	check(r3.code == "invalid_argument", "physics_hz außerhalb Bereich")

	# Falsche choice
	var r4 := project.set_value("dimension", "4d")
	check(r4.code == "invalid_argument", "dimension nicht in choices")


func test_beschreibung() -> void:
	var lines := project.describe()
	check(lines.size() == 5, "describe liefert 5 Einträge")
	check(lines[0].begins_with("dimension: "), "erster Eintrag beginnt mit dimension:")


func test_speichern() -> void:
	project.set_value("name", "Kistenspiel")
	var dict := project.to_dict()
	var serialized := JSON.stringify(dict)
	var temp: Dictionary = JSON.parse_string(serialized)
	var parsed: Dictionary = temp
	var project2 := ProjectProperties.from_dict(parsed)

	check_eq(project2.get_value("name"), "Kistenspiel", "Name wurde geladen")
	var phz: Variant = project2.get_value("physics_hz")
	check_eq(phz, 120, "physics_hz Standard erhalten")
	check(typeof(phz) == TYPE_INT, "physics_hz ist int")
