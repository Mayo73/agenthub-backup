class_name ModuleLoader
extends RefCounted
## Statische Funktionen zum Laden von Modulen aus `modules/`-Ordner.

static func read_manifest(path: String) -> CommandResult:
	if not FileAccess.file_exists(path):
		return CommandResult.error(CommandResult.NOT_FOUND, "Manifest fehlt: %s" % path)
	var datei := FileAccess.open(path, FileAccess.READ)
	var inhalt := datei.get_as_text()
	datei.close()
	var parsed: Variant = JSON.parse_string(inhalt)
	if not typeof(parsed) == TYPE_DICTIONARY:
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Manifest ist kein gültiges JSON: %s" % path)
	var manifest := ModuleManifest.from_dict(parsed)
	return CommandResult.success({"manifest": manifest})


static func load_dir(dir_path: String, registry: ModuleRegistry) -> Array[String]:
	var ergebnis: Array[String] = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return ergebnis
	var directories: PackedStringArray = DirAccess.get_directories_at(dir_path)
	directories.sort()
	for ordner in directories:
		var manifest_pfad := dir_path + "/" + ordner + "/manifest.json"
		var resultat := read_manifest(manifest_pfad)
		if not resultat.is_ok():
			ergebnis.append("%s: %s" % [ordner, resultat.message])
		else:
			var manifest := resultat.data.get("manifest") as ModuleManifest
			var lade_resultat := registry.add(manifest)
			if lade_resultat.is_ok():
				ergebnis.append("%s: geladen" % manifest.id)
			else:
				ergebnis.append("%s: %s" % [ordner, lade_resultat.message])
	return ergebnis
