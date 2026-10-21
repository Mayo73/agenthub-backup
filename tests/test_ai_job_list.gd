extends "res://tests/base_test.gd"

var model: AiJobList


func setup() -> void:
	model = AiJobList.new()


func test_kennungen() -> void:
	var job1 := model.create("Erster Auftrag")
	var job2 := model.create("Zweiter Auftrag")

	check_eq(job1.id, "ki-1", "erster Auftrag hat Kennung ki-1")
	check_eq(job2.id, "ki-2", "zweiter Auftrag hat Kennung ki-2")

	check_eq(model.find("ki-2").task, "Zweiter Auftrag", "find(\"ki-2\") liefert richtigen Auftrag")
	check_eq(model.find("ki-9"), null, "find(\"ki-9\") gibt null für unbekannte Kennung")


func test_abbruch() -> void:
	model.create("A")

	var result := model.cancel("ki-1")
	check(result.is_ok(), "cancel(\"ki-1\") ist erfolgreich")
	check_eq(model.find("ki-1").state, AiJob.CANCELLED, "Auftrag nach Abbruch hat Status CANCELLED")

	result = model.cancel("ki-1")
	check_eq(result.code, CommandResult.CONFLICT, "wiederholter Aufruf von cancel liefert CONFLICT")

	result = model.cancel("ki-7")
	check_eq(result.code, CommandResult.NOT_FOUND, "cancel nicht existierender Auftrag liefert NOT_FOUND")


func test_laufend() -> void:
	model.create("Auftrag 1")
	model.create("Auftrag 2")
	model.create("Auftrag 3")

	var job := model.find("ki-2")
	check(job.start("ollama"), "Start von Auftrag ki-2 erfolgreich")
	job.finish()

	check_eq(model.running().size(), 2, "running() liefert 2 nicht-beendete Aufträge")


func test_zeilen() -> void:
	model.create("Erster Auftrag")
	model.create("Zweiter Auftrag")

	var lines: Array[String]
	lines = model.lines()
	check(lines[0].begins_with("ki-2: "), "lines()[0] beginnt mit ki-2: ")


func test_speichern() -> void:
	model.create("Auftrag A")
	model.create("Auftrag B")

	var dict := model.to_dict()
	var restored := AiJobList.from_dict(dict)

	check_eq(restored.jobs.size(), 2, "from_dict liefert 2 Aufträge")
	check_eq(restored.next_no, 3, "next_no ist 3 nach zwei Erstellungen")

	model = restored
	var job := model.create("Dritter Auftrag")
	check_eq(job.id, "ki-3", "neuer Auftrag erhält Kennung ki-3")
