extends "res://tests/base_test.gd"

var idx: ReferenceIndex


func setup() -> void:
	idx = ReferenceIndex.new()
	idx.link("kamera", "ziel", "spieler")
	idx.link("tuer", "schalter", "hebel")
	idx.link("hud", "ziel", "spieler")




func test_ersetzen() -> void:
	idx.link("kamera", "ziel", "gegner")
	var targets := idx.targets_of("kamera")
	check_eq(targets.size(), 1, "targets hat Größe 1")
	if targets.size() > 0:
		var t: String = targets[0]
		check_eq(t, "gegner", "targets ist [\"gegner\"]")
	check(idx.refs.size() == 3, "refs.size() bleibt 3")


func test_rueckwaerts() -> void:
	var result: Array[String] = idx.referrers_of("spieler")
	check_eq(result.size(), 2, "referrers_of hat Größe 2")
	if result.size() >= 2:
		var r0: String = result[0]
		var r1: String = result[1]
		check(r0 == "hud" or r0 == "kamera", "erster Eintrag ist hud oder kamera")
		check(r1 == "hud" or r1 == "kamera", "zweiter Eintrag ist hud oder kamera")
		check(r0 != r1, "Einträge sind verschieden")


func test_loeschen() -> void:
	var removed := idx.remove_object("spieler")
	check_eq(removed, 2, "remove_object gibt 2 zurück")
	check(idx.refs.size() == 1, "refs.size() ist 1 nach Löschen")


func test_umbenennen() -> void:
	idx.rename("spieler", "held")
	var referrers_held := idx.referrers_of("held")
	check(referrers_held.size() == 2, "referrers_of(\"held\") hat 2 Einträge")
	var referrers_spieler := idx.referrers_of("spieler")
	check_eq(referrers_spieler.size(), 0, "referrers_of(\"spieler\") ist leer")


func test_verwaist() -> void:
	var result := idx.dangling(["kamera", "tuer", "hud", "spieler"])
	check(result.size() == 1, "dangling hat genau einen Eintrag")
	if result.size() >= 1:
		var r: Dictionary = result[0]
		var to_value: String = str(r.get("to", ""))
		check_eq(to_value, "hebel", "verwaistes to ist \"hebel\"")


func test_speichern() -> void:
	var json_str := JSON.stringify(idx.to_dict())
	var parsed: Dictionary = JSON.parse_string(json_str)
	var restored := ReferenceIndex.from_dict(parsed)
	check_eq(restored.refs.size(), 3, "Wiederherstellung hat 3 Einträge")
