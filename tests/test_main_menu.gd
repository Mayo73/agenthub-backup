extends "res://tests/base_test.gd"

var menu: Control

func setup() -> void:
	menu = load("res://scenes/main_menu.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(menu)

func teardown() -> void:
	GameSettings.track_id = TrackCatalog.DEFAULT_ID
	menu.free()
	menu = null

func test_knoepfe() -> void:
	check_eq(menu.start_button.text, "Rennen starten", "Start-Knopf Text")
	check_eq(menu.settings_button.text, "Einstellungen", "Settings-Knopf Text")
	check(menu.settings_button.disabled, "Settings-Knopf ist ausgegraut")
	check_eq(menu.quit_button.text, "Beenden", "Quit-Knopf Text")

func test_knoepfe_verbunden() -> void:
	check(menu.start_button.pressed.is_connected(menu.start_game), "Start-Knopf mit start_game verbunden")
	check(menu.quit_button.pressed.is_connected(menu.quit_game), "Quit-Knopf mit quit_game verbunden")

func test_rennszene_existiert() -> void:
	check(ResourceLoader.exists(menu.GAME_SCENE), "Rennszene existiert")

func test_startszene_ist_menue() -> void:
	var main_scene: String = ProjectSettings.get_setting("application/run/main_scene")
	check_eq(main_scene, "res://scenes/main_menu.tscn", "Startszene ist das Hauptmenü")

func test_streckenwahl() -> void:
	GameSettings.track_id = TrackCatalog.DEFAULT_ID
	menu.update_track_label()
	check_eq(menu.track_name.text, "Hafenring", "TrackName zeigt Hafenring nach Default")
	menu.track_next.pressed.emit()
	check_eq(GameSettings.track_id, "altstadt", "Nach Next ist track_id altstadt")
	check_eq(menu.track_name.text, "Altstadtkurs", "Nach Next zeigt TrackName Altstadtkurs")
	menu.track_prev.pressed.emit()
	menu.track_prev.pressed.emit()
	check_eq(GameSettings.track_id, "kurvenring", "Nach zweimal Prev ist track_id kurvenring")
	check_eq(menu.track_name.text, "Kurvenring", "Nach zweimal Prev zeigt TrackName Kurvenring")


func test_bestwerte_anzeigen() -> void:
	var path := "user://test_menu_bestenliste.json"
	var table := HighscoreTable.new()
	table.submit("hafen", 95.5, 800)
	table.save(path)

	GameSettings.track_id = "hafen"
	menu.highscore_path = path
	menu.update_track_label()
	check_eq(menu.track_best.text, "Bestzeit 1:35.50  ·  Rekord 800 Punkte", "Bestwerte für Hafenring")

	GameSettings.track_id = "altstadt"
	menu.update_track_label()
	check_eq(menu.track_best.text, "Bestzeit –  ·  Rekord 0 Punkte", "Bestwerte für Altstadtkurs (keine Einträge)")

	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
