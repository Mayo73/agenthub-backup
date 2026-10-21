extends "res://tests/base_test.gd"


func setup() -> void:
	pass


func teardown() -> void:
	pass


## Test: vollständiger Ablauf eines KI-Auftrags.
func test_ablauf() -> void:
	var job: AiJob = AiJob.new("k1", "Spielfigur anlegen")

	var started: bool = job.start("ollama")
	check(started, "start() sollte true zurückgeben")

	job.report(0.5)
	job.add_change("scene.add", {"type": "Node2D"})
	job.finish()

	check_eq(job.state, AiJob.DONE, "state sollte 'fertig' sein")
	check_eq(job.progress, 1.0, "progress sollte 1.0 sein nach finish()")
	check_eq(job.changes.size(), 1, "changes.size() sollte 1 sein")


## Test: Starten ohne Provider.
func test_ohne_provider() -> void:
	var job: AiJob = AiJob.new("k2", "Figur löschen")

	var started: bool = job.start("")
	check(not started, "start('') sollte false zurückgeben")
	check_eq(job.state, AiJob.NO_PROVIDER, "state sollte NO_PROVIDER sein")
	check(not job.summary().is_empty(), "summary() sollte nicht leer sein")
	check("Kein KI-Modell erreichbar" in job.summary(), "summary() sollte Fehlermeldung enthalten")


## Test: Abbruch eines laufenden Auftrags.
func test_abbruch() -> void:
	var job: AiJob = AiJob.new("k3", "Test abbrechen")

	job.start("ollama")
	var cancelled: bool = job.cancel()
	check(cancelled, "cancel() sollte true zurückgeben nach start()")
	check(job.is_finished(), "is_finished() sollte true sein nach cancel()")

	## Danach sollte finish() nicht funktionieren.
	var finished: bool = job.finish()
	check(not finished, "finish() sollte false zurückgeben nach cancel()")


## Test: Fortschrittsgrenzen.
func test_fortschritt_begrenzt() -> void:
	var job: AiJob = AiJob.new("k4", "Fortschritt begrenzen")

	## report(3.0) im Lauf sollte auf 1.0 geklumpt werden.
	job.start("ollama")
	job.report(3.0)
	check_eq(job.progress, 1.0, "progress sollte nach report(3.0) = 1.0 sein")

	## Neuanlage: progress vor start ändert nichts.
	var job2: AiJob = AiJob.new("k5", "Fortschritt vor start")
	job2.report(0.5)
	check_eq(job2.progress, 0.0, "progress sollte 0.0 bleiben bei report() vor start()")


## Test: Speichern und Laden.
func test_speichern() -> void:
	var job: AiJob = AiJob.new("k6", "Beispiel task")
	job.start("ollama")
	job.report(0.75)
	job.add_change("scene.add", {"type": "Node2D"})

	var saved: Dictionary = job.to_dict()
	var restored: AiJob = AiJob.from_dict(saved)

	check_eq(restored.task, job.task, "task sollte gleich sein")
	check_eq(restored.state, job.state, "state sollte gleich sein")
	check_eq(restored.progress, job.progress, "progress sollte gleich sein")
	check_eq(restored.changes.size(), job.changes.size(), "changes.size() sollte gleich sein")
