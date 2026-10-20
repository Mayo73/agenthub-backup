extends Playtest
## Testperson wechseln, gegenseitiges Interesse ergibt ein Match.

const STORE := "user://spieltest_perspektive.json"


func _init() -> void:
	scene_path = "res://scenes/main.tscn"


func describe() -> String:
	return "Testperson wechseln, gegenseitiges Interesse ergibt ein Match"


func run() -> void:
	# Vorbereitung: alte Test-Daten löschen
	DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))
	scene.use_store(STORE)

	# Schritt 1: Start als Demo-Testperson Alex (p01)
	await wait(0.3)
	check(scene.perspective.tag_label.text.contains("DEMO"), "Demo-Leiste beschriftet")
	check(scene.state.active_id == "p01", "Start als Alex")
	shot("start")

	# Schritt 2: Als p01 Interesse an erster Karte (p02) bekunden
	var d: DiscoverScreen = scene.screen as DiscoverScreen
	check(d.current().id == "p02", "erste Karte ist p02")
	d.like_button.pressed.emit()
	await wait(0.3)
	check(scene.state.book.matches.is_empty(), "einseitiges Interesse ist kein Match")

	# Schritt 3: Perspektive wechseln zu p02
	scene.perspective.picker.select(1)
	scene.perspective.picker.item_selected.emit(1)
	await wait(0.3)
	check(scene.state.active_id == "p02", "jetzt Testperson p02")
	check(scene.perspective.picker.get_item_text(1).begins_with("Du bist: "), "Eintrag beschriftet")
	shot("perspektive")

	# Schritt 4: Als p02 sich selbst nicht sehen
	d = scene.screen as DiscoverScreen
	check(d.current().id != "p02", "eigene Karte wird nicht gezeigt")

	# Schritt 5: Als p02 Interesse an p01 bekunden (so oft swipen, bis p01 angezeigt wird)
	var iter := 0
	while d.current() != null and d.current().id != "p01" and iter < 8:
		d.pass_button.pressed.emit()
		await wait(0.1)
		iter += 1
	d.like_button.pressed.emit()
	await wait(0.3)
	check(scene.state.book.matches.size() == 1, "gegenseitiges Interesse ergibt ein Match")
	check(d.match_label.visible, "Match-Hinweis sichtbar")
	shot("match")

	# Schritt 6: Zurückwechseln zu p01
	scene.perspective.picker.select(0)
	scene.perspective.picker.item_selected.emit(0)
	await wait(0.3)
	check(scene.state.active_id == "p01", "wieder Alex")
	check(scene.state.my_matches().size() == 1, "Match auch aus Sicht von Alex")

	# Schritt 7: Aufräumen
	DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))
