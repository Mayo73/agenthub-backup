extends Playtest
## Spieltest: Match-Bildschirm und Weg in den Chat

const STORE := "user://spieltest_matchbild.json"


func _init() -> void:
	scene_path = "res://scenes/main.tscn"


func describe() -> String:
	return "Match-Bildschirm und Weg in den Chat"


func run() -> void:
	# Speicher am Anfang löschen
	var dir := DirAccess.open("")
	if dir.file_exists(ProjectSettings.globalize_path(STORE)):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))
	scene.use_store(STORE)

	await wait(0.3)

	# 1. Setup: zu p02 (Sam) wechseln, p01 liken (gegenseitiges Interesse), zurück zu p01
	scene.state.switch_to("p02")
	scene.state.like("p01")
	scene.state.switch_to("p01")

	# 2. Entdecken-Bildschirm zeigen und auf Sam durchwischen
	scene.show_screen("entdecken")
	await wait(0.3)
	var d := scene.screen as DiscoverScreen

	# P02 ist noch Kandidat, weil p01 noch nicht gewischt hat
	# Direktes Like auf p02 (Sam) auslösen -> Match entsteht
	d.like_button.pressed.emit()
	await until(func() -> bool: return (scene.screen as DiscoverScreen).match_overlay.visible, 2.0, "Match-Bildschirm erscheint")

	# 3. Prüfen, dass Sam im Text steht, Bild aufnehmen
	check(scene.screen.match_overlay.text_label.text.contains("Sam"), "Match-Text enthält Sam")
	shot("match")
	await wait(0.3)

	# 4. Auf "Nachricht schreiben" klicken und zum Chat wechseln
	var match_overlay := scene.screen.match_overlay as MatchOverlay
	match_overlay.write_button.pressed.emit()
	await wait(0.3)
	check(scene.current_screen == "chat", "Nachricht schreiben öffnet den Chat")
	shot("chat")

	# 5. Speicher am Ende wieder löschen
	var dir_end := DirAccess.open("")
	if dir_end.file_exists(ProjectSettings.globalize_path(STORE)):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))
