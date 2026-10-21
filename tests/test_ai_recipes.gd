extends "res://tests/base_test.gd"


func test_namen() -> void:
	var n := AiRecipes.names()
	for name in ["spielfigur", "kamera", "hindernisse", "ausloeser", "testlauf"]:
		check(n.has(name), "Rezept %s vorhanden" % name)
	var sorted := n.duplicate()
	sorted.sort()
	check_eq(n, sorted, "Namen sortiert")


func test_platzhalter() -> void:
	check_eq(AiRecipes.placeholders("spielfigur"), ["name", "sprung", "tempo"], "Platzhalter der Spielfigur")
	check(AiRecipes.placeholders("zaubern").is_empty(), "unbekanntes Rezept hat keine Platzhalter")


func test_ausfuellen() -> void:
	var r := AiRecipes.fill("spielfigur", {"name": "Held"})
	check(r.is_ok(), "ausgefüllt")
	var prompt: String = r.data.get("prompt", "")
	check(prompt.contains("Held"), "Name eingesetzt")
	check(prompt.contains("5 Einheiten/s"), "Standardtempo eingesetzt")


func test_fehlt() -> void:
	var r := AiRecipes.fill("ausloeser", {"name": "Tor"})
	check_eq(r.code, "invalid_argument", "fehlender Platzhalter")
	check(r.message.contains("aktion"), "Meldung nennt aktion")


func test_unbekannt() -> void:
	var r := AiRecipes.fill("zaubern", {})
	check_eq(r.code, "not_found", "unbekanntes Rezept")
