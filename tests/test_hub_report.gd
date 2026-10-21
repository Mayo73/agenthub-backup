extends "res://tests/base_test.gd"

var queue: JobQueue
var id: String


func setup() -> void:
	queue = JobQueue.new()
	id = queue.submit("export", {"ziel": "windows"})


func test_status() -> void:
	queue.start(id)
	queue.report(id, 0.4, "Packe Dateien")

	var zeile: String = HubReport.status_line(queue.get_job(id))
	check(zeile.contains("export"), "status_line enthält Auftragstyp 'export'")
	check(zeile.contains("läuft"), "status_line enthält Zustand 'läuft'")
	check(zeile.contains("40 %"), "status_line enthält Fortschritt '40 %%'")
	check(zeile.contains("Packe Dateien"), "status_line enthält Nachricht 'Packe Dateien'")


func test_bericht_fertig() -> void:
	queue.start(id)
	queue.finish(id, {"files": ["build/spiel.exe"], "dauer": 12})

	var md: String = HubReport.markdown(queue.get_job(id))
	check(md.contains("# Auftrag "), "markdown enthält Überschrift")
	check(md.contains("- Zustand: fertig"), "markdown enthält Zustand 'fertig'")
	check(md.contains("## Ergebnis"), "markdown enthält Abschnitt '## Ergebnis'")
	check(md.contains("- dauer: 12"), "markdown enthält Ergebnis 'dauer: 12'")

	var dateien: Array[String] = HubReport.files(queue.get_job(id))
	check_eq(dateien, ["build/spiel.exe"], "files gibt Exportdatei zurück")


func test_fehler() -> void:
	queue.start(id)
	queue.fail(id, "Vorlage fehlt")

	var md: String = HubReport.markdown(queue.get_job(id))
	check(md.contains("- Fehler: Vorlage fehlt"), "markdown enthält Fehlernachricht")

	var dateien: Array[String] = HubReport.files(queue.get_job(id))
	check_eq(dateien, [], "files ist leer bei Fehler")
