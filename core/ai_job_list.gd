class_name AiJobList
extends RefCounted
## Liste der KI-Aufträge einer Sitzung mit Kennungen, Abbruch und Übersicht.

var jobs: Array[AiJob] = []
var next_no := 1


## Erstellt einen neuen Auftrag mit fortlaufender Kennung und fügt ihn hinzu.
func create(task: String) -> AiJob:
	var job := AiJob.new("ki-%d" % next_no, task)
	next_no += 1
	jobs.append(job)
	return job


## Gibt den Auftrag mit der angegebenen Kennung zurück oder null.
func find(id: String) -> AiJob:
	for job in jobs:
		if job.id == id:
			return job
	return null


## Bricht den Auftrag mit der angegebenen Kennung ab.
func cancel(id: String) -> CommandResult:
	var job := find(id)
	if job == null:
		return CommandResult.error(CommandResult.NOT_FOUND, "Auftrag %s gibt es nicht" % id)

	if not job.cancel():
		return CommandResult.error(CommandResult.CONFLICT, "Auftrag %s ist schon beendet" % id)

	return CommandResult.success({"id": id})


## Gibt alle laufenden Aufträge (noch nicht fertig) in Listenreihenfolge zurück.
func running() -> Array[AiJob]:
	var result: Array[AiJob] = []
	for job in jobs:
		if not job.is_finished():
			result.append(job)
	return result


## Liefert eine Textübersicht aller Aufträge, neueste zuerst.
func lines() -> Array[String]:
	var result: Array[String] = []
	for i in range(jobs.size() - 1, -1, -1):
		var job := jobs[i]
		result.append("%s: %s" % [job.id, job.summary()])
	return result


## Wandelt die Liste in ein Dictionary für JSON-Speicherung um.
func to_dict() -> Dictionary:
	var job_dicts := []
	for job in jobs:
		job_dicts.append(job.to_dict())

	return {"next_no": next_no, "jobs": job_dicts}


## Erstellt eine AiJobList aus einem Dictionary.
static func from_dict(d: Dictionary) -> AiJobList:
	var list := AiJobList.new()
	list.next_no = int(d.get("next_no", 1))

	for job_dict in d.get("jobs", []):
		var job := AiJob.from_dict(job_dict as Dictionary)
		list.jobs.append(job)

	return list
