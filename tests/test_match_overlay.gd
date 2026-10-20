extends "res://tests/base_test.gd"

var overlay: MatchOverlay


func setup() -> void:
	overlay = MatchOverlay.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(overlay)


func teardown() -> void:
	overlay.free()


func test_anfangs_versteckt() -> void:
	check(not overlay.visible, "overlay ist anfangs versteckt")
	check_eq(overlay.title_label.text, "Match!", "Titeltext ist 'Match!'")


func test_zeigen() -> void:
	var profiles := DemoData.profiles()
	overlay.show_match(profiles[0], profiles[1], "m7")

	check(overlay.visible, "overlay ist sichtbar nach show_match")
	check_eq(overlay.match_id, "m7", "match_id wurde gesetzt")
	check(overlay.text_label.text.contains(profiles[1].name), "text_label enthält Namen von p02")
	check_eq(overlay.other_avatar.profile.id, "p02", "other_avatar hat Profil p02")
	check_eq(overlay.me_avatar.profile.id, "p01", "me_avatar hat Profil p01")


class _Counter extends RefCounted:
	var count := 0
	var last := ""


func test_schreiben() -> void:
	var profiles := DemoData.profiles()
	overlay.show_match(profiles[0], profiles[1], "m7")

	var counter := _Counter.new()
	overlay.write_requested.connect(_on_write_requested.bind(counter))

	overlay.write_button.pressed.emit()

	check_eq(counter.count, 1, "write_requested wurde einmal emittiert")
	check_eq(counter.last, "m7", "übergebene ID ist 'm7'")
	check(not overlay.visible, "overlay nach Schreiben versteckt")


func test_weiter() -> void:
	var profiles := DemoData.profiles()
	overlay.show_match(profiles[0], profiles[1], "m7")

	var counter := _Counter.new()
	overlay.closed.connect(_on_closed_count.bind(counter))

	overlay.continue_button.pressed.emit()

	check_eq(counter.count, 1, "closed wurde einmal emittiert")
	check(not overlay.visible, "overlay nach Weiter versteckt")


func _on_write_requested(match_id: String, counter: _Counter) -> void:
	counter.count += 1
	counter.last = match_id


func _on_closed_count(counter: _Counter) -> void:
	counter.count += 1
