extends "res://tests/base_test.gd"

var state: AppState
var screen: ChatScreen
var changed_count := 0
var back_count := 0
var meeting_signal_id := ""


func setup() -> void:
	state = AppState.demo()

	# Match p01/p02 erzeugen
	state.like("p02")
	state.switch_to("p02")
	state.like("p01")
	state.switch_to("p01")

	screen = ChatScreen.new(state, "m1")
	(Engine.get_main_loop() as SceneTree).root.add_child(screen)

	back_count = 0
	screen.back.connect(_on_back)

	changed_count = 0
	screen.changed.connect(_on_changed)

	meeting_signal_id = ""
	screen.open_meeting.connect(_on_open_meeting)


func teardown() -> void:
	if screen:
		screen.free()
		screen = null


func _on_changed() -> void:
	changed_count += 1


func _on_back() -> void:
	back_count += 1


func _on_open_meeting(id: String) -> void:
	meeting_signal_id = id


func test_kopf() -> void:
	check_eq(screen.title_label.text, "Sam · MMA", "Titel zeigt Name und Sportart")
	check(screen.empty_label.visible, "empty_label.visible wahr bei leerem Chat")
	check(not screen.closed_label.visible, "closed_label.visible falsch bei aktivem Match")


func test_senden() -> void:
	screen.input.text = "Hallo Sam"
	screen.send_button.pressed.emit()

	check_eq(state.chat.count_for("m1"), 1, "state.chat.count_for('m1') ist 1")
	check_eq(screen.input.text, "", "input.text nach Senden leer")
	check_eq(screen.messages_box.get_child_count(), 1, "messages_box.get_child_count() ist 1")
	check(not screen.empty_label.visible, "empty_label.visible falsch nach Senden")
	check_eq(changed_count, 1, "changed einmal ausgelöst")


func test_leer_nicht_senden() -> void:
	screen.input.text = "  "
	var result: bool = screen.send()

	check(not result, "send() false bei nur Leerzeichen")
	check_eq(state.chat.count_for("m1"), 0, "keine Nachricht gespeichert")


func test_eigene_rechts() -> void:
	# Als p01 eine Nachricht senden
	state.switch_to("p01")
	state.send_message("m1", "Hallo von p01")
	screen.refresh()

	# Zu p02 wechseln, refresh() → das Label hat LEFT
	state.switch_to("p02")
	screen.refresh()
	var child_as_p02 := screen.messages_box.get_child(0) as Label
	check(child_as_p02.horizontal_alignment == HORIZONTAL_ALIGNMENT_LEFT, "Label als fremde Person linksbündig")

	# Zurück zu p01, refresh() → RIGHT
	state.switch_to("p01")
	screen.refresh()
	var child_as_p01 := screen.messages_box.get_child(0) as Label
	check(child_as_p01.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT, "Label als eigene Person rechtsbündig")


func test_beendet() -> void:
	state.end_match("m1")
	screen.refresh()

	check(screen.closed_label.visible, "closed_label.visible wahr nach Beenden")
	check(screen.send_button.disabled, "send_button.disabled wahr nach Beenden")
	check(not screen.input.editable, "input.editable falsch nach Beenden")

	screen.input.text = "x"
	var result: bool = screen.send()
	check(not result, "send() false bei beendetem Match")


func test_zurueck() -> void:
	check_eq(back_count, 0, "back_count initial 0")

	screen.back_button.pressed.emit()

	check_eq(back_count, 1, "back_count ist 1 nach Klick")


func test_beenden_fragt() -> void:
	var dialog := screen.dialog as ConfirmDialog
	check(not dialog.visible, "Dialog initial unsichtbar")

	screen.end_button.pressed.emit()

	check(dialog.visible, "dialog.visible wahr nach end_button.pressed.emit()")
	check(state.book.is_active("m1"), "Match noch aktiv")


func test_beenden() -> void:
	var dialog := screen.dialog as ConfirmDialog

	# Frage stellen und bestätigen
	screen.end_button.pressed.emit()
	dialog.ok_button.pressed.emit()

	check(not state.book.is_active("m1"), "state.book.is_active('m1') falsch nach Beenden")
	check(screen.closed_label.visible, "closed_label.visible wahr nach Beenden")
	check(screen.closed_label.text.begins_with("Beendet von dir."), "closed_label.text beginnt mit 'Beendet von dir.'")
	check(screen.end_button.disabled, "end_button.disabled wahr nach Beenden")


func test_beenden_andere_seite() -> void:
	var dialog := screen.dialog as ConfirmDialog

	# Als p01 beenden
	screen.end_button.pressed.emit()
	dialog.ok_button.pressed.emit()

	# Zu p02 wechseln und neuen ChatScreen bauen
	state.switch_to("p02")
	var screen2: ChatScreen = ChatScreen.new(state, "m1")
	(Engine.get_main_loop() as SceneTree).root.add_child(screen2)

	check(screen2.closed_label.text.begins_with("Beendet von Alex."), "closed_label.text beginnt mit 'Beendet von Alex.'")

	screen2.free()
	screen2 = null


func test_abbrechen() -> void:
	var dialog := screen.dialog as ConfirmDialog

	# Frage stellen und abbrechen
	screen.end_button.pressed.emit()
	dialog.cancel_button.pressed.emit()

	check(state.book.is_active("m1"), "Match weiter aktiv nach Abbruch")


func test_blockieren() -> void:
	var dialog := screen.dialog as ConfirmDialog

	# Blockieren fragen und bestätigen
	screen.block_button.pressed.emit()
	dialog.ok_button.pressed.emit()

	check(state.book.is_blocked("p01", "p02"), "state.book.is_blocked('p01', 'p02') wahr nach Blockieren")
	check(not state.can_write("m1"), "state.can_write('m1') falsch nach Blockieren")
	check_eq(changed_count, 1, "changed einmal ausgelöst")


func test_treffen_knopf() -> void:
	# Meeting-Button existiert und hat Text „Treffen"
	check(screen.meeting_button != null, "meeting_button existiert")
	check(screen.meeting_button.text == "Treffen", "meeting_button.text ist 'Treffen'")

	# Signal wird gesendet mit korrekter match_id
	screen.meeting_button.pressed.emit()
	check_eq(meeting_signal_id, "m1", "Signal open_meeting mit ID 'm1' gesendet")


func test_treffen_status() -> void:
	# Ohne Vorschlag: Statuszeile zeigt „Noch kein Treffvorschlag."
	screen.refresh()
	check(screen.meeting_label.text == "Noch kein Treffvorschlag.", "meeting_label ohne Vorschlag")

	# Als p01 gültigen Vorschlag erstellen
	state.switch_to("p01")
	state.propose_meeting("m1", {"place": "Stadtpark", "date": "24.10.2026", "time": "10:30", "form": "Drills", "intensity": "mittel", "rules": ""})

	# refresh() → Statuszeile aktualisiert sich
	screen.refresh()
	var expected := "Wartet auf die Zustimmung von Sam."
	check_eq(screen.meeting_label.text, expected, "meeting_label zeigt Wartestatus als p01")


func test_sprechblasen() -> void:
	# Als p01 eine Nachricht in "m1" senden
	state.switch_to("p01")
	state.send_message("m1", "Hallo von p01")
	screen.refresh()

	# messages_box.get_child(0) ist Label mit ACCENT-Bereichfarbe
	var label_as_p01 := screen.messages_box.get_child(0) as Label
	check(label_as_p01 != null, "messages_box.get_child(0) ist nicht null")
	var style := label_as_p01.get_theme_stylebox("normal") as StyleBoxFlat
	check(style.bg_color == UiStyle.ACCENT, "Label als eigene Person hat ACCENT-Bereichfarbe")

	# Zu p02 wechseln und refresh() → fremde Blase mit RAISED-Farbe
	state.switch_to("p02")
	screen.refresh()
	var label_as_p02 := screen.messages_box.get_child(0) as Label
	style = label_as_p02.get_theme_stylebox("normal") as StyleBoxFlat
	check(style.bg_color == UiStyle.RAISED, "Label als fremde Person hat RAISED-Bereichfarbe")


func test_runde_knoepfe() -> void:
	# back_button.text ist "‹"
	check(screen.back_button.text == "‹", "back_button.text ist '‹'")
	# send_button.text ist "➤"
	check(screen.send_button.text == "➤", "send_button.text ist '➤'")
	# send_button.custom_minimum_size.x ist 72
	check(screen.send_button.custom_minimum_size.x == 72, "send_button.custom_minimum_size.x ist 72")
