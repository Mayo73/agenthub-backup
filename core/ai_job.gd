class_name AiJob
extends RefCounted
## Datenobjekt für einen KI-Auftrag mit Zuständen, Fortschritt und Änderungsverlauf.

## Mögliche Zustände eines KI-Auftrags.
const WAITING := "wartet"
const RUNNING := "läuft"
const DONE := "fertig"
const FAILED := "fehlgeschlagen"
const CANCELLED := "abgebrochen"
const NO_PROVIDER := "kein_provider"

## Eindeutige ID des Auftrags.
var id: String = ""
## Aufgabenbeschreibung in Worten.
var task: String = ""
## Verwendeter KI-Provider.
var provider: String = ""
## Kontext (Liste von Strings).
var context: Array[String] = []
## Aktueller Zustand.
var state: String = WAITING
## Fortschrittswert von 0.0 bis 1.0.
var progress: float = 0.0
## Änderungsverlauf (je {"command": String, "args": Dictionary}).
var changes: Array[Dictionary] = []
## Fehlermeldung bei Fehlern.
var error: String = ""


func _init(job_id: String = "", job_task: String = "") -> void:
	id = job_id
	task = job_task


## Startet den Auftrag mit dem angegebenen Provider.
## Gibt true zurück, wenn erfolgreich gestartet, false sonst.
func start(provider_id: String) -> bool:
	if state != WAITING:
		return false

	if provider_id.is_empty():
		state = NO_PROVIDER
		error = "Kein KI-Modell erreichbar"
		return false

	provider = provider_id
	state = RUNNING
	return true


## Berichtet Fortschritt (0.0 bis 1.0). Nur während RUNNING gültig.
func report(value: float) -> void:
	if state != RUNNING:
		return
	progress = clampf(value, 0.0, 1.0)


## Fügt eine Änderung zum Verlauf hinzu. Nur während RUNNING gültig.
func add_change(command: String, args: Dictionary) -> void:
	if state != RUNNING:
		return
	changes.append({"command": command, "args": args})


## Beendet den Auftrag erfolgreich.
func finish() -> bool:
	if state != RUNNING:
		return false

	state = DONE
	progress = 1.0
	return true


## Markiert den Auftrag als fehlgeschlagen.
func fail(message: String) -> bool:
	if state != RUNNING:
		return false

	state = FAILED
	error = message
	return true


## Breicht den Auftrag ab.
func cancel() -> bool:
	if state == CANCELLED:
		return false

	if state == WAITING or state == RUNNING:
		state = CANCELLED
		return true

	return false


## Gibt true zurück, wenn der Auftrag in einem Endzustand ist.
func is_finished() -> bool:
	return state == DONE or state == FAILED or state == CANCELLED or state == NO_PROVIDER


## Liefert eine zusammenfassende String-Darstellung des Auftrags.
func summary() -> String:
	var result := "%s · %s · %d %% · %d Änderungen" % [task, state, int(progress * 100), changes.size()]
	if not error.is_empty():
		result += " · " + error
	return result


## Wandelt den Auftrag in ein Dictionary für JSON-Speicherung um.
func to_dict() -> Dictionary:
	return {
		"id": id,
		"task": task,
		"provider": provider,
		"context": context,
		"state": state,
		"progress": progress,
		"changes": changes,
		"error": error
	}


## Erstellt einen AiJob aus einem Dictionary.
static func from_dict(d: Dictionary) -> AiJob:
	var job := AiJob.new()
	job.id = d.get("id", "")
	job.task = d.get("task", "")
	job.provider = d.get("provider", "")

	var ctx: Array[String] = []
	for item in d.get("context", []):
		ctx.append(str(item))
	job.context = ctx

	job.state = d.get("state", WAITING)
	job.progress = float(d.get("progress", 0.0))

	var chgs: Array[Dictionary] = []
	for change in d.get("changes", []):
		chgs.append(change as Dictionary)
	job.changes = chgs

	job.error = d.get("error", "")
	return job
