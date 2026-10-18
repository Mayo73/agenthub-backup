extends "res://tests/base_test.gd"

var p: SparProfile
var ok: Dictionary


static func repeat_char(count: int, c: String) -> String:
	var s := ""
	for i in range(count):
		s += c
	return s


func setup() -> void:
	p = DemoData.profiles()[0]  # Alex
	ok = ProfileForm.values_of(p)


func test_gueltig() -> void:
	var errs: Array[String] = ProfileForm.errors(ok)
	check_eq(errs, [], "keine Fehler bei gültigen Daten")


func test_name_fehlt() -> void:
	ok["name"] = "   "
	var errs: Array[String] = ProfileForm.errors(ok)
	check_eq(errs, ["Name fehlt"], "leerer Name führt zu Fehler")


func test_name_zu_lang() -> void:
	ok["name"] = repeat_char(31, "a")
	var errs: Array[String] = ProfileForm.errors(ok)
	check("Name ist zu lang (höchstens 30 Zeichen)" in errs, "zu langer Name wird gemeldet")


func test_minderjaehrig() -> void:
	ok["age"] = 17
	var errs: Array[String] = ProfileForm.errors(ok)
	check_eq(errs, ["Nur Erwachsene: Alter mindestens 18"], "Minderjähriger wird gemeldet")


func test_unbekannte_sportart() -> void:
	ok["art"] = "Schach"
	var errs: Array[String] = ProfileForm.errors(ok)
	check_eq(errs, ["Kampfsportart fehlt"], "unbekannte Sportart wird gemeldet")


func test_leer() -> void:
	var errs: Array[String] = ProfileForm.errors({})
	check_errs_5_fehler(errs, "alle Pflichtfelder leer/mangelnd")


func test_bio_zu_lang() -> void:
	ok["bio"] = repeat_char(121, "x")
	var errs: Array[String] = ProfileForm.errors(ok)
	check_eq(errs, ["Text ist zu lang (höchstens 120 Zeichen)"], "Bio zu lang wird gemeldet")


func test_uebernehmen() -> void:
	ok["name"] = " Alexa "
	ok["level"] = 2
	var result := ProfileForm.applied(p, ok)
	check(result != null, "applied gibt Profil zurück bei gültigen Daten")
	check_eq(result.name, "Alexa", "Name strip_edges übernommen")
	check_eq(result.level, 2, "level 2 übernommen")
	check_eq(result.id, "p01", "id bleibt p01")
	check_eq(p.name, "Alex", "Originalprofil unverändert")


func test_fehler_ohne_aenderung() -> void:
	var result := ProfileForm.applied(p, {"name": ""})
	check(result == null, "applied gibt null bei Fehlern")
	check_eq(p.name, "Alex", "Originalprofil trotz Fehler unverändert")


# Hilfsfunktion für test_leer – prüft die 5 fehlenden Pflichtfelder-Fehler
func check_errs_5_fehler(errs: Array[String], msg: String) -> void:
	# Die Reihenfolge der Felder im Check: name, art, level, age, years
	# bio ist optional, also nicht bei leerem Dict geprüft (keine Länge > BIO_MAX)
	var expected: Array[String] = ["Name fehlt", "Kampfsportart fehlt", "Erfahrung fehlt",
					"Nur Erwachsene: Alter mindestens 18", "Trainingsjahre sind ungültig"]
	check_eq(errs.size(), 5, msg + ": 5 Fehler erwartet")
	for i in range(5):
		check_eq(errs[i], expected[i], "Fehler %d ist %s" % [i, errs[i]])
