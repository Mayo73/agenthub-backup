class_name AssetLibrary
extends RefCounted
## Asset-Bibliothek für 2D-Arbeitsablauf: erkennt Dateien nach Format und verwaltet Assets.

const FORMATS := {"png": "bild", "jpg": "bild", "webp": "bild", "ogg": "audio", "wav": "audio", "mp3": "audio", "glb": "modell", "gltf": "modell"}

var assets: Dictionary = {}  # Kennung -> {"id", "path", "kind", "name"}
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

	for asset: Dictionary in assets.values():
		if asset["path"] == path:
			return CommandResult.error(CommandResult.CONFLICT, "Asset %s ist schon vorhanden" % path)

	var id: String = "a%d" % next_id
	next_id += 1

	if name == "":
		name = path.get_file().get_basename()

	assets[id] = {"id": id, "path": path, "kind": art, "name": name}
	return CommandResult.success({"id": id, "kind": art})


func remove(id: String) -> bool:
	return assets.erase(id)


func list(kind: String = "") -> Array[Dictionary]:
	var ergebnis: Array[Dictionary] = []
	for asset: Dictionary in assets.values():
		if kind != "" and asset["kind"] != kind:
			continue
		ergebnis.append(asset.duplicate())

	ergebnis.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(str(a["id"]).substr(1)) < int(str(b["id"]).substr(1)))
	return ergebnis


func find(text: String) -> Array[String]:
	var ergebnis: Array[String] = []
	for asset: Dictionary in list():
		var name: String = asset["name"]
		if text == "" or name.findn(text) >= 0:
			ergebnis.append(asset["id"])
	return ergebnis


func clear_all() -> void:
	assets.clear()


static func supported_text() -> String:
	return "Bilder: png, jpg, webp · Audio: ogg, wav, mp3 · Modelle: glb, gltf"
