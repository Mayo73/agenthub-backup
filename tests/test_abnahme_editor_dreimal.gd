extends "res://tests/base_test.gd"

const P := "user://test_abnahme_editor.json"
var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	main.save_path = P
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	if main != null:
		main.free()
	if FileAccess.file_exists(P):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(P))


func _visit() -> void:
	main.mate.add_charge()
	main.call_mate()
	main.player.position = main.mate.partner_pos
	main.update_mate()


func _play_a_bit() -> void:
	for _i in range(30):
		main._physics_process(1.0 / 60.0)


func test_dreimal() -> void:
	# Start neue Partie, DNA hoch und Geißel freischalten
	main.start_new(Diet.PFLANZENFRESSER)
	main.progress.dna = 30
	main.unlocks.unlock("geissel")

	# Besuch 1
	_visit()
	check(main.editor_open, "Nach erstem Besuch muss Editor geöffnet sein")
	main.editor.panel.select("geissel")
	main.editor.canvas.click(Vector2(752, 696))
	main.editor.confirm()
	check(not main.editor_open, "Nach Bestätigung muss Editor geschlossen sein")
	check_eq(main.player.build.parts.size(), 4, "Spielerzelle soll 4 Teile haben (1 Starter + 3 = Geißel)")
	check_eq(main.player.motion.max_speed, 310.0, "Geschwindigkeit nach Geißel-Einbau")

	# Ein bisschen spielen
	_play_a_bit()
	check(main.world.visible, "Welt muss sichtbar sein")
	check(main.player.input_enabled, "Steuerung muss aktiv sein")

	# Besuch 2
	_visit()
	check(main.editor_open, "Nach zweitem Besuch muss Editor geöffnet sein")
	main.editor.set_color(Color.RED)
	main.editor.confirm()
	check(main.player.look.color.is_equal_approx(Color.RED), "Zellfarbe soll rot sein")
	check_eq(main.player.build.parts.size(), 4, "Anzahl Teile nach Farbbeibehaltung")

	_play_a_bit()

	# Besuch 3
	_visit()
	check(main.editor_open, "Nach drittem Besuch muss Editor geöffnet sein")
	main.editor.set_stretch(1.3)
	main.editor.confirm()
	var l := CellLook.new()
	l.set_stretch(1.3)
	check_eq(main.player.look.stretch, l.stretch, "Stretch nach drittem Besuch")
	check(main.player.look.color.is_equal_approx(Color.RED), "Farbe bleibt rot")
	check_eq(main.player.build.parts.size(), 4, "Anzahl Teile nach Stretch-Änderung")
	check_eq(main.player.motion.max_speed, 310.0, "Geschwindigkeit unverändert nach Stretch")

	# Final checks
	check_eq(main.stats.editor_visits, 3, "Dreimal Editor besucht")
	var build := SaveGame.read_build(SaveGame.read_file(P))
	check_eq(build.parts.size(), 4, "Spielstand soll 4 Teile enthalten")


func test_abbrechen_behaelt_umbau() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	main.progress.dna = 30
	main.unlocks.unlock("geissel")

	# Erster Besuch: Geißel einbauen
	_visit()
	check(main.editor_open, "Editor soll geöffnet sein")
	main.editor.panel.select("geissel")
	main.editor.canvas.click(Vector2(752, 696))
	main.editor.confirm()

	# Zweiter Besuch: Abbrechen
	_visit()
	check(main.editor_open, "Editor nach zweitem Besuch muss geöffnet sein")
	main.editor.cancel()
	check(not main.editor_open, "Nach Abbruch muss Editor geschlossen sein")
	check_eq(main.player.build.parts.size(), 4, "Eingebaute Geißel bleibt erhalten")
	check_eq(main.progress.dna, 0, "DNA nach Abbruch soll zurückgesetzt sein")
