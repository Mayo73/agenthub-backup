extends "res://tests/base_test.gd"

var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	Engine.get_main_loop().root.add_child(main)
	main.progress.dna = 50
	main.unlocks.unlock("geissel")
	main.open_editor()
	main.editor.canvas.symmetry = false


func teardown() -> void:
	main.free()


# Hilfsfunktion: Geißel platzieren (752, 696) → (-0.8, 0.6)
func _place_one() -> void:
	main.editor.panel.select("geissel")
	main.editor.canvas.click(Vector2(752, 696))


# Hilfsfunktion: Teil am Index auswählen
func _select(index: int) -> void:
	main.editor.canvas.place_id = ""
	main.editor.canvas.selected = index


func test_platzieren() -> void:
	_place_one()
	check_eq(main.editor.session.working.parts.size(), 3, "drei Teile nach Platzierung")
	check_eq(main.editor.canvas.selected, 2, "neues Teil ausgewählt")
	check((main.editor.session.working.parts[2]["pos"] as Vector2).is_equal_approx(Vector2(-0.8, 0.6)), "Geißel bei (-0.8, 0.6)")


func test_verschieben() -> void:
	_place_one()
	_select(2)
	main.editor.canvas.begin_drag()
	main.editor.canvas.drag_to(Vector2(830, 670))
	main.editor.canvas.end_drag()
	check((main.editor.session.working.parts[2]["pos"] as Vector2).is_equal_approx(Vector2(-0.5, 0.5)), "Geißel bei (-0.5, 0.5)")


func test_drehen() -> void:
	_place_one()
	_select(2)
	var a0: float = main.editor.session.working.parts[2]["angle"]
	main.editor.canvas.rotate_selected(EditorPlacement.ANGLE_STEP)
	check(main.editor.session.working.parts[2]["angle"] == EditorPlacement.snap_angle(a0 + EditorPlacement.ANGLE_STEP), "Winkel um einen Schritt gedreht")


func test_entfernen() -> void:
	_place_one()
	main.editor.panel.select("geissel")
	main.editor.canvas.click(Vector2(752, 384))
	check_eq(main.editor.session.working.parts.size(), 4, "zweite Geißel eingebaut")
	_select(3)
	main.editor.canvas.remove_selected()
	check_eq(main.editor.session.working.parts.size(), 3, "drei Teile nach Entfernen")


func test_alles_zusammen() -> void:
	_place_one()

	# Verschieben
	_select(2)
	main.editor.canvas.begin_drag()
	main.editor.canvas.drag_to(Vector2(830, 670))
	main.editor.canvas.end_drag()

	# Drehen
	var a0: float = main.editor.session.working.parts[2]["angle"]
	main.editor.canvas.rotate_selected(EditorPlacement.ANGLE_STEP)

	# Zweite Geißel einbauen und entfernen
	main.editor.panel.select("geissel")
	main.editor.canvas.click(Vector2(752, 384))
	_select(3)
	main.editor.canvas.remove_selected()

	# Farbe und Streckung setzen
	main.editor.set_color(Color.RED)
	main.editor.set_stretch(1.3)

	# Kosten prüfen
	var cost: int = main.editor.session.cost()
	check_eq(cost, 15, "Kosten sind 15")
	check_eq(main.editor.panel.cost_label.text, "Kosten: %d DNA" % cost, "Kostenanzeige stimmt")

	# Vorschau prüfen
	var expected_preview := "\n".join(PackedStringArray(EditorPreview.lines(main.editor.session.original, main.editor.session.working, main.progress.stage)))
	check_eq(main.editor.panel.preview_label.text, expected_preview, "Vorschau stimmt überein")

	# Bestätigen und fertige Zelle prüfen
	var erwartet: CellBuild = main.editor.session.working.copy()
	main.editor.confirm()
	check_eq(main.progress.dna, 35, "DNA nach Bestätigung: 35")
	check_eq(main.player.build.parts.size(), 3, "fertige Zelle hat drei Teile")
	check((main.player.build.parts[2]["pos"] as Vector2).is_equal_approx(Vector2(-0.5, 0.5)), "Position im Spiel stimmt")
	check(main.player.build.parts[2]["angle"] == erwartet.parts[2]["angle"], "Winkel im Spiel stimmt")
	check_eq(main.player.motion.max_speed, CellStats.max_speed(erwartet, main.progress.stage), "Geschwindigkeit korrekt berechnet")

	# Farbe prüfen
	check(main.player.look.color.is_equal_approx(Color.RED), "Farbe ist rot")

	# Streckung prüfen
	var l := CellLook.new()
	l.set_stretch(1.3)
	check_eq(main.player.look.stretch, l.stretch, "Streckung ist 1.3")
