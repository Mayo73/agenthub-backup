class_name PhysicsSettings
extends RefCounted
## Physikparameter des Projekts mit Prüfung, Serialisierung und Befehlsintegration.

var gravity: float = 9.81
var hz: int = 120
var friction: float = 0.5
var bounce: float = 0.0
var layer_names: Array[String] = ["Welt", "Spieler", "Gegner", "Projektile"]


func to_dict() -> Dictionary:
	## Alle Felder als Dictionary.
	return {
		"gravity": gravity,
		"hz": hz,
		"friction": friction,
		"bounce": bounce,
		"layer_names": layer_names.duplicate()
	}


static func from_dict(d: Dictionary) -> PhysicsSettings:
	## Instanz aus Dictionary erstellen; fehlende Felder behalten Standard.
	var settings := PhysicsSettings.new()

	if "gravity" in d:
		settings.gravity = float(d["gravity"])
	if "hz" in d:
		settings.hz = int(d["hz"])
	if "friction" in d:
		settings.friction = float(d["friction"])
	if "bounce" in d:
		settings.bounce = float(d["bounce"])
	if "layer_names" in d:
		settings.layer_names.clear()
		for item in d["layer_names"]:
			settings.layer_names.append(str(item))

	return settings


func validate() -> Array[String]:
	## Prüft alle Werte und gibt Fehlermeldungen zurück (leer bei OK).
	var problems: Array[String] = []

	if gravity < 0.0 or gravity > 100.0:
		problems.append("gravity muss zwischen 0 und 100 liegen")
	if hz < 30 or hz > 480:
		problems.append("hz muss zwischen 30 und 480 liegen")
	if friction < 0.0 or friction > 1.0:
		problems.append("friction muss zwischen 0 und 1 liegen")
	if bounce < 0.0 or bounce > 1.0:
		problems.append("bounce muss zwischen 0 und 1 liegen")
	if layer_names.size() > 32:
		problems.append("höchstens 32 Kollisionsebenen")

	return problems


func apply(changes: Dictionary) -> CommandResult:
	## Änderungen anwenden; unbekannte Schlüssel oder ungültige Werte führen zu INVALID_ARGUMENT.
	# Prüfe auf unbekannte Schlüssel
	for key in changes.keys():
		if not key in to_dict().keys():
			return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Unbekannte Einstellung: %s" % key)

	# Neue Instanz aus geupdatedem Dictionary bauen
	var merged := to_dict().merged(changes, true)
	var copy := from_dict(merged)

	# Prüfe die Kopie
	var problems := copy.validate()
	if not problems.is_empty():
		var msg := "; ".join(problems)
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, msg)

	# Werte übernehmen und Erfolgsresultat zurückgeben
	gravity = copy.gravity
	hz = copy.hz
	friction = copy.friction
	bounce = copy.bounce
	layer_names = copy.layer_names.duplicate()

	return CommandResult.success(to_dict())


static func register_commands(commands: CommandRegistry, settings: PhysicsSettings) -> void:
	## Befehle 'physics.get' und 'physics.set' registrieren.
	commands.register("physics.get",
		"Aktuelle Physikparameter abrufen",
		{},
		func(args: Dictionary) -> CommandResult:
			return CommandResult.success(settings.to_dict()))

	commands.register("physics.set",
		"Physikparameter ändern",
		{"changes": "dict"},
		func(args: Dictionary) -> CommandResult:
			return settings.apply(args["changes"]))
