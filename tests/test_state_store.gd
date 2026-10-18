extends "res://tests/base_test.gd"

const PATH := "user://test_state_store.json"


func teardown() -> void:
	DirAccess.remove_absolute(PATH)


func _veraendert() -> AppState:
	var state := AppState.demo()
	var p := state.profile("p01").duplicate_profile()
	p.name = "Alexa"
	p.bio = "Neu"
	state.update_profile(p)
	state.like("p02")
	state.switch_to("p02")
	var m1 := state.like("p01")
	state.send_message(m1, "Hallo")
	state.propose_meeting(m1, {"place": "Stadtpark", "date": "15.11.2026", "time": "18:00",
		"form": "Techniktraining", "intensity": "locker", "rules": ""})
	state.switch_to("p01")
	state.approve_meeting(m1)
	state.switch_to("p02")
	return state


func test_ohne_datei_demo() -> void:
	var state := StateStore.load_state(PATH)
	check_eq(state.profiles.size(), 8, "8 Demoprofile")
	check_eq(state.active_id, "p01", "aktive Person p01")


func test_neustart_behaelt_alles() -> void:
	var before := _veraendert()
	check(StateStore.save(before, PATH), "speichern klappt")
	var state := StateStore.load_state(PATH)
	check_eq(state.profile("p01").name, "Alexa", "Name bleibt")
	check_eq(state.profile("p01").bio, "Neu", "Bio bleibt")
	check_eq(state.active_id, "p02", "aktive Person bleibt")
	check_eq(state.my_matches().size(), 1, "Match bleibt")
	check_eq(state.chat.count_for("m1"), 1, "Nachricht bleibt")
	check(state.meeting_confirmed("m1"), "Treffen bleibt bestätigt")
	check_eq(typeof(state.profile("p01").level), TYPE_INT, "level ist int")
	check_eq(state.profile("p01").weight_class, before.profile("p01").weight_class, "Gewichtsklasse bleibt")
	check_eq(state.book.next_id, before.book.next_id, "next_id bleibt")


func test_kaputte_datei() -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string("kein json")
	file.close()
	var state := StateStore.load_state(PATH)
	check_eq(state.profiles.size(), 8, "Demodaten bei kaputter Datei")
	check_eq(state.my_matches().size(), 0, "keine Matches")


func test_falsche_version() -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string("{\"version\": 2, \"active_id\": \"p03\"}")
	file.close()
	check_eq(StateStore.load_state(PATH).active_id, "p01", "Demodaten bei fremder Version")


func test_zuruecksetzen() -> void:
	StateStore.save(_veraendert(), PATH)
	var state := StateStore.reset(PATH)
	check_eq(state.my_matches().size(), 0, "keine Matches nach Zurücksetzen")
	check_eq(state.profile("p01").name, "Alex", "ursprünglicher Name")
	var loaded := StateStore.load_state(PATH)
	check_eq(loaded.my_matches().size(), 0, "geladen: keine Matches")
	check_eq(loaded.profile("p01").name, "Alex", "geladen: ursprünglicher Name")
