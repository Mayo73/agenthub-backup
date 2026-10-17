extends "res://tests/base_test.gd"

const P := "user://test_abnahme_freischaltung.json"
var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	main.save_path = P
	(Engine.get_main_loop() as SceneTree).root.add_child(main)
	main.start_new(Diet.FLEISCHFRESSER)


func teardown() -> void:
	main.free()
	if FileAccess.file_exists(P):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(P))


func _place(id: String, screen: Vector2) -> void:
	main.editor.canvas.symmetry = false
	main.editor.panel.select(id)
	main.editor.canvas.click(screen)


func test_gesperrt_nicht_einbaubar() -> void:
	main.progress.dna = 100
	check(not main.unlocks.is_unlocked("geissel"), "Geißel ist gesperrt")
	main.open_editor()
	_place("geissel", Vector2(752, 696))
	check_eq(main.editor.session.working.parts.size(), 2, "Editor hat 2 Teile (Start + Geißel)")
	main.editor.confirm()
	check_eq(main.progress.dna, 100, "DNA nach gesperrtem Teil unverändert")
	check_eq(main.player.build.count("geissel"), 0, "Geißel nicht eingebaut")


func test_fund_schaltet_frei() -> void:
	main.pickups.positions.clear()
	main.pickups.positions.append(main.player.position)
	main.collect_pickups()
	check(main.unlocks.is_unlocked("geissel"), "Geißel nach Fund freigeschaltet")
	check_eq(main.pickups.positions.size(), 0, "Keine Funde mehr übrig")

	main.progress.dna = 15
	main.open_editor()
	_place("geissel", Vector2(752, 696))
	main.editor.confirm()
	check(not main.editor_open, "Editor nach Bestätigung geschlossen")
	check_eq(main.progress.dna, 0, "DNA nach Einkauf verbraucht")
	check_eq(main.player.build.count("geissel"), 1, "Geißel eingebaut")


func test_beute_schaltet_frei() -> void:
	var cell := AiCell.new()
	cell.setup("stachelkugel", Vector2(5000, 0))
	main.world.add_child(cell)
	main.ai_cells.append(cell)
	cell.health.damage(1000.0)
	main.resolve_combat()
	check(main.unlocks.is_unlocked("stachel"), "Stachel nach Beute freigeschaltet")
	check(not main.ai_cells.has(cell), "Besiegte Zelle entfernt")

	main.progress.dna = 15
	main.open_editor()
	_place("stachel", Vector2(752, 696))
	main.editor.confirm()
	check_eq(main.player.build.count("stachel"), 1, "Stachel eingebaut")
	check_eq(main.progress.dna, 0, "DNA nach Einkauf verbraucht")


func test_zu_teuer() -> void:
	main.unlocks.unlock("elektro")
	main.progress.dna = 24
	main.open_editor()
	_place("elektro", Vector2(752, 696))
	check_eq(main.editor.session.cost(), 25, "Elektro kostet 25 DNA")
	check(main.editor.panel.confirm_button.disabled, "Bestätigen bei zu wenig DNA deaktiviert")
	main.editor.confirm()
	check(main.editor_open, "Editor offen, Bestätigung abgelehnt")
	check_eq(main.progress.dna, 24, "DNA unverändert")

	main.editor.cancel()
	check(not main.editor_open, "Editor nach Abbrechen geschlossen")
	check_eq(main.progress.dna, 24, "DNA nach Abbrechen unverändert")
	check_eq(main.player.build.count("elektro"), 0, "Elektro nicht eingebaut")


func test_dna_nie_negativ() -> void:
	main.unlocks.unlock("elektro")
	main.unlocks.unlock("stachel")
	main.progress.dna = 25

	main.open_editor()
	_place("elektro", Vector2(752, 696))
	main.editor.confirm()
	check_eq(main.progress.dna, 0, "DNA nach Elektro-Einkauf verbraucht")

	main.open_editor()
	_place("stachel", Vector2(752, 384))
	main.editor.confirm()
	check(main.editor_open, "Editor offen, nicht genug DNA für Stachel (15)")
	check_eq(main.progress.dna, 0, "DNA nie negativ")
	main.editor.cancel()

	check(not main.progress.spend(10), "Keine Ausgabe bei 0 DNA")
	check_eq(main.progress.dna, 0, "DNA bleibt bei 0")
