class_name ScriptHistory
extends RefCounted
## Verlauf von Scriptständen je Datei, nur gültige werden übernommen.

const KEEP := 10
var versions: Dictionary = {}
var last_error: Dictionary = {}


func version_count(path: String) -> int:
	var list: Array = versions.get(path, [])
	return list.size()


func current(path: String) -> String:
	var list: Array = versions.get(path, [])
	if list.is_empty():
		return ""
	return list[list.size() - 1]


func has_error(path: String) -> bool:
	return last_error.has(path)


func revert(path: String) -> bool:
	var list: Array = versions.get(path, [])
	if list.size() < 2:
		return false
	list.pop_back()
	versions[path] = list
	return true


func submit(path: String, text: String, ok: bool, error_text: String = "") -> CommandResult:
	if ok:
		var list: Array = versions.get(path, [])
		if list.size() >= KEEP:
			list.pop_front()
		list.append(text)
		versions[path] = list
		last_error.erase(path)
		return CommandResult.success({"path": path, "version": version_count(path)}, "")
	else:
		last_error[path] = error_text
		return CommandResult.error(CommandResult.EXEC_FAILED, \
			"Script %s hat Fehler: %s. Der letzte gültige Stand bleibt aktiv." % [path, error_text], \
			{"restored": current(path)})
