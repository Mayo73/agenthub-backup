class_name UserSettings
extends RefCounted
## Einstellungen, die dauerhaft gespeichert werden: Lautstärken, Vollbild, Auflösung.

const DEFAULT_PATH := "user://einstellungen.cfg"
const RESOLUTIONS := [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080), Vector2i(2560, 1440)]

var music_volume := 0.8
var sfx_volume := 0.8
var fullscreen := false
var resolution_index := 2


func set_music_volume(v: float) -> void:
	music_volume = clampf(v, 0.0, 1.0)


func set_sfx_volume(v: float) -> void:
	sfx_volume = clampf(v, 0.0, 1.0)


func set_resolution_index(i: int) -> void:
	resolution_index = clampi(i, 0, RESOLUTIONS.size() - 1)


func resolution() -> Vector2i:
	return RESOLUTIONS[resolution_index]


## Lautstärke 0 bis 1 in Dezibel für einen Audiobus; 0 ergibt -80 dB (stumm).
static func to_db(v: float) -> float:
	if v <= 0.0:
		return -80.0
	return linear_to_db(v)


func save(path: String = DEFAULT_PATH) -> bool:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("display", "fullscreen", fullscreen)
	cfg.set_value("display", "resolution", resolution_index)
	return cfg.save(path) == OK


## Lädt gespeicherte Werte; fehlt die Datei, bleiben die Standardwerte. Ungültige Werte werden begrenzt.
func load_from(path: String = DEFAULT_PATH) -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return false
	set_music_volume(float(cfg.get_value("audio", "music", music_volume)))
	set_sfx_volume(float(cfg.get_value("audio", "sfx", sfx_volume)))
	fullscreen = bool(cfg.get_value("display", "fullscreen", fullscreen))
	set_resolution_index(int(cfg.get_value("display", "resolution", resolution_index)))
	return true
