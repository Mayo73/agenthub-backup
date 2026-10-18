extends "res://tests/base_test.gd"

var book: MeetingBook = null
var ok: Dictionary = {}


func setup() -> void:
	book = MeetingBook.new()
	ok = {
		"place": "Stadtpark, Wiese am Teich",
		"date": "24.10.2026",
		"time": "10:30",
		"form": "Drills"
	}


func teardown() -> void:
	pass


func test_vorschlag_gueltig() -> void:
	# gültiger Vorschlag gibt [], get_meeting["place"] stimmt, has_approved(p01) wahr, is_confirmed(p01,p02) falsch
	var result := book.propose("m1", "p01", ok) as Array[String]
	check_eq(result, [], "propose soll [] bei gültigem Vorschlag")

	var meeting: Dictionary = book.get_meeting("m1")
	check_eq(meeting.get("place"), "Stadtpark, Wiese am Teich", "Ort gespeichert")

	check(book.has_approved("m1", "p01"), "p01 soll zugestimmt haben nach propose")
	check(not book.is_confirmed("m1", "p01", "p02"), "is_confirmed falsch wenn nur p01 zugestimmt")


func test_beide_stimmen_zu() -> void:
	# nach propose durch p01: approve(p02) → is_confirmed(p01,p02) wahr
	book.propose("m1", "p01", ok)
	book.approve("m1", "p02")

	check(book.is_confirmed("m1", "p01", "p02"), "is_confirmed wahr wenn beide zugestimmt")


func test_aenderung_setzt_zurueck() -> void:
	# bestätigen, dann propose durch p02 mit neuer time → is_confirmed falsch, hat_approved(p01) falsch, hat_approved(p02) wahr
	var ok2: Dictionary = dict_merge(ok, {"time": "11:00"})

	book.propose("m1", "p01", ok)
	book.approve("m1", "p02")
	check(book.is_confirmed("m1", "p01", "p02"), "erst is_confirmed wahr")

	book.propose("m1", "p02", ok2)
	check(not book.is_confirmed("m1", "p01", "p02"), "is_confirmed falsch nach Änderung")
	check(not book.has_approved("m1", "p01"), "hat_approved(p01) falsch nach Änderung")
	check(book.has_approved("m1", "p02"), "hat_approved(p02) wahr nach neuer propose durch p02")


func test_fehlende_angaben() -> void:
	# propose mit {} → 4 Einträge, erster "Ort fehlt"; kein Vorschlag gespeichert
	var result := book.propose("m1", "p01", {}) as Array[String]
	check_eq(result.size(), 4, "missing_fields soll 4 Einträge haben")
	check(result[0] == "Ort fehlt", "erster Fehler muss 'Ort fehlt' sein")
	check(book.get_meeting("m1").is_empty(), "kein Vorschlag gespeichert bei Fehlern")


func test_ungueltige_zeit_und_datum() -> void:
	# date "24.10.26" und time "25:00" → genau die zwei passenden Meldungen
	var bad: Dictionary = {
		"place": "Stadtpark",
		"date": "24.10.26",
		"time": "25:00",
		"form": "Drills"
	}

	var result := book.propose("m1", "p01", bad) as Array[String]
	check_eq(result.size(), 2, "zwei Fehler erwartet")
	check("Datum fehlt oder ist ungültig (TT.MM.JJJJ)" in result, "Fehler für Datum enthalten")
	check("Uhrzeit fehlt oder ist ungültig (HH:MM)" in result, "Fehler für Uhrzeit enthalten")


func test_intensitaet_und_regeln() -> void:
	# mit intensiv und rules → gespeichert; mit invalid intensity → mittel
	var good: Dictionary = dict_merge(ok, {"intensity": "intensiv", "rules": "Kein Kopfkontakt"})
	book.propose("m1", "p01", good)

	var m: Dictionary = book.get_meeting("m1")
	check(m.get("intensity") == "intensiv", "intensity intensiv gespeichert")
	check(m.get("rules") == "Kein Kopfkontakt", "rules gespeichert")

	# neuer Vorschlag mit invalid intensity
	var bad_int: Dictionary = dict_merge(ok, {"intensity": "brutal"})
	book.propose("m2", "p01", bad_int)
	m = book.get_meeting("m2") as Dictionary
	check(m.get("intensity") == "mittel", "ungültige intensity wird zu mittel")


func test_absagen() -> void:
	# bestätigen, dann cancel(p02) → is_cancelled wahr, is_confirmed falsch; approve(p01) ändert nichts; neuer propose hebt Absage auf
	book.propose("m1", "p01", ok)
	book.approve("m1", "p02")

	book.cancel("m1", "p02")
	check(book.is_cancelled("m1"), "is_cancelled wahr nach cancel")
	check(not book.is_confirmed("m1", "p01", "p02"), "is_confirmed falsch nach cancel")

	# approve(p01) danach ändert nichts (weil abgesagt)
	book.approve("m1", "p01")
	check(book.is_cancelled("m1"), "immer noch abgesagt")

	# neuer propose hebt Absage auf
	book.propose("m1", "p01", ok)
	check(not book.is_cancelled("m1"), "is_cancelled falsch nach neuer propose")


func test_speichern_laden() -> void:
	# Vorschlag + Zustimmung, from_dict(to_dict()) → is_confirmed gleich
	book.propose("m1", "p01", ok)
	book.approve("m1", "p02")

	var before := book.is_confirmed("m1", "p01", "p02")

	var serialized := book.to_dict() as Dictionary
	var loaded := MeetingBook.from_dict(serialized)

	var after := loaded.is_confirmed("m1", "p01", "p02")
	check_eq(before, after, "is_confirmed nach speichern/laden gleich")


## Hilfsfunktion: merge two dictionaries (simple version for test setup)
func dict_merge(base: Dictionary, overrides: Dictionary) -> Dictionary:
	var result := base.duplicate()
	for k in overrides:
		result[k] = overrides[k]
	return result
