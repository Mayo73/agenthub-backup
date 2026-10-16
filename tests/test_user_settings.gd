extends "res://tests/base_test.gd"

const PATH := "user://test_einstellungen.cfg"
var s: UserSettings


func setup() -> void:
	s = UserSettings.new()


func teardown() -> void:
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))


func test_standard() -> void:
	check_eq(s.music_volume, 0.8, "Standard-Lautstärke Musik ist 0.8")
	check(not s.fullscreen, "Fullscreen ist standardmäßig falsch")
	check(s.resolution() == Vector2i(1920, 1080), "Auflösung ist 1920x1080")


func test_grenzen() -> void:
	s.set_music_volume(1.5)
	check_eq(s.music_volume, 1.0, "Musik-Lautstärke wird auf 1.0 begrenzt")
	s.set_sfx_volume(-1.0)
	check_eq(s.sfx_volume, 0.0, "SFX-Lautstärke wird auf 0.0 begrenzt")
	s.set_resolution_index(9)
	check_eq(s.resolution_index, 3, "Auflösungsindex wird auf max 3 begrenzt")


func test_dezibel() -> void:
	check_eq(UserSettings.to_db(0.0), -80.0, "to_db(0.0) ergibt -80.0")
	check_eq(UserSettings.to_db(1.0), 0.0, "to_db(1.0) ergibt 0.0")


func test_speichern_laden() -> void:
	s.set_music_volume(0.3)
	s.fullscreen = true
	s.set_resolution_index(0)
	check(s.save(PATH), "Speichern soll erfolgreich sein")
	var t := UserSettings.new()
	check(t.load_from(PATH), "Laden soll erfolgreich sein")
	check_eq(t.music_volume, 0.3, "Music-Lautstärke wurde geladen")
	check_eq(t.sfx_volume, 0.8, "SFX-Lautstärke ist Standardwert")
	check(t.fullscreen, "Fullscreen wurde geladen")
	check_eq(t.resolution_index, 0, "Auflösungsindex wurde geladen")


func test_fehlende_datei() -> void:
	check(not s.load_from("user://gibtsnicht.cfg"), "Laden nicht existenter Datei schlägt fehl")
	check_eq(s.music_volume, 0.8, "Standardwerte bleiben erhalten")
