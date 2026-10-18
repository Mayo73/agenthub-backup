extends "res://tests/base_test.gd"

var state: AppState
var match_p01_p02: String


func setup() -> void:
	state = AppState.demo()
	# Match zwischen p01 und p02 erzeugen (als p01)
	state.switch_to("p01")
	match_p01_p02 = state.like("p02")
	state.switch_to("p02")
	state.like("p01")
	# Sicherstellen, dass wir das gleiche Match haben
	if match_p01_p02.is_empty():
		var matches := state.my_matches()
		for m in matches:
			if m["a"] == "p01" and m["b"] == "p02":
				match_p01_p02 = m["id"]
				break
			if m["a"] == "p02" and m["b"] == "p01":
				match_p01_p02 = m["id"]
				break


func teardown() -> void:
	pass


func test_kein_vorschlag() -> void:
	# Als p01, kein Vorschlag existiert
	state.switch_to("p01")
	var stage := MeetingStatus.stage(state, match_p01_p02)
	check_eq(stage, MeetingStatus.Stage.NONE, "stage sollte NONE sein")

	var t := MeetingStatus.text(state, match_p01_p02)
	check_eq(t, "Noch kein Treffvorschlag.", "text sollte 'Noch kein Treffvorschlag.' sein")

	# Als p02
	state.switch_to("p02")
	stage = MeetingStatus.stage(state, match_p01_p02)
	check_eq(stage, MeetingStatus.Stage.NONE, "stage sollte NONE sein als p02")

	t = MeetingStatus.text(state, match_p01_p02)
	check_eq(t, "Noch kein Treffvorschlag.", "text sollte 'Noch kein Treffvorschlag.' sein als p02")


func test_warten() -> void:
	# Als p01 Vorschlag erstellen
	state.switch_to("p01")
	var ok := {"place": "Stadtpark, Wiese am Teich", "date": "24.10.2026", "time": "10:30", "form": "Drills"}
	state.propose_meeting(match_p01_p02, ok)

	var stage := MeetingStatus.stage(state, match_p01_p02)
	check_eq(stage, MeetingStatus.Stage.WAITING_FOR_OTHER, "stage sollte WAITING_FOR_OTHER als p01 sein")

	var t := MeetingStatus.text(state, match_p01_p02)
	# Bei einem Match zwischen p01 und p02: other ist p02 (Sam), active ist p01 (Alex)
	check_eq(t, "Wartet auf die Zustimmung von Sam.", "text sollte 'Wartet auf die Zustimmung von Sam.' sein")

	# Als p01 kann nicht approve (nur WAITING_FOR_OTHER)
	var can := MeetingStatus.can_approve(state, match_p01_p02)
	check(not can, "can_approve als p01 sollte false sein (WAITING_FOR_OTHER)")

	# Als p02 warten
	state.switch_to("p02")
	stage = MeetingStatus.stage(state, match_p01_p02)
	# p02 hat nicht zugestimmt, also WAITING_FOR_ME für p01 (active ist jetzt p02)
	check_eq(stage, MeetingStatus.Stage.WAITING_FOR_ME, "stage sollte WAITING_FOR_ME als p02 sein")

	t = MeetingStatus.text(state, match_p01_p02)
	# other ist p01 (Alex), active ist p02 (Sam)
	check_eq(t, "Alex schlägt ein Treffen vor. Stimmst du zu?", "text sollte 'Alex schlägt ein Treffen vor. Stimmst du zu?' sein")

	can = MeetingStatus.can_approve(state, match_p01_p02)
	check(can, "can_approve als p02 sollte true sein")


func test_bestaetigt() -> void:
	# Als p01 Vorschlag erstellen
	state.switch_to("p01")
	var ok := {"place": "Stadtpark, Wiese am Teich", "date": "24.10.2026", "time": "10:30", "form": "Drills"}
	# MeetingStatus.propose ist kein statischer Aufruf, sondern sollte state.propose_meeting() verwenden
	state.propose_meeting(match_p01_p02, ok)

	# Als p2 zustimmen
	state.switch_to("p02")
	state.approve_meeting(match_p01_p02)

	# Wieder als p01 prüfen
	state.switch_to("p01")
	var stage := MeetingStatus.stage(state, match_p01_p02)
	check_eq(stage, MeetingStatus.Stage.CONFIRMED, "stage sollte CONFIRMED sein")

	var t := MeetingStatus.text(state, match_p01_p02)
	check(t.contains("freiwillig"), "text sollte 'freiwillig' enthalten")

	var can := MeetingStatus.can_approve(state, match_p01_p02)
	check(not can, "can_approve sollte false sein wenn bestätigt")


func test_abgesagt() -> void:
	# Erstellen und bestätigen wie oben
	state.switch_to("p01")
	var ok := {"place": "Stadtpark, Wiese am Teich", "date": "24.10.2026", "time": "10:30", "form": "Drills"}
	state.propose_meeting(match_p01_p02, ok)

	state.switch_to("p02")
	state.approve_meeting(match_p01_p02)

	# Als p02 absagen
	state.cancel_meeting(match_p01_p02)

	# Als p02 (hat abgesagt)
	var stage := MeetingStatus.stage(state, match_p01_p02)
	check_eq(stage, MeetingStatus.Stage.CANCELLED, "stage sollte CANCELLED als p02 sein")

	var t := MeetingStatus.text(state, match_p01_p02)
	check_eq(t, "Abgesagt von dir.", "text als p02 sollte 'Abgesagt von dir.' sein")

	# Als p01 (andere Person wurde absagen von p02/Sam)
	state.switch_to("p01")
	stage = MeetingStatus.stage(state, match_p01_p02)
	check_eq(stage, MeetingStatus.Stage.CANCELLED, "stage sollte CANCELLED als p01 sein")

	t = MeetingStatus.text(state, match_p01_p02)
	# other bei active=p01 ist p02 (Sam), cancelled_by="p02" also Name von p02 anzeigen
	check_eq(t, "Abgesagt von Sam.", "text als p01 sollte 'Abgesagt von Sam.' sein")

	# can_cancel sollte false sein
	var can := MeetingStatus.can_cancel(state, match_p01_p02)
	check(not can, "can_cancel sollte false sein wenn bereits abgesagt")


func test_zusammenfassung() -> void:
	var ok := {"place": "Stadtpark, Wiese am Teich", "date": "24.10.2026", "time": "10:30", "form": "Drills"}
	var s := MeetingStatus.summary(ok)
	check_eq(s, "Stadtpark, Wiese am Teich · 24.10.2026, 10:30 Uhr · Drills · mittel", "summary sollte Standardintensität enthalten")

	# Mit Regeln
	ok["rules"] = "Kein Kopfkontakt"
	s = MeetingStatus.summary(ok)
	check(s.contains("Regeln: Kein Kopfkontakt"), "summary sollte zweite Zeile mit Regeln enthalten")

	# Leeres Dictionary
	s = MeetingStatus.summary({})
	check_eq(s, "", "summary von {} sollte '' sein")


func test_beendetes_match() -> void:
	# Vorschlag erstellen
	state.switch_to("p01")
	var ok := {"place": "Stadtpark, Wiese am Teich", "date": "24.10.2026", "time": "10:30", "form": "Drills"}
	state.propose_meeting(match_p01_p02, ok)

	# Match beenden als p01
	state.end_match(match_p01_p02)

	# Als p02 kann nicht mehr approven (Vorschlag weg durch Beendigung)
	state.switch_to("p02")
	var can := MeetingStatus.can_approve(state, match_p01_p02)
	check(not can, "can_approve sollte false sein wenn Match beendet")
