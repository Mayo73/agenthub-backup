class_name MeetingBook
extends RefCounted
## Verwaltung von Treffvorschlägen für Matches. Pro Match gibt es höchstens einen Vorschlag,
## der erst bestätigt ist, wenn beide zugestimmt haben. Jede Änderung setzt die Zustimmung zurück.

const FORMS: Array[String] = ["Techniktraining", "Drills", "Leichtes Sparring", "Konditionstraining"]
const INTENSITIES: Array[String] = ["locker", "mittel", "intensiv"]

var meetings: Dictionary = {}


## Gibt eine Liste der fehlenden/ungültigen Felder zurück, sortiert in festgelegter Reihenfolge.
static func missing_fields(details: Dictionary) -> Array[String]:
	var problems: Array[String] = []

	# Ort: leer nach strip_edges()
	if details.get("place", "").strip_edges().is_empty():
		problems.append("Ort fehlt")

	# Datum: muss TT.MM.JJJJ passen
	if not _matches_pattern(details.get("date", ""), "^[\\d]{2}\\.[\\d]{2}\\.[\\d]{4}$"):
		problems.append("Datum fehlt oder ist ungültig (TT.MM.JJJJ)")

	# Uhrzeit: muss HH:MM passen
	if not _matches_pattern(details.get("time", ""), "^([01]\\d|2[0-3]):[0-5]\\d$"):
		problems.append("Uhrzeit fehlt oder ist ungültig (HH:MM)")

	# Trainingsform: muss in FORMS sein
	if not FORMS.has(details.get("form", "")):
		problems.append("Trainingsform fehlt")

	return problems


## Hilfsfunktion: prüft RegEx-Muster.
static func _matches_pattern(value: String, pattern: String) -> bool:
	var re := RegEx.new()
	re.compile(pattern)
	return re.search(value) != null


## Prüfen, ob ein Treffvorschlag existiert.
func has_meeting(match_id: String) -> bool:
	return meetings.has(match_id)


## Erstellt einen Treffvorschlag für ein Match.
## Falls etwas fehlt, passiert nichts und die Fehlerliste wird zurückgegeben.
## Andernfalls wird der Vorschlag gespeichert (ersetzt bestehenden), approved = [by_id], cancelled_by = "".
func propose(match_id: String, by_id: String, details: Dictionary) -> Array[String]:
	var missing: Array[String] = missing_fields(details)
	if not missing.is_empty():
		return missing

	var place: String = details.get("place", "").strip_edges()
	var date: String = details.get("date", "").strip_edges()
	var time: String = details.get("time", "").strip_edges()
	var form: String = details.get("form", "")

	var intensity: String = "mittel"
	if details.has("intensity") and INTENSITIES.has(details["intensity"]):
		intensity = details["intensity"]

	var rules: String = ""
	if details.has("rules"):
		rules = str(details["rules"]).strip_edges()

	meetings[match_id] = {
		"place": place,
		"date": date,
		"time": time,
		"form": form,
		"intensity": intensity,
		"rules": rules,
		"approved": [by_id],
		"cancelled_by": ""
	}

	return []


## Gibt den Vorschlag für ein Match zurück oder { }.
func get_meeting(match_id: String) -> Dictionary:
	if meetings.has(match_id):
		return meetings[match_id]
	return {}


## Fügt user_id zur approved-Liste hinzu (keine Doppelten), nur wenn Vorschlag existiert und nicht abgesagt ist.
func approve(match_id: String, user_id: String) -> void:
	if not meetings.has(match_id):
		return
	var meeting: Dictionary = meetings[match_id]
	if not meeting["cancelled_by"].is_empty():
		return

	if not meeting["approved"].has(user_id):
		meeting["approved"].append(user_id)


## Prüft, ob der Vorschlag bestätigt ist (beide zugestimmt) und nicht abgesagt.
func is_confirmed(match_id: String, a_id: String, b_id: String) -> bool:
	if not meetings.has(match_id):
		return false
	var meeting: Dictionary = meetings[match_id]
	if not meeting["cancelled_by"].is_empty():
		return false
	return meeting["approved"].has(a_id) and meeting["approved"].has(b_id)


## Prüft, ob user_id dem Vorschlag zugestimmt hat.
func has_approved(match_id: String, user_id: String) -> bool:
	if not meetings.has(match_id):
		return false
	var meeting: Dictionary = meetings[match_id]
	if not meeting["cancelled_by"].is_empty():
		return false
	return meeting["approved"].has(user_id)


## Setzt cancelled_by auf by_id und leert approved. Absage ist jederzeit möglich.
func cancel(match_id: String, by_id: String) -> void:
	if meetings.has(match_id):
		meetings[match_id]["cancelled_by"] = by_id
		meetings[match_id]["approved"] = []


## Prüft, ob der Vorschlag abgesagt wurde.
func is_cancelled(match_id: String) -> bool:
	if not meetings.has(match_id):
		return false
	return not meetings[match_id]["cancelled_by"].is_empty()


## Gibt alle Meetings als Dictionary zurück.
func to_dict() -> Dictionary:
	return {"meetings": meetings}


## Erstellt eine MeetingBook-Instanz aus einem Dictionary.
static func from_dict(d: Dictionary) -> MeetingBook:
	var book := MeetingBook.new()
	book.meetings = d.get("meetings", {}).duplicate(true)
	return book
