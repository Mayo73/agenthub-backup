class_name MeetingStatus
extends RefCounted
## Beschreibt, wie es um einen Treffvorschlag steht: kein Vorschlag, wartend, bestätigt oder abgesagt.

enum Stage { NONE, WAITING_FOR_ME, WAITING_FOR_OTHER, CONFIRMED, CANCELLED }


## Status aus Sicht von state.active_id zurückgeben.
static func stage(state: AppState, match_id: String) -> int:
	# Prüfen, ob ein Match existiert
	var match_dict: Dictionary = state.book.get_match(match_id)
	if match_dict.is_empty():
		return Stage.NONE

	# Prüfen, ob überhaupt ein Treffvorschlag existiert
	if not state.meetings.has_meeting(match_id):
		return Stage.NONE

	# Wenn abgesagt → CANCELLED
	if state.meetings.is_cancelled(match_id):
		return Stage.CANCELLED

	# Aktive Person beteiligt?
	var active_id: String = state.active_id
	var other_id: String = state.book.other(match_dict, active_id)
	if other_id == "":
		return Stage.NONE

	# Hat aktive Person zugestimmt?
	if state.meetings.has_approved(match_id, active_id):
		# Aktive Person hat zugestimmt → warten auf andere oder bestätigt
		if state.meeting_confirmed(match_id):
			return Stage.CONFIRMED
		else:
			return Stage.WAITING_FOR_OTHER
	else:
		# Aktive Person hat nicht zugestimmt → wartet auf eigene Zustimmung
		if state.meeting_confirmed(match_id):
			return Stage.CONFIRMED
		else:
			return Stage.WAITING_FOR_ME


## Beschreibenden Text zurückgeben.
static func text(state: AppState, match_id: String) -> String:
	var s: int = stage(state, match_id)

	if s == Stage.NONE:
		return "Noch kein Treffvorschlag."

	if s == Stage.CANCELLED:
		var meeting: Dictionary = state.meetings.get_meeting(match_id)
		var cancelled_by: String = meeting.get("cancelled_by", "")
		if cancelled_by == state.active_id:
			return "Abgesagt von dir."
		else:
			var match_dict: Dictionary = state.book.get_match(match_id)
			var other_name: String = state.book.other(match_dict, state.active_id)
			var other_profile: SparProfile = state.profile(other_name)
			if other_profile != null:
				return "Abgesagt von %s." % other_profile.name
			return "Abgesagt von %s." % cancelled_by

	if s == Stage.WAITING_FOR_ME:
		var match_dict: Dictionary = state.book.get_match(match_id)
		var other_name: String = state.book.other(match_dict, state.active_id)
		var other_profile: SparProfile = state.profile(other_name)
		if other_profile != null:
			return "%s schlägt ein Treffen vor. Stimmst du zu?" % other_profile.name
		return "Noch kein Treffvorschlag."

	if s == Stage.WAITING_FOR_OTHER:
		var match_dict: Dictionary = state.book.get_match(match_id)
		var other_name: String = state.book.other(match_dict, state.active_id)
		var other_profile: SparProfile = state.profile(other_name)
		if other_profile != null:
			return "Wartet auf die Zustimmung von %s." % other_profile.name
		return "Wartet auf die Zustimmung von %s." % other_name

	if s == Stage.CONFIRMED:
		return "Von beiden bestätigt. Die Teilnahme bleibt freiwillig – ihr könnt jederzeit absagen."

	return ""


## Zusammenfassung eines Treffvorschlags als eine Zeile zurückgeben.
static func summary(meeting: Dictionary) -> String:
	if meeting.is_empty():
		return ""

	var place: String = meeting.get("place", "")
	var date: String = meeting.get("date", "")
	var time: String = meeting.get("time", "")
	var form: String = meeting.get("form", "")
	var intensity: String = meeting.get("intensity", "mittel")

	var result: String = "%s · %s, %s Uhr · %s · %s" % [place, date, time, form, intensity]

	var rules: String = meeting.get("rules", "")
	if not rules.is_empty():
		result += "\nRegeln: %s" % rules

	return result


## Prüfen, ob aktive Person den Vorschlag billigen kann.
static func can_approve(state: AppState, match_id: String) -> bool:
	return stage(state, match_id) == Stage.WAITING_FOR_ME and state.can_write(match_id)


## Prüfen, ob der aktive Nutzer den Vorschlag absagen kann.
static func can_cancel(state: AppState, match_id: String) -> bool:
	# Vorschlag existiert und ist nicht abgesagt
	var match_dict2: Dictionary = state.book.get_match(match_id)
	if match_dict2.is_empty():
		return false
	if state.meetings.is_cancelled(match_id):
		return false
	return true
