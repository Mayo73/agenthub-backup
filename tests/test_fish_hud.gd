extends "res://tests/base_test.gd"

var hud: FishHud


func setup() -> void:
	hud = FishHud.new()


func teardown() -> void:
	hud.free()


func test_gesundheit_text() -> void:
	check_eq(FishHud.health_text(1.0), "Gesundheit: 100 %", "health_text(1.0)")
	check_eq(FishHud.health_text(0.456), "Gesundheit: 46 %", "health_text(0.456)")
	check_eq(FishHud.health_text(-1.0), "Gesundheit: 0 %", "health_text(-1.0)")


func test_gesundheit_label() -> void:
	var h := FishHud.new()
	check_eq(h.health_label.text, "Gesundheit: 100 %", "health_label.text ist Gesundheit: 100 %")
	h.free()


func test_start() -> void:
	check_eq(hud.depth_label.text, "Tiefe: 20 m", "Starttiefe")
	check_eq(hud.dna_label.text, "DNA: 0", "Start-DNA")
	check_eq(hud.growth_label.text, "Wachstum: 0 / 20", "Start-Wachstum")
	check_eq(hud.help_label.text, FishHud.HELP, "Steuerungshilfe")
	check(!hud.message_label.visible, "Keine Meldung initial sichtbar")


func test_tiefe() -> void:
	check_eq(FishHud.depth_text(12.4), "Tiefe: 12 m", "Tiefe gerundet")
	hud.show_depth(41.6)
	check_eq(hud.depth_label.text, "Tiefe: 42 m", "Tiefe aktualisiert")


func test_fortschritt() -> void:
	var p := FishProgress.new()
	p.eat(25)
	hud.show_progress(p)
	check_eq(hud.dna_label.text, "DNA: 25", "DNA nach Essen")
	check_eq(hud.growth_label.text, "Wachstum: 5 / 30", "Wachstum nach Essen")


func test_ausgewachsen() -> void:
	var p := FishProgress.new()
	p.eat(500)
	check_eq(FishHud.growth_text(p), "Wachstum: ausgewachsen", "Ausgewachsen-Text")


func test_meldung() -> void:
	hud.show_message("Hallo", 2.0)
	check(hud.message_label.visible, "Meldung sichtbar nach show_message")
	check_eq(hud.message_label.text, "Hallo", "Meldungstext korrekt")
	hud.tick(1.0)
	check(hud.message_label.visible, "Meldung noch sichtbar nach 1.0s")
	hud.tick(1.5)
	check(!hud.message_label.visible, "Meldung unsichtbar nach 2.5s")


func test_schnee() -> void:
	var s := MarineSnow.new()
	check_eq(s.amount, 400, "Anzahl Teilchen")
	check_eq(s.emission_box_extents, Vector3(15, 10, 15), "Emission-Bereich")
	check(!s.local_coords, "Nicht-lokale Koordination")
	check(s.mesh is QuadMesh, "Teilchen verwenden QuadMesh")
	s.free()
