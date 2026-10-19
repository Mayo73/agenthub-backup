extends "res://tests/base_test.gd"

var hud: Hud


func setup() -> void:
	hud = Hud.new()


func teardown() -> void:
	hud.free()


func test_fortschritt() -> void:
	var p := CellProgress.new()
	p.eat(5)
	hud.show_progress(p)
	check_eq(hud.dna_label.text, "DNA: 5", "dna_label zeigt richtige DNA")
	check_eq(hud.growth_bar.value, 50.0, "growth_bar value ist 50.0")
	check_eq(hud.stage_label.text, "Größe 1/5", "stage_label zeigt richtige Größe")


func test_letzte_groesse() -> void:
	var p := CellProgress.new()
	p.eat(100)
	hud.show_progress(p)
	check_eq(hud.stage_label.text, "Größe 5/5", "stage_label zeigt letzte Größe")
	check_eq(hud.growth_bar.value, 100.0, "growth_bar value ist 100.0 im letzten Abschnitt")


func test_gesundheit() -> void:
	var h := CellHealth.new()
	h.damage(50.0)
	hud.show_health(h)
	check_eq(hud.health_bar.value, 50.0, "health_bar.value ist 50.0 nach 50 Schaden")


func test_meldung_verschwindet() -> void:
	hud.show_message("Hallo", 1.0)
	check_eq(hud.message_label.text, "Hallo", "message_label zeigt Text direkt nach show_message")
	hud._process(1.5)
	check_eq(hud.message_label.text, "", "message_label ist leer nach _process mit Zeit > seconds")


func test_beschriftungen() -> void:
	check_eq(hud.growth_caption.text, "Wachstum", "growth_caption hat Text 'Wachstum'")
	check_eq(hud.health_caption.text, "Gesundheit", "health_caption hat Text 'Gesundheit'")


func test_reihenfolge() -> void:
	check(hud.growth_caption.get_index() + 1 == hud.growth_bar.get_index(), "GrowthCaption kommt direkt vor Growth_bar")
	check(hud.health_caption.get_index() + 1 == hud.health_bar.get_index(), "HealthCaption kommt direkt vor Health_bar")


func test_fischhinweis() -> void:
	hud.show_fish_hint("abc")
	check(hud.fish_label.visible, "fish_label sichtbar bei nicht leerem Text")
	check_eq(hud.fish_label.text, "abc", "fish_label zeigt richtigen Text")
	hud.show_fish_hint("")
	check(not hud.fish_label.visible, "fish_label unsichtbar bei leerem Text")
