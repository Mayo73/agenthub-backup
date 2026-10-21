class_name ImportCheck
extends RefCounted
## Statische Prüfung von Dateiformaten für Bild-, Audio- und 3D-Imports.

const FORMATS: Dictionary = {
	"png": "bild",
	"jpg": "bild",
	"jpeg": "bild",
	"webp": "bild",
	"ogg": "audio",
	"wav": "audio",
	"mp3": "audio",
	"glb": "3d",
	"gltf": "3d",
	"obj": "3d"
}


## Art eines Pfads zurückgeben („bild", „audio", „3d" oder „").
static func kind_of(path: String) -> String:
	var endung := path.get_extension().to_lower()
	return FORMATS.get(endung, "")


## Prüfung von Endung und Größe einer Datei.
static func check(path: String, size_bytes: int) -> CommandResult:
	var endung := path.get_extension().to_lower()
	if not FORMATS.has(endung):
		return CommandResult.error(CommandResult.INCOMPATIBLE, "Format .%s wird nicht unterstützt" % endung)
	if size_bytes <= 0:
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Die Datei %s ist leer" % path.get_file())
	var art: String = FORMATS[endung]
	var result_data: Dictionary = {
		"kind": art,
		"extension": endung
	}
	return CommandResult.success(result_data)


## Dateikopf der ersten 4 Bytes prüfen.
static func header_ok(path: String, head: PackedByteArray) -> bool:
	var endung := path.get_extension().to_lower()
	if not FORMATS.has(endung):
		return false
	var expected: Array[int] = []
	if endung == "png":
		expected = [0x89, 0x50, 0x4E, 0x47]
	elif endung == "glb":
		expected = [0x67, 0x6C, 0x54, 0x46]
	elif endung == "ogg":
		expected = [0x4F, 0x67, 0x67, 0x53]
	elif endung == "wav":
		expected = [0x52, 0x49, 0x46, 0x46]
	else:
		return true
	if head.size() < 4:
		return false
	for i in range(4):
		if head[i] != expected[i]:
			return false
	return true


## Textliste der unterstützten Formate gruppieren.
static func supported_text() -> String:
	var result := ""
	# Gruppen in Reihenfolge: Bild, Audio, 3D
	var groups := {"bild": [], "audio": [], "3d": []}
	for endung in FORMATS:
		var art: String = FORMATS[endung]
		if groups.has(art):
			groups[art].append(endung)
	groups["bild"].sort()
	groups["audio"].sort()
	groups["3d"].sort()
	var group_texts: Array[String] = []
	for group in ["bild", "audio", "3d"]:
		if groups[group].size() > 0:
			var title: String = group.capitalize()
			if group == "3d":
				title = "3D"
			var line := "%s: %s" % [title, ", ".join(groups[group])]
			group_texts.append(line)
	result = "; ".join(group_texts)
	return result
