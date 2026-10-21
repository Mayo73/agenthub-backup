extends "res://tests/base_test.gd"

var registry: CommandRegistry
var model: SceneModel
var job: AiJob


func setup() -> void:
	registry = CommandRegistry.new()
	model = SceneModel.new()
	SceneCommands.register_all(registry, model)
	job = AiJob.new("k1", "Test")
	job.start("ollama")


func test_erfolg() -> void:
	var answer := "[{\"command\": \"scene.add\", \"args\": {\"type\": \"Node2D\", \"parent\": \"\", \"props\": {}}}]"
	var ergebnis := AiJobRunner.apply(job, registry, answer)

	check(ergebnis.is_ok(), "Antwort erfolgreich")
	check_eq(job.state, AiJob.DONE, "job.state DONE")
	check_eq(job.changes.size(), 1, "eine Änderung im Verlauf")
	check_eq(model.order.size(), 1, "ein Objekt in der Szene")
	check_eq(job.progress, 1.0, "Fortschritt 100%")


func test_kein_plan() -> void:
	var answer := "Ich weiß nicht"
	var ergebnis := AiJobRunner.apply(job, registry, answer)

	check(not ergebnis.is_ok(), "Antwort nicht erfolgreich")
	check_eq(job.state, AiJob.FAILED, "job.state FAILED")
	check(not job.error.is_empty(), "Fehlermeldung vorhanden")


func test_unbekannter_befehl() -> void:
	var answer := "[{\"command\": \"zaubern\", \"args\": {}}, {\"command\": \"scene.add\", \"args\": {\"type\": \"Node2D\", \"parent\": \"\", \"props\": {}}}]"
	var ergebnis := AiJobRunner.apply(job, registry, answer)

	check(not ergebnis.is_ok(), "Antwort nicht erfolgreich")
	check_eq(job.state, AiJob.FAILED, "job.state FAILED")
	check_eq(model.order.size(), 0, "nichts ausgeführt")


func test_nicht_gestartet() -> void:
	var neuer_job := AiJob.new("k2", "Test2")
	var answer := "[{\"command\": \"scene.add\", \"args\": {\"type\": \"Node2D\", \"parent\": \"\", \"props\": {}}}]"

	check_eq(neuer_job.state, AiJob.WAITING, "neuer Job WAITING")

	var ergebnis := AiJobRunner.apply(neuer_job, registry, answer)

	check(not ergebnis.is_ok(), "Antwort nicht erfolgreich")
	check_eq(ergebnis.code, CommandResult.CONFLICT, "Code CONFLICT")
	check_eq(neuer_job.state, AiJob.WAITING, "state bleibt WAITING")


func test_leerer_plan() -> void:
	var answer: String = "[]"
	var ergebnis := AiJobRunner.apply(job, registry, answer)

	check(ergebnis.is_ok(), "Leerer Plan erfolgreich")
	check_eq(job.state, AiJob.DONE, "job.state DONE")
	check_eq(job.changes.size(), 0, "keine Änderungen")
	check_eq(job.progress, 1.0, "Fortschritt 100%")
