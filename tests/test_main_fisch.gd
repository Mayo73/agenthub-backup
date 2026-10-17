extends "res://tests/base_test.gd"

const P := "user://test_main_fisch.json"
var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	main.save_path = P
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()
	FishStart.clear()
	if FileAccess.file_exists(P):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(P))


func test_knopf() -> void:
	check(main.end_screen.fish_button is Button, "fish_button ist ein Button")
	check_eq(main.end_screen.fish_button.text, "Weiter zur Fischphase", "Text des Buttons stimmt")
	check(main.end_screen.to_fish_phase.is_connected(main.go_to_fish), "Signal verbunden mit go_to_fish")


func test_knopf_signal() -> void:
	var e := EndScreen.new()
	var got := [false]
	e.to_fish_phase.connect(func() -> void: got[0] = true)
	e.fish_button.pressed.emit()
	check(got[0], "Signal wurde gesendet")
	e.free()


func test_vorbereiten() -> void:
	main.start_new(Diet.FLEISCHFRESSER)
	main.progress.dna = 55
	main.prepare_fish()
	check(FishStart.pending_build != null, "pending_build ist nicht null")
	check_eq(FishStart.pending_build.diet, Diet.FLEISCHFRESSER, "diät stimmt")
	check_eq(FishStart.pending_build.level("kiefer"), 1, "kiefer Stufe 1")
	check_eq(FishStart.pending_build.level("augen"), 1, "augen Stufe 1")
	check_eq(FishStart.pending_dna, 55, "dna stimmt")


func test_szene_vorhanden() -> void:
	check(ResourceLoader.exists(main.FISH_SCENE), "Fisch-Szene existiert")
