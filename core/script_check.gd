class_name ScriptCheck
extends RefCounted
## Prüft Scriptentwürfe vor der Übernahme: erst einfache Regeln mit Zeilennummer,
## dann übersetzt Godot den Quelltext im Speicher.

const BLOCK_STARTS: Array[String] = ["func ", "if ", "elif ", "else", "for ", "while ", "match "]
const PAIRS: Array[String] = ["()", "[]", "{}"]

## Zuletzt erfolgreich übernommener Quelltext.
var last_good := ""


## Einfache Regeln ohne Godot: Einrückung, fehlende Doppelpunkte, Klammern.
static func quick_problems(source: String) -> Array[String]:
	var problems: Array[String] = []
	var lines: PackedStringArray = source.split("\n")
	var counts: Dictionary = {}
	for pair in PAIRS:
		counts[pair] = 0
	for i in lines.size():
		var line: String = lines[i].trim_suffix("\r")
		var no: int = i + 1
		if line.begins_with(" "):
			problems.append("Zeile %d: mit Tabs einrücken, nicht mit Leerzeichen" % no)
		var code: String = _without_comment(line)
		var stripped: String = code.strip_edges()
		for start in BLOCK_STARTS:
			if stripped.begins_with(start) and not stripped.ends_with(":"):
				problems.append("Zeile %d: Doppelpunkt fehlt" % no)
				break
		for pair in PAIRS:
			var n: int = counts[pair]
			counts[pair] = n + code.count(pair[0]) - code.count(pair[1])
	for pair in PAIRS:
		var n: int = counts[pair]
		if n != 0:
			problems.append("Klammern sind nicht ausgeglichen")
			break
	return problems


## Prüft den Quelltext vollständig, ohne ihn zu übernehmen.
static func check(source: String) -> CommandResult:
	if source.strip_edges().is_empty():
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Das Script ist leer")
	var problems: Array[String] = quick_problems(source)
	if not problems.is_empty():
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, "; ".join(problems), {"problems": problems})
	var s := GDScript.new()
	s.source_code = source
	if s.reload() != OK:
		return CommandResult.error(CommandResult.EXEC_FAILED, "Das Script enthält Fehler und wurde nicht übernommen")
	return CommandResult.success({"base": String(s.get_instance_base_type())})


## Übernimmt den Quelltext, wenn er gültig ist; sonst bleibt der letzte gültige Stand.
func apply(source: String) -> CommandResult:
	var result: CommandResult = ScriptCheck.check(source)
	if result.is_ok():
		last_good = source
	else:
		result.data["restored"] = last_good
	return result


static func _without_comment(line: String) -> String:
	var pos: int = line.find("#")
	if pos < 0:
		return line
	return line.substr(0, pos)
