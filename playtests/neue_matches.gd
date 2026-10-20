extends Playtest
## Spieltest: Prüft die Reihe „Neue Matches" oben und die Zahl im Reiter wie ein Nutzer.

const STORE := "user://spieltest_neue_matches.json"


func _init() -> void:
	scene_path = "res://scenes/main.tscn"


func setup() -> void:
	# Szene initialisieren falls noch nicht geschehen
	if scene == null or not is_instance_valid(scene):
		scene = (load(scene_path) as PackedScene).instantiate()
		get_tree().root.add_child(scene)
		get_tree().current_scene = scene


func describe() -> String:
	return "Neue Matches oben und Zahl im Reiter"


func run() -> void:
	# Speicherdatei am Anfang löschen
	if FileAccess.file_exists(STORE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))

	scene.use_store(STORE)
	await wait(0.3)

	# Match zwischen zwei Testpersonen herstellen (ohne Nachricht)
	# Beide Profile liken sich gegenseitig, damit ein Match entsteht
	scene.state.book.like("p01", "p02")
	await wait(0.3)

	scene.state.book.like("p02", "p01")
	await wait(0.3)

	check(scene.state.my_matches().size() == 1, "Ein Match existiert")

	# Matches-Reiter öffnen
	scene.tab_buttons["matches"].pressed.emit()
	await wait(0.3)

	# Verlässt einen ggf. offenen Match-Bildschirm oder Chat
	check(scene.screen is MatchesScreen, "Matches offen")

	# Prüfen, dass „Neue Matches" oben nicht leer ist
	var matches_screen: MatchesScreen = scene.screen as MatchesScreen
	check(not matches_screen.new_buttons.is_empty(), "Neues Match oben")

	# Prüfen, dass Zahl im Reiter angezeigt wird
	check(" · " in scene.tab_buttons["matches"].text, "Zahl im Reiter")
	shot("neue_matches")

	# Ersten Knopf aus „new_buttons" drücken
	matches_screen.new_buttons[0].pressed.emit()
	await wait(0.3)

	check(scene.screen is ChatScreen, "Chat offen")

	# Speicherdatei am Ende löschen
	DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))
