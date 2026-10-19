class_name AssetLibrary
extends RefCounted
## Asset-Bibliothek für 2D-Arbeitsablauf: erkennt Dateien nach Format und verwaltet Assets.

const FORMATS := {"png": "bild", "jpg": "bild", "webp": "bild", "ogg": "audio", "wav": "audio", "mp3": "audio", "glb": "modell", "gltf": "modell"}

var assets: Dictionary = {}
var next_id := 1


static func kind_of(path: String) -> String:
	var endung := path.get_extension().to_lower()
	if FORMATS.has(endung):
		return FORMATS[endung]
	return ""


func add(path: String, name: String = "") -> CommandResult:
	var art := kind_of(path)
	if art == "":
		var endung := path.get_extension().to_lower()
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Format .%s wird nicht unterstützt" % endung)

	if assets.has(path):
		return CommandResult.error(CommandResult.CONFLICT, "Asset %s ist schon vorhanden")

	var id: String = "a%d" % next_id
	next_id += 1

	if name == "":
		name = path.get_file().get_basename()

	assets[path] = {"id": id, "path": path, "kind": art, "name": name}
	return CommandResult.success({"id": id, "kind": art})


func remove(id: String) -> bool:
	for path in assets.keys():
		if assets[path]["id"] == id:
			assets.erase(path)
			return true
	return false


func list(kind: String = "") -> Array[Dictionary]:
	var ergebnis: Array[Dictionary] = []
	for path in assets.keys():
		var asset: Dictionary = assets[path]
		if kind != "" and asset["kind"] != kind:
			continue
		ergebnis.append({"id": asset["id"], "path": asset["path"], "kind": asset["kind"], "name": asset["name"]})

	ergebnis.sort_custom(func(a, b): return int(a.id.substr(1)) < int(b.id.substr(1)))
	return ergebnis


func find(text: String) -> Array[String]:
	var ergebnis: Array[String] = []
	for path in assets.keys():
		var asset: Dictionary = assets[path]
		if text == "" or asset["name"].to_lower().findn(text.to_lower()) >= 0:
			ergebnis.append(asset["id"])

	ergebnis.sort_custom(func(a, b): return int(a.substr(1)) < int(b.substr(1)))
	return ergebnis


func clear_all() -> void:
	assets.clear()


static func supported_text() -> String:
	return "Bilder: png, jpg, webp · Audio: ogg, wav, mp3 · Modelle: glb, gltf"
