extends "res://tests/base_test.gd"

const PATH := "user://test_spielstand.json"
var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)
	main.save_path = PATH


func teardown() -> void:
	if main:
		main.free()
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))


func test_neue_partie_fleisch() -> void:
	main.start_new(Diet.FLEISCHFRESSER)
	check_eq(main.player.diet, Diet.FLEISCHFRESSER, "Ernährung ist Fleischfresser")
	var mouths = main.player.build.mouths()
	check(mouths.size() > 0, "Es gibt mindestens einen Mund")
	if mouths.size() > 0:
		check_eq(mouths[0], "kiefer", "Erster Mund ist Kiefer")
	check_eq(main.progress.dna, 0, "DNA startet bei 0")
	check(main.autosave == true, "Autosave ist aktiv")


func test_speichern_laden() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	main.progress.dna = 17
	main.unlocks.unlock("geissel")
	main.player.build.add_part("geissel", Vector2(-1, 0))
	var l := CellLook.new()
	l.set_pattern("punkte")
	main.player.set_look(l)

	check(main.save_now() == true, "Speichern erfolgreich")

	# Spielstand zurücksetzen
	main.progress.dna = 0
	main.unlocks.unlocked.clear()
	main.player.set_build(CellBuild.new())
	main.player.set_look(CellLook.new())

	check(main.load_saved() == true, "Laden erfolgreich")
	check_eq(main.progress.dna, 17, "DNA ist nach dem Laden wieder 17")
	check(main.unlocks.is_unlocked("geissel"), "Geissel ist nach dem Laden freigeschaltet")
	check_eq(main.player.build.parts.size(), 3, "Es gibt nach dem Laden 3 Teile")
	check_eq(main.player.look.pattern, "punkte", "Muster ist nach dem Laden Punkte")


func test_ohne_spielstand() -> void:
	var result = main.load_saved()
	check(result == false, "Laden ohne Spielstand schlägt fehl")
	check(main.autosave == false, "Autosave bleibt deaktiviert")


func test_autospeichern_nach_editor() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	main.open_editor()
	main.editor.cancel()

	check(FileAccess.file_exists(PATH), "Spielstand wurde gespeichert")


func test_kein_autospeichern_ohne_partie() -> void:
	main.open_editor()
	main.editor.cancel()

	check(not FileAccess.file_exists(PATH), "Kein Spielstand ohne start_new")


func test_autospeichern_beim_wachsen() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	main.food.items.clear()
	main.progress.eat(9)
	main.food.add_item(Diet.PFLANZE, main.player.mouth_point())
	main.feed_player()

	check(FileAccess.file_exists(PATH), "Autospeichern beim Wachsen erfolgreich")
