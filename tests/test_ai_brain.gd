extends "res://tests/base_test.gd"

var brain: AiBrain


func setup() -> void:
	brain = AiBrain.new()


func test_fliehen() -> void:
	var result := brain.decide(Vector2.ZERO, 12.0, Diet.PFLANZENFRESSER, [{"position": Vector2(100, 0), "radius": 27.0, "diet": Diet.FLEISCHFRESSER}], null)
	check_eq(result, Vector2(-1, 0), "Schwimmrichtung nach links")
	check_eq(brain.state, AiBrain.FLIEHEN, "state ist FLIEHEN")


func test_grosser_pflanzenfresser_harmlos() -> void:
	var result := brain.decide(Vector2.ZERO, 12.0, Diet.PFLANZENFRESSER, [{"position": Vector2(100, 0), "radius": 27.0, "diet": Diet.PFLANZENFRESSER}], Vector2(0, 50))
	check_eq(result, Vector2(0, 1), "Schwimmrichtung nach unten")
	check_eq(brain.state, AiBrain.SUCHEN, "state ist SUCHEN")


func test_jagen() -> void:
	var result := brain.decide(Vector2.ZERO, 27.0, Diet.FLEISCHFRESSER, [{"position": Vector2(0, -100), "radius": 12.0, "diet": Diet.FLEISCHFRESSER}], null)
	check_eq(result, Vector2(0, -1), "Schwimmrichtung nach oben")
	check_eq(brain.state, AiBrain.JAGEN, "state ist JAGEN")


func test_ausser_sicht() -> void:
	var result := brain.decide(Vector2.ZERO, 27.0, Diet.FLEISCHFRESSER, [{"position": Vector2(500, 0), "radius": 60.0, "diet": Diet.FLEISCHFRESSER}], null)
	check_eq(result, Vector2.ZERO, "keine Richtung außerhalb der Sicht")
	check_eq(brain.state, AiBrain.TREIBEN, "state ist TREIBEN")


func test_flucht_vor_jagd() -> void:
	var result := brain.decide(Vector2.ZERO, 18.0, Diet.FLEISCHFRESSER, [
		{"position": Vector2(100, 0), "radius": 40.0, "diet": Diet.FLEISCHFRESSER},
		{"position": Vector2(-50, 0), "radius": 10.0, "diet": Diet.FLEISCHFRESSER}
	], null)
	check_eq(result, Vector2(-1, 0), "Schwimmrichtung nach links zur Gefahr")
	check_eq(brain.state, AiBrain.FLIEHEN, "state ist FLIEHEN")


func test_sich_selbst_ignorieren() -> void:
	var result := brain.decide(Vector2.ZERO, 18.0, Diet.FLEISCHFRESSER, [
		{"position": Vector2(0, 0), "radius": 60.0, "diet": Diet.FLEISCHFRESSER}
	], null)
	check_eq(brain.state, AiBrain.TREIBEN, "state ist TREIBEN")


func test_regeln() -> void:
	check(AiBrain.is_threat(12.0, 18.0, Diet.FLEISCHFRESSER), "18 > 12 * 1.2: threat wahr")
	check(not AiBrain.is_threat(27.0, 18.0, Diet.FLEISCHFRESSER), "18 <= 27 * 1.2: threat falsch")
	check(AiBrain.is_prey(27.0, Diet.FLEISCHFRESSER, 18.0), "18 < 27 * 0.8: prey wahr für Fleischfresser")
	check(not AiBrain.is_prey(27.0, Diet.PFLANZENFRESSER, 18.0), "prey falsch für Pflanzenfresser")


func test_sicht_je_verhalten() -> void:
	check_eq(AiBrain.sight_for("scheu"), 450.0, "scheu sieht 450")
	check_eq(AiBrain.sight_for("lauerer"), 250.0, "lauerer sieht 250")
	check_eq(AiBrain.sight_for("jaeger"), 350.0, "jaeger sieht Standard 350")
	check_eq(AiBrain.sight_for(""), 350.0, "leere Zeichenkette ergibt Standard 350")


func test_scheu_sieht_weiter() -> void:
	brain.sight = AiBrain.sight_for("scheu")
	var result := brain.decide(Vector2.ZERO, 12.0, Diet.PFLANZENFRESSER, [{"position": Vector2(400, 0), "radius": 27.0, "diet": Diet.FLEISCHFRESSER}], null)
	check_eq(result, Vector2(-1, 0), "Schwimmrichtung nach links bei scheuer Zelle")
	check_eq(brain.state, AiBrain.FLIEHEN, "state ist FLIEHEN")
