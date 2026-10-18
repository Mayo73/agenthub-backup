extends "res://tests/base_test.gd"

var facts: ProfileFacts


func setup() -> void:
	facts = ProfileFacts.new()


func test_gewicht() -> void:
	# weight_class = 0 → „Gewicht: Leicht (bis 66 kg)“
	var p1: SparProfile = SparProfile.new()
	p1.weight_class = 0
	check_eq(facts.weight_text(p1), "Gewicht: Leicht (bis 66 kg)", "weight_class 0 → Gewicht: Leicht (bis 66 kg)")

	# weight_class = -1 → „Gewicht: keine Angabe“
	var p2: SparProfile = SparProfile.new()
	p2.weight_class = -1
	check_eq(facts.weight_text(p2), "Gewicht: keine Angabe", "weight_class -1 → Gewicht: keine Angabe")


func test_tage() -> void:
	# Tage ["Di", "Do", "Sa"] → „Verfügbar: Di, Do, Sa“
	var p1: SparProfile = SparProfile.new()
	p1.days = ["Di", "Do", "Sa"]
	check_eq(facts.days_text(p1), "Verfügbar: Di, Do, Sa", "Tage [Di, Do, Sa] → Verfügbar: Di, Do, Sa")

	# leer → „Verfügbar: nach Absprache“
	var p2: SparProfile = SparProfile.new()
	check_eq(facts.days_text(p2), "Verfügbar: nach Absprache", "leere Tage → Verfügbar: nach Absprache")

	# alle sieben → „Verfügbar: täglich“
	var p3: SparProfile = SparProfile.new()
	p3.days = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
	check_eq(facts.days_text(p3), "Verfügbar: täglich", "alle Tage → Verfügbar: täglich")


func test_ausruestung() -> void:
	# ["Mundschutz", "Matte"] → „Ausrüstung: Mundschutz, Matte“
	var p1: SparProfile = SparProfile.new()
	p1.equipment = ["Mundschutz", "Matte"]
	check_eq(facts.equipment_text(p1), "Ausrüstung: Mundschutz, Matte", "Ausrüstung [Mundschutz, Matte] → Ausrüstung: Mundschutz, Matte")

	# leer → „Ausrüstung: keine eigene“
	var p2: SparProfile = SparProfile.new()
	check_eq(facts.equipment_text(p2), "Ausrüstung: keine eigene", "leere Ausrüstung → Ausrüstung: keine eigene")


func test_alles() -> void:
	# weight_class = 1, days = ["Mo"], equipment = []
	var p: SparProfile = SparProfile.new()
	p.weight_class = 1
	p.days = ["Mo"]
	p.equipment = []

	var expected: String = "Gewicht: Mittel (66–84 kg)\nVerfügbar: Mo\nAusrüstung: keine eigene"
	check_eq(facts.all_text(p), expected, "all_text mit weight 1, days [Mo], equipment leer")


func test_gemeinsame_tage() -> void:
	# a = ["Mo", "Mi", "Sa"], b = ["Mi", "Sa", "So"] → ["Mi", "Sa"]
	var a: SparProfile = SparProfile.new()
	a.days = ["Mo", "Mi", "Sa"]

	var b: SparProfile = SparProfile.new()
	b.days = ["Mi", "Sa", "So"]

	var common := facts.common_days(a, b)
	check_eq(common, ["Mi", "Sa"], "common_days a=[Mo,Mi,Sa], b=[Mi,Sa,So] → [Mi,Sa]")

	# Text: „Gemeinsame Tage: Mi, Sa“
	check_eq(facts.common_days_text(a, b), "Gemeinsame Tage: Mi, Sa", "common_days_text zu a=[Mo,Mi,Sa], b=[Mi,Sa,So] → Gemeinsame Tage: Mi, Sa")


func test_keine_gemeinsamen_tage() -> void:
	# a = ["Mo"], b = ["Di"] → leerer Array
	var a: SparProfile = SparProfile.new()
	a.days = ["Mo"]

	var b: SparProfile = SparProfile.new()
	b.days = ["Di"]

	var common := facts.common_days(a, b)
	check_eq(common, [], "common_days a=[Mo], b=[Di] → []")

	# Text: „Keine gemeinsamen Tage – sprecht euch ab.“
	check_eq(facts.common_days_text(a, b), "Keine gemeinsamen Tage – sprecht euch ab.", "common_days_text zu a=[Mo], b=[Di] → Keine gemeinsamen Tage – sprecht euch ab.")
