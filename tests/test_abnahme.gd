extends "res://tests/base_test.gd"

const PATH := "user://test_abnahme.json"

var state: AppState


func teardown() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))


## Hilfsfunktion: als a like(b), switch_to(b), like(a) (Rückgabe merken), switch_to(a), Match-ID zurückgeben
func mutual(state: AppState, a: String, b: String) -> String:
	state.switch_to(a)
	var result := state.like(b)
	state.switch_to(b)
	result = state.like(a)
	state.switch_to(a)
	return result


## Gültige Treffangaben als Konstante
const OK := {
	"place": "Stadtpark, Wiese am Teich",
	"date": "24.10.2026",
	"time": "10:30",
	"form": "Drills"
}


func test_k1_acht_testprofile() -> void:
	state = AppState.demo()
	check_eq(state.profiles.size(), 8, "es gibt 8 Demoprofile")

	var has_jiu_jitsu := false
	var has_mma := false
	var has_boxen := false
	var all_adults := true

	for p in state.profiles:
		if p.art == "Jiu-Jitsu":
			has_jiu_jitsu = true
		if p.art == "MMA":
			has_mma = true
		if p.art == "Boxen":
			has_boxen = true
		if p.age < 18:
			all_adults = false

	check(has_jiu_jitsu, "Sportart Jiu-Jitsu ist vorhanden")
	check(has_mma, "Sportart MMA ist vorhanden")
	check(has_boxen, "Sportart Boxen ist vorhanden")
	check(all_adults, "alle Profile haben age >= 18")


func test_k2_profil_nach_neustart() -> void:
	state = AppState.demo()
	var p := state.profile("p01").duplicate_profile()
	p.name = "Alexa"
	state.update_profile(p)
	StateStore.save(state, PATH)

	var loaded := StateStore.load_state(PATH)
	check_eq(loaded.profile("p01").name, "Alexa", "Name ist nach Neustart 'Alexa'")


func test_k3_match_erst_gegenseitig() -> void:
	state = AppState.demo()
	state.like("p02")
	check(state.my_matches().is_empty(), "nach einseitigem Like von p01: my_matches() leer")

	state.switch_to("p02")
	check(state.my_matches().is_empty(), "nach einseitigem Like von p01: als p02 ist my_matches() leer")

	var match_id := state.like("p01")
	check(not match_id.is_empty(), "gegenseitiges Like erzeugt Match-ID")

	state.switch_to("p01")
	check(state.book.matches.size() == 1, "genau ein Match in book.matches")

	var m1 := state.my_matches()
	check_eq(m1.size(), 1, "aus Perspektive p01: my_matches().size() ist 1")

	state.switch_to("p02")
	var m2 := state.my_matches()
	check_eq(m2.size(), 1, "aus Perspektive p02: my_matches().size() ist 1")


func test_k4_verschiedene_sportarten() -> void:
	state = AppState.demo()

	# Profil p01 auf Jiu-Jitsu setzen (bereits so)
	var p01 := state.profile("p01").duplicate_profile()
	p01.art = "Jiu-Jitsu"
	state.update_profile(p01)

	# Profil p02 auf MMA setzen (bereits so)
	var p02 := state.profile("p02").duplicate_profile()
	p02.art = "MMA"
	state.update_profile(p02)

	var match_id := mutual(state, "p01", "p02")
	check(not match_id.is_empty(), "mutual liefert eine Match-ID bei verschiedenen Sportarten")


func test_k5_chat_nur_fuer_beteiligte() -> void:
	state = AppState.demo()
	var match_id := mutual(state, "p01", "p02")

	state.switch_to("p01")
	check(state.send_message(match_id, "Hallo"), "Nachricht von p01 gesendet")

	state.switch_to("p02")
	check(state.send_message(match_id, "Hi"), "Nachricht von p02 gesendet")

	check_eq(state.chat.count_for(match_id), 2, "chat.count_for ist 2")

	state.switch_to("p03")
	check(state.my_matches().is_empty(), "als p03: my_matches() leer")
	check(not state.send_message(match_id, "x"), "send_message für nicht-Beteiligte liefert false")


func test_k6_treffen_beide_zustimmen() -> void:
	state = AppState.demo()
	var match_id := mutual(state, "p01", "p02")

	state.switch_to("p01")
	var result := state.propose_meeting(match_id, OK)
	check(result.is_empty(), "propose_meeting liefert [] bei gültigen Daten")
	check(not state.meeting_confirmed(match_id), "nach p01-Vorschlag noch nicht bestätigt")

	state.switch_to("p02")
	state.approve_meeting(match_id)
	check(state.meeting_confirmed(match_id), "nach p02-Zustimmung ist Treffen bestätigt")

	# als p02 Vorschlag mit time „11:00" → nicht bestätigt (form fehlt, da neue propose)
	var result2 := state.propose_meeting(match_id, {"place": "Stadtpark", "date": "24.10.2026", "time": "11:00", "form": "Drills"})
	check(result2.is_empty(), "p02-Vorschlag mit neuer Zeit erfolgt")
	check(not state.meeting_confirmed(match_id), "nach neuem p02-Vorschlag noch nicht bestätigt")

	state.switch_to("p01")
	state.approve_meeting(match_id)
	check(state.meeting_confirmed(match_id), "nach p01-Zustimmung wieder bestätigt")


func test_k7_beenden_und_absagen() -> void:
	state = AppState.demo()
	var match_id := mutual(state, "p01", "p02")

	# Treffvorschlag und Bestätigung
	state.switch_to("p01")
	state.propose_meeting(match_id, OK)
	state.switch_to("p02")
	state.approve_meeting(match_id)
	check(state.meeting_confirmed(match_id), "Treffen ist bestätigt")

	# als p02 cancel_meeting → als p01 meetings.is_cancelled wahr
	state.cancel_meeting(match_id)
	state.switch_to("p01")
	check(state.meetings.is_cancelled(match_id), "nach p02-Cancel: is_cancelled wahr")

	# als p1 end_match
	state.switch_to("p01")
	state.end_match(match_id)
	check(not state.book.is_active(match_id), "Match nach Beenden inaktiv")

	state.switch_to("p02")
	var my_m := state.my_matches()
	check(my_m.size() == 1, "Match bleibt in matches_of von p02 enthalten")
	var m := my_m[0]
	check_eq(m["ended_by"], "p01", "ended_by ist p01")

	# send_message falsch (Match beendet)
	check(not state.send_message(match_id, "Hallo"), "send_message nach Ende liefert false")

	# propose_meeting(id, OK) gleich ["Match ist beendet"]
	var result := state.propose_meeting(match_id, OK)
	check_eq(result, ["Match ist beendet"], "propose_meeting nach Ende gibt ['Match ist beendet'] zurück")


func test_k9_neustart_und_zuruecksetzen() -> void:
	state = AppState.demo()

	# Match erstellen
	var match_id := mutual(state, "p01", "p02")

	# Nachricht senden
	state.switch_to("p01")
	state.send_message(match_id, "Hallo")

	# Bestätigtes Treffen
	state.propose_meeting(match_id, OK)
	state.switch_to("p02")
	state.approve_meeting(match_id)
	state.switch_to("p01")
	check(state.meeting_confirmed(match_id), "Treffen ist bestätigt")

	# speichern
	StateStore.save(state, PATH)

	# laden: 1 Match, 1 Nachricht, meeting_confirmed wahr
	var loaded := StateStore.load_state(PATH)
	check_eq(loaded.book.matches.size(), 1, "geladen: 1 Match")
	check_eq(loaded.chat.count_for(match_id), 1, "geladen: 1 Nachricht")
	check(loaded.meeting_confirmed(match_id), "geladen: meeting_confirmed wahr")

	# reset
	StateStore.reset(PATH)
	var after_reset := StateStore.load_state(PATH)

	check_eq(after_reset.book.matches.size(), 0, "nach Reset: keine Matches")
	check_eq(after_reset.chat.count_for(match_id), 0, "nach Reset: keine Nachrichten")
	check_eq(after_reset.profile("p01").name, "Alex", "Name ist wieder 'Alex'")
	check_eq(after_reset.active_id, "p01", "active_id ist p01")
