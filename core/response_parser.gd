class_name ResponseParser
extends RefCounted

## Extrahiert JSON aus Textantworten eines KI-Modells.
## Nur statische Funktionen, reine Logik ohne Engine-Abhängigkeiten.


static func extract_json(text: String) -> Dictionary:
	## Löst den JSON-Befehlsblock aus der Textantwort heraus.
	## Ergebnis: {ok: bool, data: Variant, error: String}
	var result: Dictionary = {"ok": false, "data": null, "error": ""}
	var teil: String

	# Schritt 1: Suchen nach ```json
	if text.contains("```json"):
		var start_pos := text.find("```json") + 7
		teil = text.substr(start_pos)
		var end_pos := teil.find("```")
		if end_pos != -1:
			teil = teil.substr(0, end_pos)
		# Fehlt das Ende: bis zum Textende (pass)
	elif text.contains("{"):
		# Schritt 2: Sonst vom ersten "{" bis zum letzten "}"
		var start_idx := text.find("{")
		var end_idx := text.rfind("}")
		if start_idx == -1 or end_idx == -1 or end_idx <= start_idx:
			return {"ok": false, "data": null, "error": "kein_json"}
		teil = text.substr(start_idx, end_idx - start_idx + 1)
	else:
		return {"ok": false, "data": null, "error": "kein_json"}

	# Schritt 3: JSON parsen
	var json := JSON.new()
	var parsed_text := teil.strip_edges()
	var parse_result := json.parse(parsed_text)

	if parse_result != OK:
		result["ok"] = false
		result["data"] = null
		result["error"] = "ungueltig"
		return result

	# Schritt 4: Prüfen, ob es ein Dictionary ist
	if not typeof(json.data) == TYPE_DICTIONARY:
		result["ok"] = false
		result["data"] = null
		result["error"] = "kein_objekt"
		return result

	result["ok"] = true
	result["data"] = json.data
	result["error"] = ""

	return result
