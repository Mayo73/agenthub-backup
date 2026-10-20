extends "res://tests/base_test.gd"

class _Counter extends RefCounted:
	var count := 0

var state: AppState
var screen: DiscoverScreen


func setup() -> void:
	state = AppState.demo()
	screen = DiscoverScreen.new(state)
	(Engine.get_main_loop() as SceneTree).root.add_child(screen)


func teardown() -> void:
	if screen:
		screen.free()
		screen = null


func test_erstes_profil() -> void:
	check_eq(screen.current().id, "p02", "erstes Profil ist p02 (p01 ist aktive Person)")
	check(screen.card.visible, "Karte soll sichtbar sein")


func test_knopf_interesse() -> void:
	screen.like_button.pressed.emit()
	var liked := state.book.likes.has("p01>p02")
	check(liked, "state.book.likes enthält p01>p02")
	check_eq(screen.current().id, "p03", "nächstes Profil ist p03")


func test_knopf_ueberspringen() -> void:
	screen.pass_button.pressed.emit()
	var passed := state.book.passes.has("p01>p02")
	check(passed, "state.book.passes enthält p01>p02")


func test_wischen_wie_knopf() -> void:
	# Rechte Wischung (LIKE) → p02
	screen.swipe(Vector2(100.0, 600.0), Vector2(400.0, 610.0))
	var liked := state.book.likes.has("p01>p02")
	check(liked, "likes enthält p01>p02 nach rechtem Wischen")

	# Linkes Wischung (PASS) → p03
	screen.swipe(Vector2(400.0, 600.0), Vector2(100.0, 600.0))
	var passed := state.book.passes.has("p01>p03")
	check(passed, "passes enthält p01>p03 nach linkem Wischen")

	# Kurze Wischung (keine Entscheidung) → p04 bleibt aktiv
	screen.swipe(Vector2(100.0, 600.0), Vector2(150.0, 600.0))
	check_eq(screen.current().id, "p04", "current().id bleibt p04")


func test_match_hinweis() -> void:
	# Jiu-Jitsu (p01) und MMA (p02) sollen matchen
	state.switch_to("p02")
	state.like("p01")  # p02 likes p01

	state.switch_to("p01")
	var new_screen := DiscoverScreen.new(state)
	(Engine.get_main_loop() as SceneTree).root.add_child(new_screen)

	var counter := _Counter.new()
	new_screen.matched.connect(func(_match_id: String) -> void: counter.count += 1)

	new_screen.like_button.pressed.emit()
	# In GDScript sind Signale synchron, kein await nötig

	check(new_screen.match_label.visible, "match_label.visible soll wahr sein")
	check(new_screen.match_label.text.contains("Sam"), "Text enthält 'Sam'")
	check_eq(counter.count, 1, "matched Signal einmal ausgelöst")

	new_screen.free()


func test_leerzustand() -> void:
	# Siebenmal überspringen (es gibt 7 Kandidaten für p01)
	for i in range(8):
		screen.pass_button.pressed.emit()

	check(screen.empty_label.visible, "empty_label.visible soll wahr sein")
	check(not screen.card.visible, "card.visible soll falsch sein")
	check(screen.like_button.disabled, "like_button.disabled soll wahr sein")


func test_signal_changed() -> void:
	var counter := _Counter.new()
	# Signal direkt verbinden (in GDScript ist das immer gültig)
	screen.changed.connect(func() -> void: counter.count += 1)

	screen.like_button.pressed.emit()
	screen.pass_button.pressed.emit()
	await Engine.get_main_loop().process_frame

	check_eq(counter.count, 2, "Signal zweimal ausgelöst")


func test_filter_boxen() -> void:
	# Index 3 = "Boxen" (0 = Alle, 1 = Jiu-Jitsu, 2 = MMA, 3 = Boxen)
	screen.set_filter(3, 0)
	check_eq(screen.current().id, "p03", "aktuelles Profil ist p03 (Mira, Boxen)")
	check_eq(state.filter.art, "Boxen", "state.filter.art ist 'Boxen'")


func test_filter_leer() -> void:
	# Boxen (Index 3) + Einsteiger (Index 1) → kein Match bei p01
	screen.set_filter(3, 1)
	check(screen.empty_label.visible, "empty_label.visible soll wahr sein")
	check(screen.empty_label.text.contains("Ändere den Filter"), "Text enthält 'Ändere den Filter'")
	check(screen.empty_label.text.contains("Boxen · Einsteiger"), "Text enthält 'Boxen · Einsteiger'")


func test_filter_aufheben() -> void:
	# Filter setzen (Boxen, Einsteiger)
	screen.set_filter(3, 1)
	check(not screen.card.visible, "Karte soll unsichtbar sein nach aktivem Filter")

	# Filter aufheben
	screen.set_filter(0, 0)
	check_eq(screen.current().id, "p02", "aktuelles Profil ist p02 (Sam)")
	check(screen.card.visible, "Karte soll sichtbar sein")


func test_filter_signal() -> void:
	var counter := _Counter.new()
	screen.changed.connect(func() -> void: counter.count += 1)

	# Filter setzen auf MMA (Index 2) und Jede Erfahrung (Index 0)
	screen.set_filter(2, 0)

	check_eq(counter.count, 1, "changed Signal einmal ausgelöst")


func test_filter_aus_zustand() -> void:
	# state.filter.art auf "MMA" setzen
	state.filter.art = "MMA"

	# Neuen Bildschirm bauen
	var new_screen := DiscoverScreen.new(state)
	(Engine.get_main_loop() as SceneTree).root.add_child(new_screen)

	# art_filter.selected soll 2 sein (0 = Alle, 1 = Jiu-Jitsu, 2 = MMA)
	check_eq(new_screen.art_filter.selected, 2, "art_filter.selected ist 2 für MMA")

	new_screen.free()


func test_stempel_beim_ziehen() -> void:
	# Touch bei Vector2(100, 600)
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(100.0, 600.0)
	screen._on_card_gui_input(touch)

	# Drag nach rechts → like_stamp sichtbar
	var drag_right := InputEventScreenDrag.new()
	drag_right.position = Vector2(180.0, 600.0)
	screen._on_card_gui_input(drag_right)
	check(screen.card.like_stamp.visible, "like_stamp soll sichtbar sein beim rechten Drag")
	check(is_equal_approx(screen.card.like_stamp.modulate.a, 0.5), "like_stamp modulate.a ist 0.5")

	# Drag nach links → pass_stamp sichtbar, like_stamp unsichtbar
	var drag_left := InputEventScreenDrag.new()
	drag_left.position = Vector2(-100.0, 600.0)
	screen._on_card_gui_input(drag_left)
	check(screen.card.pass_stamp.visible, "pass_stamp soll sichtbar sein beim linken Drag")
	check(not screen.card.like_stamp.visible, "like_stamp soll unsichtbar sein nach linkem Drag")


func test_stempel_nach_loslassen() -> void:
	# Touch bei Vector2(100, 600)
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(100.0, 600.0)
	screen._on_card_gui_input(touch)

	# Drag nach rechts (zu kurz für Entscheidung)
	var drag_short := InputEventScreenDrag.new()
	drag_short.position = Vector2(150.0, 600.0)
	screen._on_card_gui_input(drag_short)

	# Loslassen (pressed = false)
	touch.pressed = false
	screen._on_card_gui_input(touch)

	# Beide Stempel unsichtbar
	check(not screen.card.like_stamp.visible, "like_stamp soll nach Loslassen unsichtbar sein")
	check(not screen.card.pass_stamp.visible, "pass_stamp soll nach Loslassen unsichtbar sein")
	# current().id soll weiter p02 sein (keine Entscheidung)
	check_eq(screen.current().id, "p02", "current().id bleibt p02 nach zu kurzem Drag")


func test_match_bildschirm() -> void:
	# Jiu-Jitsu (p01) und MMA (p02) sollen matchen
	state.switch_to("p02")
	state.like("p01")  # p02 likes p01

	state.switch_to("p01")
	var new_screen := DiscoverScreen.new(state)
	(Engine.get_main_loop() as SceneTree).root.add_child(new_screen)

	var counter := _Counter.new()
	new_screen.open_chat.connect(func(_match_id: String) -> void: counter.count += 1)

	new_screen.like_button.pressed.emit()

	check(new_screen.match_overlay.visible, "match_overlay.visible soll wahr sein")
	check(new_screen.match_overlay.text_label.text.contains("Sam"), "Text enthält 'Sam'")
	new_screen.match_overlay.write_button.pressed.emit()
	# Signale sind synchron
	check_eq(counter.count, 1, "open_chat einmal gesendet")
	check(not new_screen.match_overlay.visible, "match_overlay.visible soll falsch sein nach Klick auf Write")

	new_screen.free()


func test_kein_match_kein_bildschirm() -> void:
	state.switch_to("p02")
	# Kein Like von p02 zu p01 im Demozustand

	state.switch_to("p01")
	var new_screen := DiscoverScreen.new(state)
	(Engine.get_main_loop() as SceneTree).root.add_child(new_screen)

	new_screen.like_button.pressed.emit()

	check(not new_screen.match_overlay.visible, "match_overlay.visible soll falsch sein")

	new_screen.free()
