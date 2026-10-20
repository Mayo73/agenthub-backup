extends Playtest
## Spieltest: Alle Bildschirme im neuen Stil nacheinander zeigen (Material für Design-Prüfungen).
## Öffnet Matches, Chat, Treffen und Profil und macht je ein Bild.

const STORE := "user://spieltest_design.json"


func _init() -> void:
	scene_path = "res://scenes/main.tscn"


func describe() -> String:
	return "Alle Bildschirme im neuen Stil"


func run() -> void:
	# Speicherdatei am Anfang löschen
	if FileAccess.file_exists(STORE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))

	scene.use_store(STORE)
	await wait(0.3)

	# ===== 1. Match zwischen zwei Testpersonen herstellen und Nachricht senden =====
	var discover := scene.screen as DiscoverScreen
	check(discover != null, "Entdecken ist offen")

	# Alex (p01) interessiert sich für Sam (p02)
	discover.like_button.pressed.emit()
	await wait(0.3)

	# Zu Sam (p02) wechseln
	scene._on_switched("p02")
	await wait(0.3)

	# Alex im Entdecken-Stapel finden und liken
	var discover_alex := scene.screen as DiscoverScreen
	var iterations := 0
	while discover_alex.current() != null and discover_alex.current().id != "p01" and iterations < 8:
		discover_alex.pass_button.pressed.emit()
		await wait(0.3)
		iterations += 1

	check(discover_alex.current() != null, "Alex im Stapel gefunden")
	discover_alex.like_button.pressed.emit()
	await wait(0.3)

	# Match ist entstanden, zu Matches wechseln
	scene.tab_buttons["matches"].pressed.emit()
	await wait(0.3)
	check(scene.screen is MatchesScreen, "Matches offen")
	shot("matches")
	await wait(0.3)  # das Bild entsteht erst im nächsten Frame

	# Zeile des Matches drücken
	var matches_screen := scene.screen as MatchesScreen
	matches_screen.rows["m1"].pressed.emit()
	await wait(0.3)
	check(scene.screen is ChatScreen, "Chat offen")
	shot("chat")
	await wait(0.3)  # das Bild entsteht erst im nächsten Frame

	# Nachricht senden
	var chat_screen := scene.screen as ChatScreen
	chat_screen.input.text = "Lust auf ein Training?"
	chat_screen.send_button.pressed.emit()
	await wait(0.3)

	# ===== 2. Treffen öffnen =====
	(chat_screen.meeting_button).pressed.emit()
	await wait(0.3)
	check(scene.screen is MeetingScreen, "Treffen offen")
	shot("treffen")
	await wait(0.3)  # das Bild entsteht erst im nächsten Frame

	# ===== 3. Profil öffnen =====
	scene.tab_buttons["profil"].pressed.emit()
	await wait(0.3)
	check(scene.screen is ProfileScreen, "Profil offen")
	shot("profil")
	await wait(0.3)  # das Bild entsteht erst im nächsten Frame

	# Speicherdatei am Ende löschen
	if FileAccess.file_exists(STORE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))
