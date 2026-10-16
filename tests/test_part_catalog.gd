extends "res://tests/base_test.gd"


func test_elf_teile() -> void:
	check_eq(PartCatalog.ids().size(), 11, "es gibt 11 Teile")


func test_freischaltung_vollstaendig() -> void:
	var starter_count: int = PartCatalog.STARTER.size()
	var unlock_count: int = PartCatalog.UNLOCK_ORDER.size()
	check_eq(starter_count + unlock_count, 11, "STARTER + UNLOCK_ORDER ergeben 11")

	var all_ids: Array[String] = PartCatalog.ids()
	for id: String in all_ids:
		var in_starter: bool = PartCatalog.STARTER.has(id)
		var in_unlock: bool = PartCatalog.UNLOCK_ORDER.has(id)
		check(in_starter != in_unlock, "jede ID kommt genau einmal vor: " + id)


func test_kategorien() -> void:
	var mauler: Array[String] = ["filtermaul", "kiefer", "ruessel"]
	check_eq(PartCatalog.ids_in_category("maul"), mauler, "Kategorie maul")

	check_eq(PartCatalog.ids_in_category("waffe").size(), 3, "Kategorie waffe hat 3 Einträge")

	check_eq(PartCatalog.category_of("wimpern"), "antrieb", "wimpern ist Antrieb")
	check_eq(PartCatalog.category_of("gibtsnicht"), "", "unbekannte ID ergibt leeren String")


func test_maeuler_passen_zu_diet() -> void:
	check_eq(PartCatalog.category_of(Diet.FILTERMAUL), "maul", "FILTERMAUL ist Maul")
	check_eq(PartCatalog.category_of(Diet.KIEFER), "maul", "KIEFER ist Maul")
	check_eq(PartCatalog.category_of(Diet.RUESSEL), "maul", "RUESSEL ist Maul")


func test_kosten_und_namen() -> void:
	check_eq(PartCatalog.cost_of("elektro"), 25, "elektro kostet 25")
	check_eq(PartCatalog.cost_of("gibtsnicht"), 0, "unbekannte ID kostet 0")

	check_eq(PartCatalog.name_of("ruessel"), "Rüssel", "Name von ruessel ist Rüssel")
	check_eq(PartCatalog.name_of("gibtsnicht"), "", "Name von unbekannter ID ist leer")

	check(PartCatalog.exists("geissel"), "geissel existiert")
