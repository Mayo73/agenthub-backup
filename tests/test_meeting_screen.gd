extends "res://tests/base_test.gd"

var state: AppState
var screen: MeetingScreen


func setup() -> void:
	state = AppState.demo()
	state.like("p02")
	state.switch_to("p02")
	state.like("p01")
	state.switch_to("p01")
	screen = MeetingScreen.new(state, "m1")
	(Engine.get_main_loop() as SceneTree).root.add_child(screen)


func teardown() -> void:
	screen.free()


func fill(s: MeetingScreen) -> void:
	s.place_edit.text = "Stadtpark"
	s.date_edit.text = "24.10.2026"
	s.time_edit.text = "10:30"
	s.form_picker.select(1)


## Als p01 vorschlagen, als p02 einen neuen Bildschirm bauen und zustimmen.
func confirm_as_p02() -> MeetingScreen:
	fill(screen)
	screen.propose()
	state.switch_to("p02")
	var other := MeetingScreen.new(state, "m1")
	(Engine.get_main_loop() as SceneTree).root.add_child(other)
	other.approve_button.pressed.emit()
	return other


func test_anfang() -> void:
	check_eq(screen.status_label.text, "Noch kein Treffvorschlag.", "Status ohne Vorschlag")
	check(not screen.approve_button.visible, "Zustimmen ausgeblendet")
	check(not screen.cancel_button.visible, "Absagen ausgeblendet")
	check_eq(screen.title_label.text, "Treffen mit Sam", "Titel nennt die andere Person")
	check_eq(screen.propose_button.text, "Vorschlagen", "Knopf ohne Vorschlag")


func test_unvollstaendig() -> void:
	screen.place_edit.text = "Stadtpark"
	check(not screen.propose(), "unvollständiger Vorschlag scheitert")
	check(screen.error_label.text.contains("Datum fehlt oder ist ungültig"), "Hinweis auf das Datum")
	check(not state.meetings.has_meeting("m1"), "nichts gespeichert")


func test_vorschlagen() -> void:
	var counter := [0]
	screen.changed.connect(func() -> void: counter[0] += 1)
	fill(screen)
	screen.propose_button.pressed.emit()
	check_eq(screen.status_label.text, "Wartet auf die Zustimmung von Sam.", "Status nach dem Vorschlag")
	check_eq(screen.propose_button.text, "Änderung vorschlagen", "Knopf nach dem Vorschlag")
	check_eq(counter[0], 1, "changed einmal")
	check(screen.summary_label.text.begins_with("Stadtpark · 24.10.2026, 10:30 Uhr · Drills · mittel"), "Zusammenfassung")


func test_zustimmen_andere_seite() -> void:
	fill(screen)
	screen.propose()
	state.switch_to("p02")
	var other := MeetingScreen.new(state, "m1")
	(Engine.get_main_loop() as SceneTree).root.add_child(other)
	check_eq(other.place_edit.text, "Stadtpark", "Felder aus dem Vorschlag gefüllt")
	check_eq(other.form_picker.selected, 1, "Trainingsform übernommen")
	check(other.approve_button.visible, "Zustimmen sichtbar")
	other.approve_button.pressed.emit()
	check(state.meeting_confirmed("m1"), "von beiden bestätigt")
	check(other.status_label.text.contains("freiwillig"), "Status nennt die Freiwilligkeit")
	check(not other.approve_button.visible, "Zustimmen danach ausgeblendet")
	other.free()


func test_aenderung_verlangt_zustimmung() -> void:
	var other := confirm_as_p02()
	check(state.meeting_confirmed("m1"), "zuerst bestätigt")
	other.time_edit.text = "11:00"
	check(other.propose(), "Änderung angenommen")
	check(not state.meeting_confirmed("m1"), "Änderung verlangt neue Zustimmung")
	other.free()


func test_absagen() -> void:
	fill(screen)
	screen.propose()
	check(screen.cancel_button.visible, "Absagen sichtbar")
	screen.cancel_button.pressed.emit()
	check_eq(screen.status_label.text, "Abgesagt von dir.", "Status nach dem Absagen")
	check(not screen.cancel_button.visible, "Absagen danach ausgeblendet")


func test_beendet() -> void:
	state.end_match("m1")
	screen.refresh()
	check(screen.propose_button.disabled, "beendetes Match: kein Vorschlag mehr")


## Skizze startet mit "Draußen"
func test_skizze_anfang() -> void:
	check_eq(screen.place_view.kind, "Draußen", "Skizze initial Draußen")


## Skizze folgt der Eingabe
func test_skizze_folgt_eingabe() -> void:
	screen.place_edit.text = "Stadtpark"
	screen.place_edit.text_changed.emit("Stadtpark")
	check_eq(screen.place_view.kind, "Park", "Skizze wird zu Park")


## Skizze aus Vorschlag mit Strand
func test_skizze_aus_vorschlag() -> void:
	fill(screen)
	screen.place_edit.text = "Strand am Badesee"
	screen.state.propose_meeting("m1", screen.details())
	state.switch_to("p02")
	var other := MeetingScreen.new(state, "m1")
	(Engine.get_main_loop() as SceneTree).root.add_child(other)
	check_eq(other.place_view.kind, "Strand", "Skizze ist Strand bei Platzvorschlag")
	other.free()


## Gemeinsame Tage werden angezeigt
func test_gemeinsame_tage() -> void:
	screen.refresh()
	var p01 := state.profile("p01")
	var p02 := state.profile("p02")
	check(p01.days.has("Di"), "Alex hat Di")
	check(p01.days.has("Do"), "Alex hat Do")
	check(p01.days.has("Sa"), "Alex hat Sa")
	check(p02.days.has("Mo"), "Sam hat Mo")
	check(p02.days.has("Mi"), "Sam hat Mi")
	check(p02.days.has("Fr"), "Sam hat Fr")
	var expected := "Keine gemeinsamen Tage – sprecht euch ab."
	check_eq(screen.days_label.text, expected, "days_label zeigt keine gemeinsamen Tage")


## Reihenfolge der Elemente
func test_reihenfolge() -> void:
	check(screen.place_view.get_index() == screen.place_edit.get_index() + 1, "place_view folgt direkt nach place_edit")


## Status-Text und Zusammenfassung in einer Karte mit Schattenstilbox
func test_status_karte() -> void:
	check(screen.status_label.get_parent().get_parent() == screen.status_card, "status_label ist zweimal gekettet in status_card")
	var panel := screen.status_card.get_theme_stylebox("panel") as StyleBoxFlat
	check(panel.shadow_size > 0, "status_card hat Schattenstilbox mit shadow_size > 0")


## Felder sind gestaltet: place_edit Mindesthöhe 72, back_button zeigt '‹'
func test_felder_gestaltet() -> void:
	check(screen.place_edit.custom_minimum_size.y == 72, "place_edit hat Mindesthöhe 72")
	check(screen.back_button.text == "‹", "back_button Text ist '‹'")
