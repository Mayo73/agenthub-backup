class_name UserSettings
extends RefCounted

const DEFAULT_PATH := "user://einstellungen.json"

var volume: float = 0.8
var fullscreen: bool = false
var keys := {}  # Aktion → physical_keycode, nur geänderte Tasten

static func volume_db(v: float) -> float:
	if v <= 0.001:
		return -80.0
	return linear_to_db(v)

func save(path: String = DEFAULT_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({"volume": volume, "fullscreen": fullscreen, "keys": keys}))
	file.close()
	return true

static func load_from(path: String = DEFAULT_PATH) -> UserSettings:
	var settings := UserSettings.new()
	if not FileAccess.file_exists(path):
		return settings
	var content := FileAccess.get_file_as_string(path)
	if content == null:
		return settings
	var parsed = JSON.parse_string(content)
	if not (parsed is Dictionary):
		return settings
	var d := parsed as Dictionary
	settings.volume = clampf(float(d.get("volume", 0.8)), 0.0, 1.0)
	settings.fullscreen = bool(d.get("fullscreen", false))
	var k: Variant = d.get("keys", {})
	if k is Dictionary:
		for action in k:
			settings.keys[str(action)] = int(k[action])
	return settings

## Fenstermodus, den apply() setzen muss; -1 = nichts ändern. Nur der Wechsel zwischen Vollbild
## und Fenster wird gesetzt, ein vom Spieler vergrößertes (maximiertes) Fenster bleibt so groß.
static func window_mode_for(want_fullscreen: bool, current: int) -> int:
	var is_full := current == DisplayServer.WINDOW_MODE_FULLSCREEN or current == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	if want_fullscreen:
		return -1 if is_full else DisplayServer.WINDOW_MODE_FULLSCREEN
	return DisplayServer.WINDOW_MODE_WINDOWED if is_full else -1

func apply() -> void:
	AudioServer.set_bus_volume_db(0, volume_db(volume))
	if DisplayServer.get_name() != "headless":
		var mode := window_mode_for(fullscreen, DisplayServer.window_get_mode())
		if mode != -1:
			DisplayServer.window_set_mode(mode)
	Controls.setup()
	Controls.apply_bindings(keys)
