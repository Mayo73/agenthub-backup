extends "res://tests/base_test.gd"

var u: PartUnlocks

func setup() -> void:
	u = PartUnlocks.new()


func test_start() -> void:
	check_eq(u.unlocked.size(), 3, "start: 3 Teile freigeschaltet")
	check(u.is_unlocked("filtermaul"), "start: filtermaul ist frei")
	check(not u.is_unlocked("geissel"), "start: geissel noch gesperrt")
	check_eq(u.next_locked(), "geissel", "nächstes gesperrtes Teil ist geissel")


func test_freischalten() -> void:
	check(u.unlock("geissel"), "unlock geissel erfolgreich")
	check(not u.unlock("geissel"), "geissel schon frei, erneut unlock falsch")
	check(not u.unlock("gibtsnicht"), "unbekanntes Teil false")
	check_eq(u.next_locked(), "stachel", "nächstes gesperrtes Teil ist stachel")


func test_ausser_der_reihe() -> void:
	u = PartUnlocks.new()  # Frische Instanz
	check(u.unlock("wimpern"), "wimpern freischalten möglich")
	check_eq(u.next_locked(), "geissel", "trotzdem zuerst geissel als nächstes gesperrt")


func test_alle_frei() -> void:
	u = PartUnlocks.new()  # Frische Instanz
	for id in PartCatalog.UNLOCK_ORDER:
		check(u.unlock(id), id + " freischalten")
	check(u.all_unlocked(), "alle Teile nach Unlock aller gesperrten frei")
	check_eq(u.next_locked(), "", "next_locked leer wenn alle frei")
	check_eq(u.unlocked.size(), 11, "insgesamt 11 Teile (3 starter + 8 unlocked)")
