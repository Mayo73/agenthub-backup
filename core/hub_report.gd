class_name HubReport
extends RefCounted
## Berichtsfunktionen für JobQueue-Aufträge.

const STATE_NAMES := {JobQueue.QUEUED: "wartet", JobQueue.RUNNING: "läuft", JobQueue.DONE: "fertig", JobQueue.FAILED: "fehlgeschlagen", JobQueue.CANCELLED: "abgebrochen"}


static func status_line(job: Dictionary) -> String:
	var id: String = job.get("id", "")
	var kind: String = job.get("kind", "")
	var progress: float = job.get("progress", 0.0)
	var message: String = job.get("message", "")

	var zustandsname: String = STATE_NAMES.get(job.get("state", ""), "unbekannt")

	var proz := int(progress * 100)
	var zeile: String = "%s %s: %s, %d %%" % [id, kind, zustandsname, proz]
	if message != "":
		zeile += " – " + message
	return zeile


static func markdown(job: Dictionary) -> String:
	var id: String = job.get("id", "")
	var kind: String = job.get("kind", "")
	var progress: float = job.get("progress", 0.0)

	var zustandsname: String = STATE_NAMES.get(job.get("state", ""), "unbekannt")

	var zeilen: Array[String] = []
	zeilen.append("# Auftrag " + id)
	zeilen.append("")
	zeilen.append("- Art: " + kind)
	zeilen.append("- Zustand: " + zustandsname)
	zeilen.append("- Fortschritt: %d %%" % int(progress * 100))

	if job.has("error") and job["error"] != "":
		zeilen.append("- Fehler: " + job["error"])

	var result: Dictionary = job.get("result", {})
	if result.size() > 0:
		zeilen.append("")
		zeilen.append("## Ergebnis")
		var schluesseln := result.keys()
		schluesseln.sort()
		for schl in schluesseln:
			var wert: Variant = result[schl]
			zeilen.append("- " + schl + ": " + str(wert))

	return "\n".join(zeilen)


static func files(job: Dictionary) -> Array[String]:
	var result: Dictionary = job.get("result", {})
	if not result.has("files"):
		return []
	var dateien: Variant = result["files"]
	if typeof(dateien) != TYPE_ARRAY:
		return []
	var ergebnis: Array[String] = []
	for eintrag in dateien:
		ergebnis.append(str(eintrag))
	return ergebnis
