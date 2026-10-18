class_name AppState
extends RefCounted
## Hält den gesamten Zustand der App: Profile, Matches, Chat und Treffen.
## Weiß aus wessen Perspektive die App gerade bedient wird.

var profiles: Array[SparProfile] = []
var active_id := "p01"
var book := MatchBook.new()
var chat := ChatLog.new()
var meetings := MeetingBook.new()


## Demo-Zustand mit 8 Testpersonen zurückgeben
static func demo() -> AppState:
	var state := AppState.new()
	state.profiles = DemoData.profiles()
	state.active_id = "p01"
	return state


## Profil mit dieser ID zurückgeben oder null
func profile(id: String) -> SparProfile:
	for p in profiles:
		if p.id == id:
			return p
	return null


## Aktives Profil zurückgeben
func active() -> SparProfile:
	return profile(active_id)


## Alle IDs der Profile zurückgeben
func all_ids() -> Array[String]:
	var result: Array[String] = []
	for p in profiles:
		result.append(p.id)
	return result


## Zu aktiver Person wechseln, falls ID existiert; true wenn erfolgreich
func switch_to(id: String) -> bool:
	if profile(id) == null:
		return false
	active_id = id
	return true


## Kandidaten-Profile für die aktive Person zurückgeben
func candidates() -> Array[SparProfile]:
	var candidate_ids := book.candidates(active_id, all_ids())
	var result: Array[SparProfile] = []
	for id in candidate_ids:
		var p := profile(id)
		if p != null:
			result.append(p)
	return result


## Like von aktiver Person zu to_id; Match-ID oder ""
func like(to_id: String) -> String:
	return book.like(active_id, to_id)


## Pass/Ignore von aktiver Person zu to_id
func pass_on(to_id: String) -> void:
	book.pass_on(active_id, to_id)


## Matches der aktiven Person zurückgeben, ohne blockierte Personen (außer bei beendeten Matches)
func my_matches() -> Array[Dictionary]:
	var matches := book.matches_of(active_id)
	var result: Array[Dictionary] = []

	for m in matches:
		var other_id := book.other(m, active_id)
		# Prüfen, ob aktive_id die andere Person blockiert hat oder umgekehrt
		var active_blocks_other := book.blocks.has(MatchBook.key(active_id, other_id))
		var other_blocks_active := book.blocks.has(MatchBook.key(other_id, active_id))
		var blocked := active_blocks_other or other_blocks_active

		# Beendete Matches bleiben sichtbar
		if blocked and m["ended_by"] == "":
			continue
		result.append(m)

	return result


## Kann aktive Person in diesem Match schreiben? (Match existiert, beteiligt und aktiv)
func can_write(match_id: String) -> bool:
	var m := book.get_match(match_id)
	if m.is_empty():
		return false
	if m["a"] != active_id and m["b"] != active_id:
		return false
	if not book.is_active(match_id):
		return false
	return true


## Nachricht senden, falls can_write; sonst false
func send_message(match_id: String, text: String) -> bool:
	if not can_write(match_id):
		return false
	return chat.send(match_id, active_id, text)


## Treffvorschlag erstellen; bei beendetem Match ["Match ist beendet"], sonst Ergebnis von meetings.propose()
func propose_meeting(match_id: String, details: Dictionary) -> Array[String]:
	if not can_write(match_id):
		return ["Match ist beendet"]
	return meetings.propose(match_id, active_id, details)


## Treffen bestätigen (nur wenn can_write)
func approve_meeting(match_id: String) -> void:
	if not can_write(match_id):
		return
	meetings.approve(match_id, active_id)


## Treffen absagen (auch bei beendetem Match erlaubt, wenn aktive Person beteiligt)
func cancel_meeting(match_id: String) -> void:
	var m := book.get_match(match_id)
	if m.is_empty():
		return
	if m["a"] != active_id and m["b"] != active_id:
		return
	meetings.cancel(match_id, active_id)


## Prüfen, ob Treffen bestätigt ist (beide Personen zugestimmt und nicht abgesagt)
func meeting_confirmed(match_id: String) -> bool:
	var m := book.get_match(match_id)
	if m.is_empty():
		return false
	var a_id: String = m["a"]
	var b_id: String = m["b"]
	return meetings.is_confirmed(match_id, a_id, b_id)


## Match beenden (aktive Person muss beteiligt sein); offener Treffvorschlag wird abgesagt
func end_match(match_id: String) -> void:
	book.end_match(match_id, active_id)
	# Offenen Treffvorschlag für aktive Person absagen
	var m := book.get_match(match_id)
	if not m.is_empty():
		meetings.cancel(match_id, active_id)


## Andere Person blockieren; gemeinsamen Treffvorschlag wird abgesagt
func block(to_id: String) -> void:
	book.block(active_id, to_id)
	# Treffvorschlag im gemeinsamen Match absagen
	var m := book.match_between(active_id, to_id)
	if not m.is_empty():
		meetings.cancel(m["id"], active_id)


## Profil ändern: ersetzt Profil mit gleicher ID durch Kopie
func update_profile(changed: SparProfile) -> void:
	for i in range(profiles.size()):
		if profiles[i].id == changed.id:
			profiles[i] = changed.duplicate_profile()
			return


## Zustand als Dictionary serialisieren
func to_dict() -> Dictionary:
	var profile_dicts: Array[Dictionary] = []
	for p in profiles:
		profile_dicts.append(p.to_dict())

	return {
		"version": 1,
		"active_id": active_id,
		"profiles": profile_dicts,
		"book": book.to_dict(),
		"chat": chat.to_dict(),
		"meetings": meetings.to_dict()
	}


## AppState aus Dictionary deserialisieren; bei fehlenden Profilen DemoData.profiles() verwenden
static func from_dict(d: Dictionary) -> AppState:
	var state := AppState.new()
	state.active_id = d.get("active_id", "p01")

	var profiles_data: Variant = d.get("profiles")
	if profiles_data == null:
		state.profiles = DemoData.profiles()
	else:
		for pd in profiles_data:
			state.profiles.append(SparProfile.from_dict(pd))

	state.book = MatchBook.from_dict(d.get("book", {}))
	state.chat = ChatLog.from_dict(d.get("chat", {}))
	state.meetings = MeetingBook.from_dict(d.get("meetings", {}))

	return state
