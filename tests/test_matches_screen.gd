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


func test_ueberschrift() -> void:
	build()
	check_eq(screen.title_label.text, "Deine Matches", "title_label zeigt „Deine Matches\" auch ohne Matches")
	check(not screen.title_label.visible == false, "title_label ist sichtbar")


func test_leer_mit_symbol() -> void:
	build()
	check(screen.empty_icon.visible, "empty_icon.visible wahr wenn leer")
	check(screen.empty_icon.text == "♥", "empty_icon.text ist ♥")

	var id := make_match("p01", "p02")
	screen.refresh()
	check(not screen.empty_icon.visible, "empty_icon.visible falsch nach Match")


func test_zeile_als_karte() -> void:
	make_match("p01", "p02")
	build()
	var btn := screen.rows["m1"] as Button
	check(btn.alignment == HORIZONTAL_ALIGNMENT_LEFT, "Zeilen-Button ist linksbündig")
	var sb := btn.get_theme_stylebox("normal") as StyleBoxFlat
	check(sb != null, "normal stylebox existiert")
	check(sb.shadow_size > 0, "Zeile hat weichen Schatten (shadow_size > 0)")


func test_neue_matches_reihe() -> void:
	make_match("p01", "p02")
	build()
	check(screen.new_buttons.has("m1"), "new_buttons enthält Match-ID")
	check(screen.new_section.visible, "new_section sichtbar wenn neue Matches vorhanden")


func test_neue_matches_nach_nachricht() -> void:
	make_match("p01", "p02")
	state.send_message("m1", "Hallo Sam")
	build()
	check(screen.new_buttons.is_empty(), "new_buttons leer nach Nachricht")
	check(not screen.new_section.visible, "new_section unsichtbar nach Nachricht")


func test_neue_matches_oeffnet_chat() -> void:
	make_match("p01", "p02")
	build()
	screen.open_chat.connect(_on_open_chat)
	var btn := screen.new_buttons.get("m1") as Button
	btn.pressed.emit()
	check_eq(received_id, "m1", "empfangene Match-ID beim Tipp auf neues Match")


func test_ohne_matches_keine_reihe() -> void:
	build()
	check(not screen.new_section.visible, "new_section unsichtbar ohne Matches")
