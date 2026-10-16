extends "res://tests/base_test.gd"

var b: CellBuild

func setup() -> void:
	b = CellBuild.new()


func test_einbauen() -> void:
	check_eq(b.add_part("stachel", Vector2(-1, 0)), 0, "erster Stachel hat Index 0")
	check_eq(b.add_part("geissel", Vector2(0, 1), 0.5), 1, "Geißel hat Index 1")
	check_eq(b.add_part("gibtsnicht", Vector2.ZERO), -1, "unbekannte ID gibt -1 zurück")
	check_eq(b.parts.size(), 2, "es sind genau 2 Teile eingebaut")
	check_eq(b.parts[1]["angle"], 0.5, "Geißel hat Winkel 0.5")


func test_verschieben_drehen() -> void:
	b.add_part("stachel", Vector2(0, 0))
	check(b.move_part(0, Vector2(0.5, 0.5)), "move_part gibt true bei gültigem Index")
	check_eq(b.parts[0]["pos"], Vector2(0.5, 0.5), "Position wurde verschoben")
	check(b.rotate_part(0, 1.0), "rotate_part gibt true bei gültigem Index")
	check_eq(b.parts[0]["angle"], 1.0, "Winkel wurde gedreht")
	check(not b.move_part(5, Vector2.ZERO), "move_part gibt false bei ungültigem Index")
	check(not b.rotate_part(-1, 0.0), "rotate_part gibt false bei ungültigem Index")


func test_entfernen() -> void:
	b.add_part("stachel", Vector2(0, 0))
	b.add_part("geissel", Vector2(1, 0))
	check(b.remove_part(0), "remove_part gibt true bei gültigem Index")
	check_eq(b.parts.size(), 1, "nach Entfernen ist noch 1 Teil übrig")
	check_eq(b.parts[0]["id"], "geissel", "das verbleibende Teil ist die Geißel")
	check(not b.remove_part(3), "remove_part gibt false bei ungültigem Index")


func test_zaehlen_und_maeuler() -> void:
	b.add_part("kiefer", Vector2(0, 0))
	b.add_part("stachel", Vector2(0.5, 0))
	b.add_part("stachel", Vector2(-0.5, 0))
	b.add_part("filtermaul", Vector2(1, 0))
	check_eq(b.count("stachel"), 2, "es sind 2 Stacheln eingebaut")
	var erwartet: Array[String] = ["kiefer", "filtermaul"]
	check_eq(b.mouths(), erwartet, "Mundwerkzeuge in Einbaureihenfolge")


func test_startaufbau() -> void:
	var pflanz := CellBuild.starter(Diet.PFLANZENFRESSER)
	check_eq(pflanz.parts[0]["id"], "filtermaul", "Pflanzenfresser bekommt Filtermaul")
	check_eq(pflanz.parts[0]["pos"], Vector2(1, 0), "Maul ist vorn bei (1, 0)")
	check_eq(pflanz.total_cost(), 15, "Gesamtkosten sind 15")
	var fleisch := CellBuild.starter(Diet.FLEISCHFRESSER)
	check_eq(fleisch.parts[0]["id"], "kiefer", "Fleischfresser bekommt Kiefer")


func test_kopie_unabhaengig() -> void:
	var s := CellBuild.starter(Diet.PFLANZENFRESSER)
	var c := s.copy()
	c.move_part(0, Vector2(9, 9))
	c.add_part("stachel", Vector2(-1, 0))
	check_eq(s.parts[0]["pos"], Vector2(1, 0), "Original bleibt unverändert")
	check_eq(s.parts.size(), 2, "Original hat weiterhin 2 Teile")
	check_eq(c.parts.size(), 3, "Kopie hat nun 3 Teile")
