extends "res://tests/base_test.gd"

var state: AppState
var screen: ChatScreen
var changed_count := 0
var back_count := 0


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


func teardown() -> void:
	if screen:
		screen.free()
		screen = null


func _on_changed() -> void:
	changed_count += 1


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
	var result := screen.send()

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
	var result := screen.send()
	check(not result, "send() false bei beendetem Match")


func _on_back() -> void:
	back_count += 1


func test_zurueck() -> void:
	check_eq(back_count, 0, "back_count initial 0")

	screen.back_button.pressed.emit()

	check_eq(back_count, 1, "back_count ist 1 nach Klick")
