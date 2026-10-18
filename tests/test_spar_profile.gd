extends "res://tests/base_test.gd"

func test_initialen() -> void:
	var p1: SparProfile = SparProfile.new()
	p1.name = "Alex Berger"
	check_eq(p1.initials(), "AB", "Alex Berger → AB")

	var p2: SparProfile = SparProfile.new()
	p2.name = "Mo"
	check_eq(p2.initials(), "M", "Mo → M")

	var p3: SparProfile = SparProfile.new()
	p3.name = ""
	check_eq(p3.initials(), "?", "leerer Name → ?")

	var p4: SparProfile = SparProfile.new()
	p4.name = "anna maria lang"
	check_eq(p4.initials(), "AM", "anna maria lang → AM")


func test_stufe() -> void:
	var p1: SparProfile = SparProfile.new()
	p1.level = 2
	check_eq(p1.level_name(), "Erfahren", "level 2 → Erfahren")

	var p2: SparProfile = SparProfile.new()
	p2.level = 7
	check_eq(p2.level_name(), "Erfahren", "level 7 → Erfahren (geclamped)")


func test_hin_und_zurueck() -> void:
	var original: SparProfile = SparProfile.new()
	original.id = "x1"
	original.name = "Test"
	original.art = "MMA"
	original.level = 1
	original.years = 3
	original.age = 40
	original.bio = "Hallo"
	original.color = Color(1, 0, 0)

	var dict: Dictionary = original.to_dict()
	var restored: SparProfile = SparProfile.from_dict(dict)

	check_eq(restored.id, original.id, "id übereinstimmend")
	check_eq(restored.name, original.name, "name übereinstimmend")
	check_eq(restored.art, original.art, "art übereinstimmend")
	check_eq(restored.level, original.level, "level übereinstimmend")
	check_eq(restored.years, original.years, "years übereinstimmend")
	check_eq(restored.age, original.age, "age übereinstimmend")
	check_eq(restored.bio, original.bio, "bio übereinstimmend")
	check(original.color.is_equal_approx(restored.color), "color annähernd gleich")


func test_fehlende_schluessel() -> void:
	var d: Dictionary = {"id": "x"}
	var p: SparProfile = SparProfile.from_dict(d)

	check_eq(p.age, 18, "age Standardwert 18")
	check_eq(p.name, "", "name Standardwert leer")
	check_eq(p.level, 0, "level Standardwert 0")


func test_merkmale_standard() -> void:
	var p: SparProfile = SparProfile.new()
	check_eq(p.weight_class, -1, "weight_class initial -1")
	check_eq(p.weight_name(), "keine Angabe", "weight_name bei -1 → 'keine Angabe'")
	check(p.days.is_empty(), "days initial leer")
	check(p.equipment.is_empty(), "equipment initial leer")


func test_merkmale_speichern_laden() -> void:
	var p: SparProfile = SparProfile.new()
	p.weight_class = 2
	p.days = ["Sa", "Mo"]
	p.equipment = ["Matte"]

	var saved_dict := p.to_dict()
	var restored: SparProfile = SparProfile.from_dict(saved_dict)

	check_eq(restored.weight_class, 2, "weight_class 2")
	check(typeof(restored.weight_class) == TYPE_INT, "weight_class ist INT")
	# Sortierte Reihenfolge aus DAYS
	check_eq(restored.days, ["Mo", "Sa"], "days sortiert und ohne Doppelte")
	check_eq(restored.equipment, ["Matte"], "equipment korrekt übernommen")
	check_eq(restored.weight_name(), "Schwer (über 84 kg)", "weight_name → 'Schwer (über 84 kg)'")


func test_alte_daten() -> void:
	var d: Dictionary = {
		"id": "p09",
		"name": "Test",
		"art": "Boxen",
		"level": 0,
		"years": 1,
		"age": 20,
		"bio": ""
	}
	var p: SparProfile = SparProfile.from_dict(d)

	check_eq(p.weight_class, -1, "alte Daten: weight_class -1")
	check(p.days.is_empty(), "alte Daten: days leer")
	check(p.equipment.is_empty(), "alte Daten: equipment leer")


func test_unbekannte_werte() -> void:
	var d: Dictionary = {
		"id": "p10",
		"name": "Test",
		"art": "Boxen",
		"level": 0,
		"years": 1,
		"age": 20,
		"bio": "",
		"weight_class": 7,
		"days": ["Mo", "Montag", "Mo"],
		"equipment": ["Helm", "Pratzen"]
	}
	var p: SparProfile = SparProfile.from_dict(d)

	check_eq(p.weight_class, -1, "ungültiger weight_class 7 → -1")
	check_eq(p.days, ["Mo"], "days nur bekannte Werte ohne Doppelte")
	check_eq(p.equipment, ["Pratzen"], "equipment nur bekannte Werte")


func test_kopie_unabhaengig() -> void:
	var p: SparProfile = SparProfile.new()
	p.days = ["Mo"]

	var q: SparProfile = p.duplicate_profile()
	q.days.append("Di")

	check_eq(p.days.size(), 1, "p.days bleibt unverändert (Größe 1)")
