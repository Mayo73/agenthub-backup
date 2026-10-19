class_name JobQueue
extends RefCounted
## Warteschlange für langlaufende Aufträge (Export, Testläufe etc.).
## Reine Logik ohne Threads – Ausführung erfolgt über Callbacks im Hub.

## Zustände als Konstanten
const QUEUED := "queued"
const RUNNING := "running"
const DONE := "done"
const FAILED := "failed"
const CANCELLED := "cancelled"

## jobs: Kennung → Auftrag
var jobs: Dictionary = {}
## Reihenfolge der Aufträge
var order: Array[String] = []
## nächste ID
var next_id := 1


func _create_job(id: String, kind: String, params: Dictionary) -> Dictionary:
	return {
		"id": id,
		"kind": kind,
		"params": params.duplicate(true),
		"state": QUEUED,
		"progress": 0.0,
		"message": "",
		"result": {},
		"error": ""
	}


func submit(kind: String, params: Dictionary) -> String:
	var id := "j%d" % next_id
	next_id += 1

	jobs[id] = _create_job(id, kind, params)
	order.append(id)

	return id


func get_job(id: String) -> Dictionary:
	if not jobs.has(id):
		return {}

	var j: Dictionary = jobs[id]
	return {
		"id": j["id"],
		"kind": j["kind"],
		"params": j["params"].duplicate(true),
		"state": j["state"],
		"progress": j["progress"],
		"message": j["message"],
		"result": j["result"].duplicate(true),
		"error": j["error"]
	}


func next_queued() -> String:
	for id in order:
		if jobs[id]["state"] == QUEUED:
			return id
	return ""


func start(id: String) -> bool:
	if not jobs.has(id):
		return false

	if jobs[id]["state"] != QUEUED:
		return false

	jobs[id]["state"] = RUNNING
	return true


func report(id: String, progress: float, message: String) -> bool:
	if not jobs.has(id):
		return false

	if jobs[id]["state"] != RUNNING:
		return false

	jobs[id]["progress"] = clampf(progress, 0.0, 1.0)
	jobs[id]["message"] = message
	return true


func finish(id: String, result: Dictionary) -> bool:
	if not jobs.has(id):
		return false

	if jobs[id]["state"] != RUNNING:
		return false

	jobs[id]["state"] = DONE
	jobs[id]["progress"] = 1.0
	jobs[id]["result"] = result.duplicate(true)
	return true


func fail(id: String, error: String) -> bool:
	if not jobs.has(id):
		return false

	if jobs[id]["state"] != RUNNING:
		return false

	jobs[id]["state"] = FAILED
	jobs[id]["error"] = error
	return true


func cancel(id: String) -> CommandResult:
	if not jobs.has(id):
		return CommandResult.error(CommandResult.NOT_FOUND, "Auftrag %s gibt es nicht" % id)

	var j: Dictionary = jobs[id]
	if j["state"] in [DONE, FAILED, CANCELLED]:
		return CommandResult.error(CommandResult.INVALID_ARGUMENT, "Auftrag %s ist schon beendet" % id)

	jobs[id]["state"] = CANCELLED
	return CommandResult.success({"id": id})


func is_cancelled(id: String) -> bool:
	if not jobs.has(id):
		return false
	return jobs[id]["state"] == CANCELLED


func list(state_filter: String = "") -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id in order:
		if state_filter != "" and jobs[id]["state"] != state_filter:
			continue

		var j: Dictionary = jobs[id]
		result.append({
			"id": j["id"],
			"kind": j["kind"],
			"params": j["params"].duplicate(true),
			"state": j["state"],
			"progress": j["progress"],
			"message": j["message"],
			"result": j["result"].duplicate(true),
			"error": j["error"]
		})

	return result
