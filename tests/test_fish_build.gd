extends "res://tests/base_test.gd"

var b := FishBuild.new()

func setup() -> void:
	b = FishBuild.new()


func test_neu() -> void:
	check_eq(b.level("schwanz"), 0, "neuer Fisch hat Schwanz-Level 0")
	check_eq(b.total_levels(), 0, "neuer Fisch hat keine Level")
	check_eq(b.level("unbekannt"), 0, "unbekanntes Bauteil hat Level 0")
	check_eq(b.diet, Diet.PFLANZENFRESSER, "neuer Fisch ist Pflanzenfresser")


func test_ausbauen() -> void:
	check(b.upgrade("flossen"), "erstes Upgrade von Flossen erfolgreich")
	check(b.upgrade("flossen"), "zweites Upgrade von Flossen erfolgreich")
	check_eq(b.level("flossen"), 2, "Flossen haben Level 2 nach zwei Upgrades")
	check_eq(b.total_levels(), 2, "Gesamt-Level ist 2")


func test_hoechste_stufe() -> void:
	b.upgrade("kiefer")
	b.upgrade("kiefer")
	b.upgrade("kiefer")
	check(not b.upgrade("kiefer"), "viertes Upgrade von Kiefer schlägt fehl")
	check_eq(b.level("kiefer"), 3, "Kiefer hat Level 3 nach drei Upgrades")


func test_unbekannt() -> void:
	check(not FishBuild.new().upgrade("fluegel"), "unbekanntes Bauteil kann nichtUpgrade werden")


func test_kopie() -> void:
	b.upgrade("augen")
	var c := b.copy()
	c.upgrade("augen")
	check_eq(b.level("augen"), 1, "Original hat Level 1 nach Kopieren und Upgrade")
	check_eq(c.level("augen"), 2, "Kopie hat Level 2 nach eigenem Upgrade")


func test_speichern() -> void:
	b.upgrade("schwanz")
	b.color = Color(1, 0, 0)
	b.diet = Diet.FLEISCHFRESSER
	var c := FishBuild.from_dict(b.to_dict())
	check_eq(c.level("schwanz"), 1, "Gespeicherte und geladene Instanz hat Schwanz-Level 1")
	check(c.color.is_equal_approx(Color(1, 0, 0)), "Farbe wurde korrekt gespeichert und geladen")
	check_eq(c.diet, Diet.FLEISCHFRESSER, "Ernährungsart wurde korrekt gespeichert und geladen")


func test_laden_begrenzt() -> void:
	check_eq(FishBuild.from_dict({"levels": {"stacheln": 9}}).level("stacheln"), 3, "Level wird auf MAX_LEVEL begrenzt")
	check_eq(FishBuild.from_dict({}).total_levels(), 0, "leeres Dictionary ergibt Gesamt-Level 0")
