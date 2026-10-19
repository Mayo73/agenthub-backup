@tool
class_name CliParser
extends RefCounted

## Zerlegt CLI-Argumente in Befehl und Parameter.
## Nur statische Funktionen, reine Logik ohne Engine-Abhängigkeiten.


static func parse_value(text: String) -> Variant:
	## Parses a single argument value into an appropriate variant type.
	if text == "true":
		return true
	elif text == "false":
		return false
	elif text == "null":
		return null

	# Ganzzahl prüfen
	if text.is_valid_int():
		return int(text)

	# Kommazahl mit Punkt prüfen
	if text.is_valid_float():
		return float(text)

	# JSON-Objekt oder Array
	if text.begins_with("{") or text.begins_with("["):
		# Prüfen ob es ein plausibles JSON sein könnte:
		# - "{" muss gefolgt von " oder Zahl oder n/t/f für null/true/false
		# - "[" kann mit beliebtem Wert beginnen
		var valid_start := false
		if text.begins_with("{"):
			var idx := 1
			while idx < text.length() and (text[idx] == " " or text[idx] == "\t"):
				idx += 1
			if idx < text.length():
				var c := text[idx]
				valid_start = (c == "\"") or (c >= "0" and c <= "9") or (c == "-" and idx + 1 < text.length() and text[idx + 1] >= "0" and text[idx + 1] <= "9") or (c in ["n", "t", "f"])
		elif text.begins_with("["):
			valid_start = true  # Arrays können alles enthalten

		if valid_start:
			var parsed_result: Variant = JSON.parse_string(text)
			if parsed_result is Array or parsed_result is Dictionary:
				return parsed_result

	# String in Anführungszeichen
	if text.length() >= 2 and text.begins_with("\"") and text.ends_with("\""):
		return text.substr(1, text.length() - 2)

	# Sonst Text unverändert
	return text


static func parse(argv: PackedStringArray) -> Dictionary:
	## Zerlegt Argumentliste in Befehl und Parameter-Dictionary.
	var result: Dictionary = {"command": "", "args": {}, "error": ""}

	# Leere Liste -> kein Befehl
	if argv.is_empty():
		result["error"] = "Kein Befehl angegeben"
		return result

	# Erster Teil ist der Befehlsname
	var command: String = argv[0]
	result["command"] = command

	# Check ob erster Element '=' enthält (Fehler)
	if "=" in command:
		result["error"] = "Erst den Befehl nennen, dann Parameter"
		return result

	# Restliche Elemente sind Parameter
	for i in range(1, argv.size()):
		var arg: String = argv[i]

		# Leerer Parameter ist gültig (name="")
		if arg.is_empty():
			continue

		# Trennung am ersten '='
		var eq_pos: int = arg.find("=")
		if eq_pos == -1:
			result["error"] = "Parameter ohne '=': %s" % arg
			return result

		var name: String = arg.substr(0, eq_pos)
		var value: String = arg.substr(eq_pos + 1)

		# Leerer Parametername -> Fehler
		if name.is_empty():
			result["error"] = "Parametername fehlt"
			return result

		# Doppelter Name -> Fehler
		if result["args"].has(name):
			result["error"] = "Parameter doppelt: %s" % name
			return result

		# Wert parsen (empty value wird "")
		var parsed_value: Variant = parse_value(value)
		result["args"][name] = parsed_value

	return result
