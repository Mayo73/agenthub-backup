class_name ExportProfile
extends RefCounted

## Profil für Exporteinstellungen.
var game_name := ""
var output_path := ""
var icon_path := ""

## Überprüft die Einstellungen und gibt eine Liste von Fehlercodes zurück.
func validate(allowed_root: String) -> Array[String]:
	var errors: Array[String] = []

	# name_fehlt
	if game_name.strip_edges() == "":
		errors.append("name_fehlt")

	# pfad_fehlt und abhängige Checks
	if output_path == "":
		errors.append("pfad_fehlt")
	else:
		# keine_exe
		var lower_output := output_path.to_lower()
		if not lower_output.ends_with(".exe"):
			errors.append("keine_exe")
		else:
			# pfad_nicht_erlaubt
			var normalized_path := lower_output.replace("\\", "/")
			if ".." in normalized_path:
				errors.append("pfad_nicht_erlaubt")
			elif not normalized_path.begins_with(allowed_root.to_lower() + "/"):
				errors.append("pfad_nicht_erlaubt")

	# icon_kein_ico
	if icon_path != "" and not icon_path.to_lower().ends_with(".ico"):
		errors.append("icon_kein_ico")

	return errors
