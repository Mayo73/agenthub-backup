class_name AiJobRunner
extends RefCounted
## Führt Befehlspläne aus KI-Antworten als Auftrag aus.

## Führt eine KI-Antwort als Befehlsplan für einen Auftrag aus.
static func apply(job: AiJob, registry: CommandRegistry, answer: String) -> CommandResult:
	# Prüfe ob Auftrag läuft
	if job.state != AiJob.RUNNING:
		return CommandResult.error(CommandResult.CONFLICT, "Auftrag läuft nicht")

	# Parsen des Plans
	var ergebnis := CommandPlan.parse(answer)
	if not ergebnis.is_ok():
		job.fail(ergebnis.message)
		return ergebnis

	# Schrittweise Array extrahieren und prüfen
	var data := ergebnis.data
	var steps_raw: Array = data.get("steps", [])
	var steps: Array[Dictionary] = []
	for item in steps_raw:
		steps.append(item as Dictionary)

	# Check gegen Registry
	var probleme := CommandPlan.check(registry, steps)
	if not probleme.is_empty():
		var fehlermeldung := "; ".join(probleme)
		job.fail(fehlermeldung)
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, fehlermeldung)

	# Leerer Plan
	if steps.size() == 0:
		job.finish()
		return CommandResult.success({"done": 0}, "0 Befehle ausgeführt")

	# Schritte der Reihe nach ausführen
	for i in steps.size():
		var step: Dictionary = steps[i]
		var cmd_name := step["command"] as String
		var args: Dictionary = step.get("args", {})

		var ergebnis_befehl := registry.execute(cmd_name, args)
		if not ergebnis_befehl.is_ok():
			job.fail("Schritt %d: %s" % [i + 1, ergebnis_befehl.message])
			return CommandResult.error(ergebnis_befehl.code, "Schritt %d: %s" % [i + 1, ergebnis_befehl.message], {"done": i})

		# Erfolg
		job.add_change(cmd_name, args)
		job.report(float(i + 1) / steps.size())

	# Alles gut
	job.finish()
	return CommandResult.success({"done": steps.size()}, "%d Befehle ausgeführt" % steps.size())
