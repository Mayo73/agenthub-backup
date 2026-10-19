extends "res://tests/base_test.gd"

const TEST_PATH := "user://test_einstellungen.json"

var settings: UserSettings

func setup() -> void:
	settings = UserSettings.new()

func teardown() -> void:
	var abs_path := ProjectSettings.globalize_path(TEST_PATH)
	if FileAccess.file_exists(abs_path):
		DirAccess.remove_absolute(abs_path)
	AudioServer.set_bus_volume_db(0, 0.0)
	Controls.reset_defaults()

func test_standardwerte() -> void:
	check_eq(settings.volume, 0.8, "volume default ist 0.8")
	check(not settings.fullscreen, "fullscreen default ist falsch")

func test_lautstaerke_in_db() -> void:
	check_eq(UserSettings.volume_db(1.0), 0.0, "volume_db(1.0) ist 0.0")
	check_eq(UserSettings.volume_db(0.0), -80.0, "volume_db(0.0) ist -80.0")
	check(absf(UserSettings.volume_db(0.5) - linear_to_db(0.5)) < 0.001, "volume_db(0.5) entspricht linear_to_db(0.5)")

func test_speichern_und_laden() -> void:
	settings.volume = 0.25
	settings.fullscreen = true
	check(settings.save(TEST_PATH), "speichern erfolgreich")
	var loaded := UserSettings.load_from(TEST_PATH)
	check_eq(loaded.volume, 0.25, "geladene volume ist 0.25")
	check(loaded.fullscreen, "geladene fullscreen ist wahr")

func test_fehlende_datei() -> void:
	var loaded := UserSettings.load_from("user://gibt_es_nicht.json")
	check_eq(loaded.volume, 0.8, "bei fehlender Datei ist volume 0.8")

func test_anwenden() -> void:
	settings.volume = 0.5
	settings.apply()
	check(absf(AudioServer.get_bus_volume_db(0) - linear_to_db(0.5)) < 0.01, "apply setzt Lautstärke korrekt")

func test_tasten_speichern() -> void:
	var s := UserSettings.new()
	s.keys = {"gas": KEY_I}
	s.save(TEST_PATH)
	var l := UserSettings.load_from(TEST_PATH)
	check(l.keys.has("gas"), "keys hat Eintrag für 'gas'")
	check_eq(l.keys["gas"], KEY_I, "geladener key für gas ist KEY_I")

func test_tasten_anwenden() -> void:
	var s := UserSettings.new()
	s.keys = {"gas": KEY_I}
	s.apply()
	check_eq(Controls.key_for("gas"), KEY_I, "key_for(gas) ist KEY_I nach apply()")

func test_ohne_tasten() -> void:
	check(UserSettings.new().keys.is_empty(), "neue Settings haben leeres keys-Dictionary")

func test_fenstermodus() -> void:
	check_eq(UserSettings.window_mode_for(false, DisplayServer.WINDOW_MODE_MAXIMIZED), -1, "maximiertes Fenster bleibt maximiert")
	check_eq(UserSettings.window_mode_for(false, DisplayServer.WINDOW_MODE_WINDOWED), -1, "Fenster bleibt unverändert")
	check_eq(UserSettings.window_mode_for(false, DisplayServer.WINDOW_MODE_FULLSCREEN), DisplayServer.WINDOW_MODE_WINDOWED, "Vollbild aus: zurück ins Fenster")
	check_eq(UserSettings.window_mode_for(true, DisplayServer.WINDOW_MODE_MAXIMIZED), DisplayServer.WINDOW_MODE_FULLSCREEN, "Vollbild an")
	check_eq(UserSettings.window_mode_for(true, DisplayServer.WINDOW_MODE_FULLSCREEN), -1, "Vollbild bleibt")
