extends Playtest
## Kompletter Ablauf: Swipe, Match, Chat, Treffen, Neustart

const STORE := "user://spieltest_ablauf.json"


func _init() -> void:
	scene_path = "res://scenes/main.tscn"


func describe() -> String:
	return "Kompletter Ablauf: Swipe, Match, Chat, Treffen, Neustart"


func run() -> void:
	# Speicherdatei am Anfang löschen
	DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))

	# Szene laden und eigene Speicherdatei verwenden
	scene = (load(scene_path) as PackedScene).instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	await get_tree().process_frame
	scene.use_store(STORE)
	await wait(0.3)

	# ===== 1. Entdecken als Alex (p01) =====
	shot("entdecken")
	(scene.screen as DiscoverScreen).swipe(Vector2(100, 600), Vector2(450, 610))
	await wait(0.3)
	check(scene.state.book.likes.has("p01>p02"), "Wischen nach rechts bekundet Interesse")
	check(scene.state.my_matches().is_empty(), "Einseitiges Interesse ergibt kein Match")

	# ===== 2. Wechsel zu Sam (p02) =====
	scene._on_switched("p02")
	await wait(0.3)

	# Im Entdecken-Bildschirm so oft pass_button drücken, bis current().id == "p01" (höchstens 8-mal)
	var discover := scene.screen as DiscoverScreen
	var iterations := 0
	while discover.current() != null and discover.current().id != "p01" and iterations < 8:
		discover.pass_button.pressed.emit()
		await wait(0.3)
		iterations += 1

	# Nun auf p01 kommen und like_button drücken
	discover = scene.screen as DiscoverScreen
	if discover.current() != null and discover.current().id == "p01":
		discover.like_button.pressed.emit()
		await wait(0.3)
		check(not scene.state.my_matches().is_empty(), "Gegenseitiges Interesse ergibt ein Match")
		check(discover.match_label.visible, "Match-Hinweis sichtbar")
	shot("match")

	# ===== 3. Matches-Reiter =====
	scene.tab_buttons["matches"].pressed.emit()
	await wait(0.3)
	shot("matches")

	# Zeile „m1" antippen
	var matches_screen := scene.screen as MatchesScreen
	matches_screen.rows["m1"].pressed.emit()
	await wait(0.3)
	check(scene.screen is ChatScreen, "Chat öffnet sich")

	# Nachricht senden
	var chat_screen := scene.screen as ChatScreen
	chat_screen.input.text = "Hallo Alex, Lust auf Drills im Park?"
	chat_screen.send_button.pressed.emit()
	await wait(0.3)
	shot("chat")

	# ===== 4. Treffen =====
	scene.tab_buttons["matches"].pressed.emit()
	await wait(0.3)
	matches_screen.rows["m1"].pressed.emit()
	await wait(0.3)
	chat_screen = scene.screen as ChatScreen

	chat_screen.meeting_button.pressed.emit()
	await wait(0.3)

	var meeting_screen := scene.screen as MeetingScreen
	meeting_screen.place_edit.text = "Stadtpark, Wiese am Teich"
	meeting_screen.date_edit.text = "24.10.2026"
	meeting_screen.time_edit.text = "10:30"
	# Form Index 1 (Drills)
	meeting_screen.form_picker.select(1)
	meeting_screen.rules_edit.text = "Tap = sofort Stopp"
	await wait(0.3)

	meeting_screen.propose_button.pressed.emit()
	await wait(0.3)
	shot("treffen")

	# ===== 5. Wechsel zu Alex (p01), Meeting bestätigen =====
	scene._on_switched("p01")
	await wait(0.3)

	# Matches → „m1" → Treffen
	scene.tab_buttons["matches"].pressed.emit()
	await wait(0.3)
	matches_screen = scene.screen as MatchesScreen
	matches_screen.rows["m1"].pressed.emit()
	await wait(0.3)

	# Zu Meeting wechseln (ChatScreen hat button "Treffen")
	var chat_screen_alex := scene.screen as ChatScreen
	chat_screen_alex.meeting_button.pressed.emit()
	await wait(0.3)

	meeting_screen = scene.screen as MeetingScreen
	meeting_screen.approve_button.pressed.emit()
	await wait(0.3)
	check(scene.state.meeting_confirmed("m1"), "Treffen von beiden bestätigt")
	shot("bestaetigt")

	# ===== 6. Neustart =====
	await reload_scene()
	await wait(0.3)
	scene.use_store(STORE)
	await wait(0.3)

	check(scene.state.book.matches.size() == 1, "Match nach Neustart erhalten")
	check(scene.state.chat.count_for("m1") == 1, "Nachricht nach Neustart erhalten")
	check(scene.state.meeting_confirmed("m1"), "Treffen nach Neustart bestätigt")

	# ===== 7. Aufräumen =====
	DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))
