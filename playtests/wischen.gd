extends Playtest
## Spieltest: Wischen und Knöpfe bewirken dasselbe, Jiu-Jitsu und MMA matchen


const STORE := "user://spieltest_wischen.json"


func _init() -> void:
	scene_path = "res://scenes/main.tscn"


func describe() -> String:
	return "Wischen und Knöpfe bewirken dasselbe, Jiu-Jitsu und MMA matchen"


func run() -> void:
	# Speicher am Anfang löschen
	var dir := DirAccess.open("")
	if dir.file_exists(ProjectSettings.globalize_path(STORE)):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))
	scene.use_store(STORE)

	await wait(0.3)

	# Alex (p01) ist aktiv
	var d := scene.screen as DiscoverScreen

	# 1. Wischen nach rechts = Interesse
	d.swipe(Vector2(100, 600), Vector2(450, 610))
	await wait(0.3)
	check(scene.state.book.likes.has("p01>p02"), "Wischen nach rechts = Interesse")

	# 2. Wischen nach links = Überspringen
	d.swipe(Vector2(450, 600), Vector2(100, 600))
	await wait(0.3)
	check(scene.state.book.passes.has("p01>p03"), "Wischen nach links = Überspringen")

	# 3. Knopf Interesse
	d = scene.screen as DiscoverScreen
	d.like_button.pressed.emit()
	await wait(0.3)
	check(scene.state.book.likes.has("p01>p04"), "Knopf Interesse")

	# 4. Knopf Überspringen
	d = scene.screen as DiscoverScreen
	d.pass_button.pressed.emit()
	await wait(0.3)
	check(scene.state.book.passes.has("p01>p05"), "Knopf Überspringen")

	# 5. Kurzes Wischen ändert nichts
	d = scene.screen as DiscoverScreen
	d.swipe(Vector2(100, 600), Vector2(140, 600))
	await wait(0.3)
	check(d.current().id == "p06", "Kurzes Wischen ändert nichts")
	shot("entdecken")

	# 6. Switch zu p02 (Jiu-Jitsu) und per Knopf bis zu p01 durchwischen
	scene._on_switched("p02")
	d = scene.screen as DiscoverScreen

	# So oft pass_button drücken, bis d.current().id == "p01" (höchstens 8-mal)
	for i in range(8):
		var current_id := d.current().id
		if current_id == "p01":
			break
		d.pass_button.pressed.emit()
		await wait(0.3)

	# Jetzt Wischen nach rechts für Match
	d = scene.screen as DiscoverScreen
	d.swipe(Vector2(100, 600), Vector2(450, 610))
	await wait(0.3)

	check(scene.state.my_matches().size() == 1, "Jiu-Jitsu und MMA matchen per Wischen")
	check(d.match_label.visible, "Match-Hinweis sichtbar")
	shot("match")

	# Am Ende Speicher wieder löschen
	var dir_end := DirAccess.open("")
	if dir_end.file_exists(ProjectSettings.globalize_path(STORE)):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))
