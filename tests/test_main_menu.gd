extends "res://tests/base_test.gd"

var menu: Control

func setup() -> void:
	menu = load("res://scenes/main_menu.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(menu)

func teardown() -> void:
	GameSettings.car_id = CarCatalog.DEFAULT_ID
	GameSettings.track_id = TrackCatalog.DEFAULT_ID
	AudioServer.set_bus_volume_db(0, 0.0)
	menu.free()
	menu = null

func test_knoepfe() -> void:
	check_eq(menu.start_button.text, "Rennen starten", "Start-Knopf Text")
	check_eq(menu.settings_button.text, "Einstellungen", "Settings-Knopf Text")
	check(not menu.settings_button.disabled, "Einstellungen-Knopf ist freigeschaltet")
	check_eq(menu.quit_button.text, "Beenden", "Quit-Knopf Text")

func test_knoepfe_verbunden() -> void:
	check(menu.start_button.pressed.is_connected(menu.start_game), "Start-Knopf mit start_game verbunden")
	check(menu.quit_button.pressed.is_connected(menu.quit_game), "Quit-Knopf mit quit_game verbunden")

func test_einstellungen_verbunden() -> void:
	check(menu.settings_button.pressed.is_connected(menu.open_settings), "Settings-Knopf mit open_settings verbunden")
	check(ResourceLoader.exists(menu.SETTINGS_SCENE), "Einstellungen-Szene existiert")

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

func test_autowahl() -> void:
	GameSettings.car_id = CarCatalog.DEFAULT_ID
	menu.update_car_label()
	check_eq(menu.car_name.text, "Allrounder", "CarName zeigt Allrounder nach Default")
	menu.car_next.pressed.emit()
	check_eq(GameSettings.car_id, "grip", "Nach Next ist car_id grip")
	check_eq(menu.car_name.text, "Grip-Coupé", "Nach Next zeigt CarName Grip-Coupé")
	menu.car_prev.pressed.emit()
	menu.car_prev.pressed.emit()
	check_eq(GameSettings.car_id, "drifter", "Nach zweimal Prev ist car_id drifter")
	check_eq(menu.car_name.text, "Drift-Kombi", "Nach zweimal Prev zeigt CarName Drift-Kombi")


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


func test_klick() -> void:
	check(menu.get_node("Click") is AudioStreamPlayer, "Click Node ist AudioStreamPlayer")
	check(menu.click_player.stream is AudioStreamWAV, "click_player.stream ist AudioStreamWAV")
	check(menu.track_next.pressed.is_connected(menu.play_click), "track_next.pressed ist mit play_click verbunden")
	check(menu.car_prev.pressed.is_connected(menu.play_click), "car_prev.pressed ist mit play_click verbunden")

func test_menuemusik() -> void:
	check(menu.get_node("Music") is AudioStreamPlayer, "Music Node ist AudioStreamPlayer")
	check(menu.music.stream is AudioStreamWAV, "menu.music.stream ist AudioStreamWAV")
	check(absf(menu.music.volume_db - (-18.0)) < 0.001, "music.volume_db ist -18.0")

func test_titelbild() -> void:
	var image := menu.get_node("BackgroundImage") as TextureRect
	check(image != null, "BackgroundImage existiert")
	check(image.texture != null, "BackgroundImage hat eine Textur")
	check(menu.get_node("BackgroundImage").get_index() < menu.get_node("Buttons").get_index(), "BackgroundImage kommt vor Buttons")
	check(menu.get_node("ButtonShade") is ColorRect, "ButtonShade ist ein ColorRect")

func test_autobild() -> void:
	check(menu.car_preview.texture != null, "car_preview.texture ist nicht null")
	menu._on_car_next()
	var expected_texture := CarCatalog.sprite_of(GameSettings.car_id)
	check(menu.car_preview.texture.resource_path == expected_texture, "car_preview.texture entspricht CarCatalog.sprite_of(GameSettings.car_id)")


func test_namensnennung() -> void:
	var c := menu.get_node_or_null("Credits") as Label
	check(c != null, "Credits-Label im Hauptmenü vorhanden")
	if c != null:
		check(c.text.contains("Mike Koenig") and c.text.contains("CC BY 3.0"), "Namensnennung für das Reifenquietschen")
