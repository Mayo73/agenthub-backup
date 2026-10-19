class_name BehaviorLibrary
extends RefCounted
## Bibliothek fertiger Verhaltensarten mit Parameterbeschreibung und Prüfung.
## Für Editor und Agenten zugänglich über statische Funktionen.


const _BEHAVIORS: Dictionary = {
	"bewegen": {
		"description": "Bewegt das Objekt gleichmäßig.",
		"parameters": {
			"speed": {"type": "number", "min": 0.0, "max": 1000.0, "default": 100.0},
			"direction": {"type": "string", "allowed": ["links", "rechts", "hoch", "runter"], "default": "rechts"}
		}
	},
	"drehen": {
		"description": "Dreht das Objekt dauerhaft.",
		"parameters": {
			"degrees_per_second": {"type": "number", "min": -720.0, "max": 720.0, "default": 90.0}
		}
	},
	"zerstoeren_nach": {
		"description": "Entfernt das Objekt nach einer Zeit.",
		"parameters": {
			"seconds": {"type": "number", "min": 0.1, "max": 600.0, "default": 5.0}
		}
	},
	"spielersteuerung": {
		"description": "Bewegt das Objekt mit den Eingabeaktionen.",
		"parameters": {
			"speed": {"type": "number", "min": 0.0, "max": 1000.0, "default": 200.0},
			"jump": {"type": "bool", "default": false}
		}
	}
}


static func names() -> Array[String]:
	var result: Array[String] = []
	for key in _BEHAVIORS:
		result.append(key)
	result.sort()
	return result


static func description(name: String) -> String:
	if not _BEHAVIORS.has(name):
		return ""
	return _BEHAVIORS[name].description


static func defaults(name: String) -> Dictionary:
	if not _BEHAVIORS.has(name):
		return {}
	var result: Dictionary = {}
	for param_name in _BEHAVIORS[name].parameters:
		result[param_name] = _BEHAVIORS[name].parameters[param_name].default
	return result


static func validate(name: String, params: Dictionary) -> Array[String]:
	var problems: Array[String] = []

	# Prüfen, ob Verhalten existiert
	if not _BEHAVIORS.has(name):
		problems.append("Verhalten %s gibt es nicht" % name)
		return problems

	var allowed_params: Array[String] = []
	for key in _BEHAVIORS[name].parameters:
		allowed_params.append(key)
	allowed_params.sort()

	# Prüfen auf unbekannte Parameter (in sortierter Reihenfolge)
	for param_name in allowed_params:
		if param_name in params:
			continue

	var known_params: Array[String] = []
	for key in _BEHAVIORS[name].parameters:
		known_params.append(key)
	known_params.sort()

	for param_name in params.keys():
		var found := false
		for allowed in known_params:
			if allowed == param_name:
				found = true
				break
		if not found:
			problems.append("Unbekannter Parameter %s" % param_name)

	# Prüfen der vorgesehenen Parameter (in sortierter Reihenfolge)
	for param_name in known_params:
		if not params.has(param_name):
			continue

		var spec = _BEHAVIORS[name].parameters[param_name]
		var value = params[param_name]
		var expected_type = spec.type

		# Typ-Prüfung
		var type_correct := false
		match expected_type:
			"number":
				if typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT:
					type_correct = true
			"string":
				if typeof(value) == TYPE_STRING:
					type_correct = true
			"bool":
				if typeof(value) == TYPE_BOOL:
					type_correct = true

		if not type_correct:
			var type_name := ""
			match expected_type:
				"number":
					type_name = "eine Zahl"
				"string":
					type_name = "ein Text"
				"bool":
					type_name = "wahr oder falsch"
			problems.append("%s muss %s sein" % [param_name, type_name])
			continue

		# Zahlenbereich-Prüfung (nur bei number)
		if expected_type == "number":
			var num_val := float(value)
			if spec.has("min") and num_val < float(spec.min):
				problems.append("%s muss zwischen %s und %s liegen" % [param_name, str(spec.min), str(spec.max)])
				continue
			if spec.has("max") and num_val > float(spec.max):
				problems.append("%s muss zwischen %s und %s liegen" % [param_name, str(spec.min), str(spec.max)])
				continue

		# Spezielle Prüfung für direction
		if param_name == "direction":
			var allowed = spec.allowed if spec.has("allowed") else []
			var valid := false
			for a in allowed:
				if value == a:
					valid = true
					break
			if not valid:
				problems.append("direction muss links, rechts, hoch oder runter sein")

	return problems


static func create(name: String, params: Dictionary) -> CommandResult:
	var problems := validate(name, params)
	if problems.size() > 0:
		var msg := "; ".join(problems)
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, msg)

	var default_params := defaults(name)
	var merged := default_params.merged(params, true)
	return CommandResult.success({"behavior": name, "params": merged})
