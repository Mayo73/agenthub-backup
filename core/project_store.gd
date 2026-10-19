class_name ProjectStore
extends RefCounted

## Speichert und lädt Projekte im JSON-Format. Schrieben und Lesen nur innerhalb erlaubter Pfade.

const FORMAT := 1

var guard: PathGuard


func _init(path_guard: PathGuard) -> void:
	guard = path_guard


func save(path: String, name: String, scene: SceneModel, modules: Array[String]) -> CommandResult:
	var erlaubt: CommandResult = guard.check(path)
	if not erlaubt.is_ok():
		return erlaubt

	var inhalt := {
		"format": FORMAT,
		"name": name,
		"scene": scene.to_dict(),
		"modules": modules
	}

	var pfad_vorher := path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(pfad_vorher)

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return CommandResult.error(CommandResult.EXEC_FAILED, "Speichern fehlgeschlagen: %s" % path)

	file.store_string(JSON.stringify(inhalt, "\t"))
	file.close()

	return CommandResult.success({"path": path})


func open(path: String) -> CommandResult:
	var erlaubt: CommandResult = guard.check(path)
	if not erlaubt.is_ok():
		return erlaubt

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return CommandResult.error(CommandResult.NOT_FOUND, "Projekt fehlt: %s" % path)

	var inhalt_str := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(inhalt_str)
	if error != OK:
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Projektdatei ist beschädigt: %s" % path)

	if typeof(json.data) != TYPE_DICTIONARY:
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Projektdatei ist beschädigt: %s" % path)
	var d: Dictionary = json.data

	var format_val := int(d.get("format", 0))
	if format_val != FORMAT:
		return CommandResult.error(CommandResult.INCOMPATIBLE, "Projektformat %d wird nicht unterstützt" % format_val)

	var scene_model := SceneModel.from_dict(d["scene"])

	var modules_list: Array[String] = []
	var mod_arr := d.get("modules", []) as Array
	for m in mod_arr:
		modules_list.append(str(m))

	return CommandResult.success({
		"name": String(d.get("name", "")),
		"scene": scene_model,
		"modules": modules_list
	})
