extends "res://tests/base_test.gd"


func test_bits() -> void:
	var cl := CollisionLayers.new()
	check_eq(cl.bit("Welt"), 1, "erste Ebene = 1")
	check_eq(cl.bit("Projektile"), 8, "vierte Ebene = 8")
	check_eq(cl.bit("Wasser"), 0, "unbekannte Ebene = 0")


func test_maske() -> void:
	var cl := CollisionLayers.new()
	check_eq(cl.mask(["Welt", "Gegner"]), 5, "Maske aus Welt und Gegner")


func test_unbekannt() -> void:
	var cl := CollisionLayers.new()
	var result: Array[String] = cl.unknown(["Welt", "Wasser", "Luft"])
	check_eq(result, ["Wasser", "Luft"], "nur unbekannte Namen")


func test_kollision() -> void:
	# Projektil (Ebene 3, Bit 8) trifft Gegner (Ebene 2, Bit 4)
	# layer_a = 8 (Projektil), mask_a = 4 (Akzeptiert Gegner), layer_b = 4 (Gegner), mask_b = 1 (Akzeptiert Welt)
	check(CollisionLayers.collides(8, 4, 4, 1), "Projektil trifft Gegner")

	# Projektil gegen Spieler (kein Treffer)
	# layer_a = 8 (Projektil), mask_a = 2 (Akzeptiert nur Spieler), layer_b = 2 (Spieler), mask_b = 1
	check(not CollisionLayers.collides(8, 4, 2, 1), "Projektil gegen Spieler")


func test_namen() -> void:
	var cl := CollisionLayers.new()
	# Ebene 1 (Welt) + Ebene 3 (Gegner) = 1 | 4 = 5? Nein: Bit 0 = 1, Bit 2 = 4, also 1 | 4 = 5
	# Ebenenreihenfolge: ["Welt", "Spieler", "Gegner", "Projektile"] -> Bit 0=1, 1=2, 2=4, 3=8
	# Wert 10 = Bit 1 (2) + Bit 3 (8) = Spieler + Projektile
	check_eq(cl.names_of(10), ["Spieler", "Projektile"], "Namen für Wert 10")


func test_eigene_namen() -> void:
	var cl := CollisionLayers.new(["A", "B"])
	check_eq(cl.bit("B"), 2, "zweite Ebene in eigener Liste = 2")
	check_eq(cl.bit("Welt"), 0, "unbekannte Ebene = 0")
