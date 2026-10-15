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
