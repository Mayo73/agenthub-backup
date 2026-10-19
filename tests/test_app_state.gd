extends "res://tests/base_test.gd"

var state: AppState


func setup() -> void:
	state = AppState.demo()


func test_demo() -> void:
	# 8 Profile
	check_eq(state.profiles.size(), 8, "8 Profile")
	# aktive Person ist p01
	check_eq(state.active().id, "p01", "active_id ist p01")
	# keine Matches
	check_eq(state.book.matches.size(), 0, "keine Matches")


func test_perspektive_wechseln() -> void:
	# zu p02 wechseln → wahr, Name ist Sam
	var changed := state.switch_to("p02")
	check(changed, "switch_to p02 erfolgreich")
	check_eq(state.active().id, "p02", "ID ist p02")
	check_eq(state.active().name, "Sam", "Name ist Sam")

	# zu nicht existenter ID → falsch, bleibt p02
	changed = state.switch_to("x")
	check(not changed, "switch_to x fehlgeschlagen")
	check_eq(state.active().id, "p02", "bleibt p02")


func test_match_aus_beiden_perspektiven() -> void:
	# als p01 liken → "" (kein Match weil p02 noch nicht gelikt hat)
	var match_id := state.like("p02")
	check_eq(match_id, "", "p01 likes p02 ohne Gegenlike → kein Match")

	# my_matches leer
	check_eq(state.my_matches().size(), 0, "p01: keine Matches nach einseitigem Like")

	# zu p02 wechseln und p01 liken → Match m1
	state.switch_to("p02")
	match_id = state.like("p01")
	check_eq(match_id, "m1", "p02 likes p01 → Match m1")

	# my_matches von p02 hat 1 Eintrag
	var matches := state.my_matches()
	check_eq(matches.size(), 1, "p02: ein Match nach Gegenseitigkeit")
	check(match_id in [matches[0].id], "Match-ID stimmt überein")

	# zurück zu p01 → my_matches hat ebenfalls 1 Eintrag
	state.switch_to("p01")
	matches = state.my_matches()
	check_eq(matches.size(), 1, "p01: ein Match von seiner Sicht aus")


func test_unbeteiligte_sehen_nichts() -> void:
	# Match p01/p02 erstellen
	state.switch_to("p01")
	var match_id := state.like("p02")
	state.switch_to("p02")
	state.like("p01")  # Match m1 entsteht

	# Nachricht von p01 senden
	state.switch_to("p01")
	state.send_message(match_id, "Hallo!")

	# als p03 wechseln: keine Matches, kann nicht schreiben
	state.switch_to("p03")
	var matches := state.my_matches()
	check_eq(matches.size(), 0, "p03: keine Matches")

	var sent := state.send_message(match_id, "x")
	check(not sent, "p03 kann Nachricht in fremdem Match nicht senden")


func test_nachricht_nach_ende() -> void:
	# Match p01/p02 erstellen
	state.switch_to("p01")
	state.like("p02")
	state.switch_to("p02")
	var match_id := state.like("p01")
	check(match_id != "", "Match erstellt nach gegenseitigem Like")

	state.switch_to("p01")
	var sent := state.send_message(match_id, "Hallo!")
	check(sent, "Nachricht gesendet vor Ende")

	# Match beenden (als p01)
	state.end_match(match_id)

	# Nachricht senden nach Ende → false
	sent = state.send_message(match_id, "x")
	check(not sent, "keine Nachricht nach Ende als Endende")

	# zu p02 wechseln: Match ist noch in my_matches, aber can_write false
	state.switch_to("p02")
	var matches := state.my_matches()
	var seen := false
	for m in matches:
		if m["id"] == match_id:
			seen = true
	check(seen, "p02 sieht beendetes Match noch in my_matches")

	check(not state.can_write(match_id), "p02 kann nach Ende nicht schreiben")


func test_treffen_bestaetigen() -> void:
	# Match erstellen
	state.switch_to("p01")
	state.like("p02")
	state.switch_to("p02")
	var match_id := state.like("p01")
	check(match_id != "", "Match erstellt nach gegenseitigem Like")

	# als p01 Treffvorschlag
	state.switch_to("p01")
	var details := {
		"place": "Stadtpark",
		"date": "24.10.2026",
		"time": "10:30",
		"form": "Drills"
	}
	var errors := state.propose_meeting(match_id, details)
	check(errors.is_empty(), "Treffvorschlag gültig, keine Fehler")

	# Bestätigung von p02
	state.switch_to("p02")
	state.approve_meeting(match_id)

	# p01 prüft: confirmed = true
	state.switch_to("p01")
	check(state.meeting_confirmed(match_id), "Treffen bestätigt nach Zustimmung beider")


func test_kandidaten_ohne_gewischte() -> void:
	# p01 lässt sich gewischt (pass_on) bei p03
	state.switch_to("p01")
	state.pass_on("p03")

	var cands := state.candidates()
	var ids: Array[String] = []
	for cp in cands:
		ids.append(cp.id)

	# 6 Profile, ohne p01 (aktiv) und p03 (gewischt)
	check_eq(ids.size(), 6, "6 Kandidaten nach pass_on zu p03")
	check(not ids.has("p01"), "ohne aktive Person selbst")
	check(not ids.has("p03"), "ohne gewischte Person")


func test_profil_aendern() -> void:
	# Kopie von aktuellem Profil erstellen, Name ändern
	state.switch_to("p01")
	var original := state.active().duplicate_profile()
	original.name = "Alexa"

	# update_profile aufrufen
	state.update_profile(original)

	# Name muss geändert sein
	check_eq(state.active().name, "Alexa", "Name wurde geändert")

	# Änderung an der Kopie danach wirkt nicht auf Zustand
	original.name = "Original"
	check_eq(state.active().name, "Alexa", "Zustand bleibt unverändert nach Änderung an Kopie")


func test_speichern_laden() -> void:
	# Match, Nachricht, Treffen erstellen
	state.switch_to("p01")
	state.like("p02")
	state.switch_to("p02")
	var match_id := state.like("p01")
	check(match_id != "", "Match erstellt")

	state.switch_to("p01")
	state.send_message(match_id, "Hallo!")

	var details := {
		"place": "Turnhalle",
		"date": "01.11.2026",
		"time": "18:00",
		"form": "Techniktraining"
	}
	state.propose_meeting(match_id, details)

	# Perspektivwechsel zu p02
	state.switch_to("p02")

	# Serialisieren und deserialisieren
	var d := state.to_dict()
	var loaded := AppState.from_dict(d)

	# active_id ist p02, 1 Match, 1 Nachricht, gleiches Treffen
	check_eq(loaded.active_id, "p02", "active_id bleibt p02")
	check_eq(loaded.book.matches.size(), 1, "1 Match im geladenen Zustand")
	check_eq(loaded.chat.count_for(match_id), 1, "1 Nachricht im geladenen Zustand")

	# Treffvorschlag existiert noch (place Turnhalle)
	var meeting := loaded.meetings.get_meeting(match_id)
	check(not meeting.is_empty(), "Treffvorschlag vorhanden")
	check_eq(meeting.get("place", ""), "Turnhalle", "Ort des Treffens stimmt")


func test_filter_kandidaten() -> void:
	# Filter auf Boxen setzen
	state.filter.art = "Boxen"

	var cands := state.candidates()
	var ids: Array[String] = []
	for p in cands:
		ids.append(p.id)

	check_eq(ids.size(), 2, "Filter Boxen: 2 Kandidaten")
	check(ids.has("p03"), "enthält p03 (Mira)")
	check(ids.has("p08"), "enthält p08 (Tarek)")


func test_filter_kein_matchverbot() -> void:
	# Filter setzen auf Boxen, damit Kandidaten nur Boxer angezeigt werden
	state.filter.art = "Boxen"

	# p01 und p02 liken sich gegenseitig → Match
	# als p01 liken
	state.switch_to("p01")
	state.like("p02")  # einseitiges Like von p01 auf p02

	# als p02 liken und Gegenlike von p01 → Match m1
	state.switch_to("p02")
	var match_id := state.like("p01")
	check(match_id == "m1", "p02 likes p01 → Match m1")

	# Auch wenn Filter auf Boxen steht, darf gematcht werden (Filter gilt nur für Kandidaten-Anzeige)
	state.switch_to("p01")
	var my_matches := state.my_matches()
	check_eq(my_matches.size(), 1, "p01 hat Match trotz Filter")


func test_filter_gespeichert() -> void:
	# Filter-Ebene setzen
	state.filter.level = 0

	# Serialisieren und deserialisieren
	var d := state.to_dict()
	var loaded := AppState.from_dict(d)

	check_eq(loaded.filter.level, 0, "filter.level wurde gespeichert")
