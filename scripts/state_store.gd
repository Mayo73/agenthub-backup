class_name StateStore
extends RefCounted
## Speichert den App-Zustand als JSON, lädt ihn wieder und setzt ihn zurück.

const DEFAULT_PATH := "user://sparring.json"


## Zustand speichern; false, wenn die Datei nicht geöffnet werden kann
static func save(state: AppState, path: String = DEFAULT_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(state.to_dict(), "\t"))
	file.close()
	return true


## Zustand laden; fehlt die Datei oder ist sie unbrauchbar, gibt es die Demodaten
## Farbe, die SparProfile.from_dict ohne gültige Farbe vergibt.
const GRAY := Color(0.5, 0.5, 0.5)


static func load_state(path: String = DEFAULT_PATH) -> AppState:
	if not FileAccess.file_exists(path):
		return AppState.demo()
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		return AppState.demo()
	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY or int(data.get("version", 0)) != 1:
		return AppState.demo()
	var state := AppState.from_dict(data)
	# Bis 20.10.2026 verlor DemoData die Avatarfarben (alle grau gespeichert): aus den Demodaten ergänzen.
	for demo in DemoData.profiles():
		for p in state.profiles:
			if p.id == demo.id and _is_gray(p.color):
				p.color = demo.color
	return state


## Gespeicherten Zustand löschen und die Demodaten neu speichern
static func reset(path: String = DEFAULT_PATH) -> AppState:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	var state := AppState.demo()
	save(state, path)
	return state


## Grau aus SparProfile.from_dict, auch nach dem Umweg über HTML ("808080" = 0.502).
static func _is_gray(c: Color) -> bool:
	return absf(c.r - GRAY.r) < 0.01 and absf(c.g - GRAY.g) < 0.01 and absf(c.b - GRAY.b) < 0.01
