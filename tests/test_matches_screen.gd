extends "res://tests/base_test.gd"

var state: AppState
var screen: MatchesScreen
var received_id := ""


func setup() -> void:
	state = AppState.demo()
	received_id = ""


func teardown() -> void:
	if screen:
		screen.free()
		screen = null


func build() -> void:
	screen = MatchesScreen.new(state)
	(Engine.get_main_loop() as SceneTree).root.add_child(screen)


## a liked b, b liked zurück; danach ist wieder a aktiv. Gibt die Match-ID zurück.
func make_match(a: String, b: String) -> String:
	state.switch_to(a)
	state.like(b)
	state.switch_to(b)
	var id := state.like(a)
	state.switch_to(a)
	return id


func _on_open_chat(id: String) -> void:
	received_id = id


func test_leerzustand() -> void:
	build()
	check(screen.empty_label.visible, "Leerzustand sichtbar")
	check(screen.rows.is_empty(), "keine Zeilen")


func test_eine_zeile() -> void:
	make_match("p01", "p02")
	build()
	check_eq(screen.rows.size(), 1, "Zeilen")
	check_eq((screen.rows["m1"] as Button).text, "Sam · MMA\nNoch keine Nachrichten", "Zeilentext")
	check(not screen.empty_label.visible, "Leerzustand verborgen")


func test_beide_seiten() -> void:
	make_match("p01", "p02")
	state.switch_to("p02")
	build()
	check((screen.rows["m1"] as Button).text.begins_with("Alex · Jiu-Jitsu"), "Zeile aus Sicht von p02")


func test_letzte_nachricht() -> void:
	make_match("p01", "p02")
	state.send_message("m1", "Hallo Sam")
	var m := state.book.get_match("m1")
	check(MatchesScreen.row_text(state, m).ends_with("Du: Hallo Sam"), "eigene Nachricht")
	state.switch_to("p02")
	check(MatchesScreen.row_text(state, m).ends_with("Alex: Hallo Sam"), "Nachricht der anderen Person")


func test_kuerzen() -> void:
	make_match("p01", "p02")
	state.send_message("m1", "a".repeat(50))
	var text := MatchesScreen.row_text(state, state.book.get_match("m1"))
	check(text.ends_with(": " + "a".repeat(40) + "…"), "auf 40 Zeichen gekürzt")


func test_beendet() -> void:
	make_match("p01", "p02")
	state.end_match("m1")
	build()
	check(screen.rows.has("m1"), "beendetes Match bleibt sichtbar")
	check((screen.rows["m1"] as Button).text.ends_with("Match beendet"), "als beendet markiert")


func test_tippen_oeffnet_chat() -> void:
	make_match("p01", "p02")
	build()
	screen.open_chat.connect(_on_open_chat)
	(screen.rows["m1"] as Button).pressed.emit()
	check_eq(received_id, "m1", "empfangene Match-ID")
