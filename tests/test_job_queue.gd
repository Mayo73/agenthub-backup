extends "res://tests/base_test.gd"

var queue: JobQueue


func setup() -> void:
	queue = JobQueue.new()


func test_kennungen() -> void:
	var id1 := queue.submit("export", {"ziel": "a"})
	var id2 := queue.submit("test", {"datei": "b"})

	check_eq(id1, "j1", "Erste Kennung ist j1")
	check_eq(id2, "j2", "Zweite Kennung ist j2")

	var job := queue.get_job(id1)
	check_eq(job["state"], "queued", "Auftrag hat Zustand queued")

	var unknown := queue.get_job("j9")
	check(unknown.is_empty(), "Unbekannter Auftrag ergibt leeres Dictionary")


func test_ablauf() -> void:
	var id := queue.submit("export", {"ziel": "a"})

	check(queue.start(id), "start() erfolgreich für queued Auftrag")

	var success := queue.report(id, 0.5, "Halbzeit")
	check(success, "report() erfolgreich für laufenden Auftrag")

	var job := queue.get_job(id)
	check_eq(job["progress"], 0.5, "Fortschritt ist 0.5")
	check_eq(job["message"], "Halbzeit", "Nachricht ist Halbzeit")

	success = queue.finish(id, {"datei": "x.exe"})
	check(success, "finish() erfolgreich")

	job = queue.get_job(id)
	check_eq(job["state"], "done", "Zustand ist done")
	check_eq(job["progress"], 1.0, "Fortschritt ist 1.0 nach finish")
	check_eq(job["result"]["datei"], "x.exe", "Ergebnis enthält Datei")


func test_fortschritt_begrenzt() -> void:
	var id := queue.submit("export", {"ziel": "a"})
	queue.start(id)

	queue.report(id, 1.7, "")
	var job := queue.get_job(id)
	check_eq(job["progress"], 1.0, "Fortschritt wird auf 1.0 begrenzt")

	queue.report(id, -1.0, "")
	job = queue.get_job(id)
	check_eq(job["progress"], 0.0, "Fortschritt wird auf 0.0 begrenzt")


func test_falsche_reihenfolge() -> void:
	var id := queue.submit("export", {"ziel": "a"})

	# report auf queued-Auftrag sollte nicht funktionieren
	check(not queue.report(id, 0.5, ""), "report() auf queued zurückgegeben false")
	# finish auf queued-Auftrag sollte nicht funktionieren
	check(not queue.finish(id, {"datei": "x.exe"}), "finish() auf queued zurückgegeben false")

	# start zweimal: erst mal erfolgreich
	check(queue.start(id), "erster start() erfolgreich")
	# und nochmal
	check(not queue.start(id), "zweiter start() zurückgegeben false")


func test_abbruch() -> void:
	var id := queue.submit("export", {"ziel": "a"})
	queue.start(id)

	var result := queue.cancel(id)
	check(result.is_ok(), "cancel() erfolgreich für laufenden Auftrag")
	check(queue.is_cancelled(id), "is_cancelled() zurückgegeben true")

	var job := queue.get_job(id)
	check_eq(job["state"], "cancelled", "Zustand ist cancelled")

	# erneuter Aufruf sollte fehlschlagen
	result = queue.cancel(id)
	check(not result.is_ok(), "erneuter cancel() nicht erfolgreich")
	check_eq(result.code, "invalid_argument", "Code ist invalid_argument")
	check("ist schon beendet" in result.message, "Meldung enthält 'schon beendet'")

	# unbekannter Auftrag
	result = queue.cancel("j9")
	check(not result.is_ok(), "cancel() auf unbekannten Auftrag nicht erfolgreich")
	check_eq(result.code, "not_found", "Code ist not_found")


func test_fehler() -> void:
	var id := queue.submit("export", {"ziel": "a"})
	queue.start(id)

	var success := queue.fail(id, "Vorlage fehlt")
	check(success, "fail() erfolgreich für laufenden Auftrag")

	var job := queue.get_job(id)
	check_eq(job["state"], "failed", "Zustand ist failed")
	check_eq(job["error"], "Vorlage fehlt", "Fehlermeldung korrekt gesetzt")


func test_warteschlange() -> void:
	queue.submit("export", {"ziel": "a"})
	var id2 := queue.submit("test", {"datei": "b"})
	queue.submit("export", {"ziel": "c"})

	queue.start("j1")

	check_eq(queue.next_queued(), "j2", "next_queued() gibt j2 zurück")
	check_eq(queue.list("queued").size(), 2, "list('queued') Größe ist 2")
	check_eq(queue.list().size(), 3, "list() ohne Filter Größe ist 3")


func test_kopie() -> void:
	var id := queue.submit("export", {"ziel": "a"})

	var job1 := queue.get_job(id)
	job1["params"]["ziel"] = "b"

	var job2 := queue.get_job(id)
	check_eq(job2["params"]["ziel"], "a", "Änderung an Kopie ändert Original nicht")
