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
static func load_state(path: String = DEFAULT_PATH) -> AppState:
	if not FileAccess.file_exists(path):
		return AppState.demo()
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		return AppState.demo()
	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY or int(data.get("version", 0)) != 1:
		return AppState.demo()
	return AppState.from_dict(data)


## Gespeicherten Zustand löschen und die Demodaten neu speichern
static func reset(path: String = DEFAULT_PATH) -> AppState:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	var state := AppState.demo()
	save(state, path)
	return state
