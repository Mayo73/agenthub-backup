extends "res://tests/base_test.gd"

var s: EditorSession

func setup() -> void:
	var u := PartUnlocks.new()
	u.unlock("geissel")
	s = EditorSession.new(CellBuild.starter(Diet.PFLANZENFRESSER), u)


func test_achse() -> void:
	check(EditorSymmetry.is_on_axis(Vector2(1, 0.02)), "pos.y=0.02 <= 0.05: auf Achse")
	check(not EditorSymmetry.is_on_axis(Vector2(0, 0.5)), "pos.y=0.5 > 0.05: nicht auf Achse")
	check_eq(EditorSymmetry.mirror_pos(Vector2(-0.8, 0.6)), Vector2(-0.8, -0.6), "Pos spiegeln")
	check_eq(EditorSymmetry.mirror_angle(0.3), -0.3, "Winkel spiegeln")


func test_gespiegelt_einbauen() -> void:
	var idx := EditorSymmetry.place_mirrored(s, "geissel", Vector2(-0.8, 0.6), 0.3)
	check_eq(idx.size(), 2, "Es werden zwei Teile eingebaut")
	check_eq(idx[0], 2, "Erstes Teil an Index 2")
	check_eq(idx[1], 3, "Gespiegeltes Teil an Index 3")
	check_eq(s.working.parts[3]["pos"], Vector2(-0.8, -0.6), "Spiegelbild hat richtige Position")
	check_eq(s.working.parts[3]["angle"], -0.3, "Spiegelbild hat gespiegelten Winkel")
	check_eq(s.cost(), 30, "Kosten: Kiefer(10) + Geißel(15) + Spiegel-Geißel(15) = 40, Original-Maul(10) = netto 30 DNA")


func test_auf_der_achse_einmal() -> void:
	check_eq(EditorSymmetry.place_mirrored(s, "kiefer", Vector2(1, 0.02)).size(), 1, "Teil auf Achse wird nur einmal eingebaut")
	check_eq(s.cost(), 10, "Nur ein Kiefer kostet 10 DNA")


func test_gesperrt() -> void:
	var idx := EditorSymmetry.place_mirrored(s, "stachel", Vector2(0, 1))
	check_eq(idx.size(), 0, "Gesperrter Stachel wird nicht eingebaut")
	check_eq(s.working.parts.size(), 2, "Parts-Größe bleibt unverändert")
