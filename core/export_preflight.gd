class_name ExportPreflight
extends RefCounted
## Prüft die Voraussetzungen für einen Windows-Export.

const TEMPLATE_FILES: Array[String] = ["windows_release_x86_64.exe", "windows_debug_x86_64.exe"]

var guard: PathGuard
var templates_dir: String


func _init(path_guard: PathGuard, templates: String) -> void:
	guard = path_guard
	templates_dir = templates


static func default_templates_dir() -> String:
	var info: Dictionary = Engine.get_version_info()
	var major: int = info["major"]
	var minor: int = info["minor"]
	var patch: int = info["patch"]
	var status: String = info["status"]
	var version := "%d.%d.%d.%s" % [major, minor, patch, status]
	return OS.get_data_dir().path_join("Godot/export_templates").path_join(version)


func problems(output_path: String) -> Array[String]:
	var errs: Array[String] = []

	# Fehlende Vorlagen-Dateien prüfen
	for datei in TEMPLATE_FILES:
		if not FileAccess.file_exists(templates_dir.path_join(datei)):
			errs.append("Exportvorlage fehlt: %s" % datei)

	# Zielpfad nicht erlaubt
	if not guard.is_allowed(output_path):
		errs.append("Zielpfad ist nicht erlaubt: %s" % PathGuard.normalize(output_path))

	# Endung nicht .exe
	if output_path.get_extension().to_lower() != "exe":
		errs.append("Die Zieldatei muss auf .exe enden")

	return errs


func check(output_path: String) -> CommandResult:
	var problem_list := problems(output_path)
	if problem_list.is_empty():
		return CommandResult.success({"output": PathGuard.normalize(output_path)})
	else:
		var result := CommandResult.error(CommandResult.DEPENDENCY, "Export nicht möglich")
		result.data = {"problems": problem_list}
		return result
