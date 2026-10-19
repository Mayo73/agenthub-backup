class_name PathGuard
extends RefCounted
## Prüft, ob ein Pfad in erlaubten Projekt- oder Ausgabeordnern liegt.
## Speichern und Export schreiben nur in erlaubte Orte.

var roots: Array[String] = []


## Normalisiert einen Pfad: Backslashes zu Slashes, simplify_path(), Laufwerksbuchstaben klein,
## abschließenden Slash entfernen (außer bei ://).
static func normalize(path: String) -> String:
	path = path.replace("\\", "/")
	path = simplify_path(path)
	# Laufwerkserkennung: zweites Zeichen ist ':'
	if path.length() >= 2 and path[1] == ":":
		path = path[0].to_lower() + path.substr(1)
	# Abschließenden Slash entfernen, außer bei ://
	if path.ends_with("://"):
		pass
	elif path.ends_with("/"):
		path = path.rstrip("/")
	return path


static func simplify_path(path: String) -> String:
	var parts := Array(path.split("/", false))
	var result: Array[String] = []
	for part in parts:
		if part.is_empty() or part == ".":
			continue
		elif part == "..":
			if result.size() > 0 and result[-1] != "..":
				result.pop_back()
			elif not path.begins_with("/"):
				result.append("..")
		else:
			result.append(part)
	return "/".join(result)


## Fügt einen erlaubten Wurzel-Pfad hinzu.
func add_root(path: String) -> void:
	roots.append(normalize(path))


## Prüft, ob ein Pfad in einer der erlaubten Wurzeln liegt.
func is_allowed(path: String) -> bool:
	var normalized := normalize(path)
	for root in roots:
		if normalized == root:
			return true
		if normalized.begins_with(root + "/"):
			return true
	return false


## Prüft einen Pfad und gibt ein CommandResult zurück.
func check(path: String) -> CommandResult:
	var normalized := normalize(path)
	if is_allowed(normalized):
		return CommandResult.success({"path": normalized})
	return CommandResult.error(CommandResult.FORBIDDEN_PATH, "Pfad liegt außerhalb der erlaubten Orte: %s" % normalized)
