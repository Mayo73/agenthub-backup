extends Playtest
## Spieltest: Unbeteiligte, Absage und Beenden aus beiden Perspektiven

const STORE := "user://spieltest_beenden.json"
var state: AppState


func _init() -> void:
	scene_path = "res://scenes/main.tscn"


func describe() -> String:
	return "Unbeteiligte, Absage und Beenden aus beiden Perspektiven"


func run() -> void:
	# Anfang: Datei löschen, falls vorhanden
	var dir_access := DirAccess.open("user://")
	if dir_access.file_exists("spieltest_beenden.json"):
		dir_access.remove_absolute(ProjectSettings.globalize_path(STORE))

	scene.use_store(STORE)

	# 1. Match vorbereiten
	state.like("p02")
	await wait(0.3)
	scene._on_switched("p02")
	await wait(0.3)
	state.like("p01")
	await wait(0.3)
	state.save()
	check(state.book.is_active("m1"), "Match m1 besteht")

	# 2. Als Sam (p02): Chat öffnen und Nachricht senden
	scene.show_chat("m1")
	await wait(0.3)
	var input := scene.input as LineEdit
	input.text = "Hallo Alex"
	await wait(0.3)
	var send_button := scene.send_button as Button
	send_button.pressed.emit()
	await wait(0.3)
	check(state.chat.count_for("m1") == 1, "Nachricht gesendet")

	# 3. Unbeteiligt: als p03 (Mira)
	scene._on_switched("p03")
	await wait(0.3)
	scene.show_screen("matches")
	await wait(0.3)
	var matches_screen := scene.screen as MatchesScreen
	check(state.my_matches().is_empty(), "Mira hat kein Match")
	check(matches_screen.empty_label.visible, "Mira sieht den Leerzustand statt des Chats")
	shot("unbeteiligt")

	# 4. Treffen: p01 (Alex) schickt Vorschlag, p02 (Sam) sagt ab
	scene._on_switched("p01")
	await wait(0.3)
	scene.show_meeting("m1")
	await wait(0.3)
	var meeting_screen := scene.screen as MeetingScreen
	meeting_screen.place_edit.text = "Stadtpark, Wiese am Teich"
	await wait(0.1)
	meeting_screen.date_edit.text = "24.10.2026"
	await wait(0.1)
	meeting_screen.time_edit.text = "10:30"
	await wait(0.1)
	meeting_screen.form_picker.select(1)
	await wait(0.1)
	var propose_button := meeting_screen.propose_button as Button
	propose_button.pressed.emit()
	await wait(0.3)

	# p02 (Sam) sieht Vorschlag und sagt ab
	scene._on_switched("p02")
	await wait(0.3)
	scene.show_meeting("m1")
	await wait(0.3)
	meeting_screen = scene.screen as MeetingScreen
	var cancel_button := meeting_screen.cancel_button as Button
	cancel_button.pressed.emit()
	await wait(0.3)
	check((scene.screen as MeetingScreen).status_label.text.begins_with("Abgesagt von dir"), "Sam sieht die eigene Absage")

	# 5. Absage aus der anderen Perspektive: p01 (Alex) sieht Absage von Sam
	scene._on_switched("p01")
	await wait(0.3)
	scene.show_meeting("m1")
	await wait(0.3)
	check((scene.screen as MeetingScreen).status_label.text.begins_with("Abgesagt von Sam"), "Alex sieht die Absage von Sam")
	shot("absage")

	# 6. Beenden: p01 (Alex) beendet das Match
	scene.show_chat("m1")
	await wait(0.3)
	var end_button := scene.end_button as Button
	end_button.pressed.emit()
	await wait(0.3)
	var dialog := scene.dialog as ConfirmDialog
	dialog.ok_button.pressed.emit()
	await wait(0.3)
	check(not state.book.is_active("m1"), "Match beendet")

	# 7. Andere Perspektive: p02 (Sam) sieht, dass Alex beendet hat
	scene._on_switched("p02")
	await wait(0.3)
	scene.show_chat("m1")
	await wait(0.3)
	var chat_screen := scene.screen as ChatScreen
	check(chat_screen.closed_label.text.begins_with("Beendet von Alex"), "Sam sieht, dass Alex beendet hat")
	check(chat_screen.send_button.disabled, "Senden gesperrt")
	check(not state.send_message("m1", "Noch da?"), "keine neue Nachricht möglich")
	var new_meeting: Array[String] = state.propose_meeting("m1", {"place": "Park", "date": "25.10.2026", "time": "11:00", "form": "Drills"})
	check(not new_meeting.is_empty(), "kein neuer Treffvorschlag möglich")
	shot("beendet")

	# 8. Aufräumen: Datei löschen
	if dir_access.file_exists("spieltest_beenden.json"):
		dir_access.remove_absolute(ProjectSettings.globalize_path(STORE))
