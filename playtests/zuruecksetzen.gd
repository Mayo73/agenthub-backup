extends Playtest
## Profil nach Neustart erhalten und Zurücksetzen mit Rückfrage prüfen.

const STORE := "user://spieltest_zuruecksetzen.json"


func _init() -> void:
	scene_path = "res://scenes/main.tscn"


func describe() -> String:
	return "Profil nach Neustart, Zurücksetzen mit Rückfrage"


func run() -> void:
	# Datei am Anfang löschen (falls vorhanden)
	var dir := DirAccess.open("user://")
	if dir.file_exists(STORE):
		dir.remove(STORE)

	scene.use_store(STORE)
	await wait(0.3)

	# 1. Profil ändern
	scene.show_screen("profil")
	await wait(0.3)
	(scene.screen as ProfileScreen).name_edit.text = "Alexa"
	var save_button := (scene.screen as ProfileScreen).save_button
	save_button.pressed.emit()
	await wait(0.3)
	check(scene.state.active().name == "Alexa", "Name geändert")
	shot("profil")

	# 2. Ein Match anlegen
	scene.state.like("p02")
	await wait(0.1)
	scene._on_switched("p02")
	await wait(0.1)
	scene.state.like("p01")
	await wait(0.1)
	scene.save()
	await wait(0.3)

	# 3. Neustart
	await reload_scene()
	scene.use_store(STORE)
	await wait(0.3)
	check(scene.state.profile("p01").name == "Alexa", "Profiländerung nach Neustart erhalten")
	check(scene.state.book.matches.size() == 1, "Match nach Neustart erhalten")

	# 4. Zurücksetzen abbrechen
	scene.show_screen("profil")
	await wait(0.3)
	var reset_button := (scene.screen as ProfileScreen).reset_button
	reset_button.pressed.emit()
	await wait(0.3)
	check((scene.screen as ProfileScreen).dialog.visible, "Rückfrage erscheint")
	shot("rueckfrage")
	var dialog := (scene.screen as ProfileScreen).dialog
	dialog.cancel_button.pressed.emit()
	await wait(0.3)
	check(scene.state.book.matches.size() == 1, "Abbrechen ändert nichts")

	# 5. Zurücksetzen bestätigen
	reset_button.pressed.emit()
	await wait(0.3)
	dialog.ok_button.pressed.emit()
	await wait(0.3)
	check(scene.state.profile("p01").name == "Alex", "Name wieder Alex")
	check(scene.state.book.matches.is_empty(), "keine Matches mehr")
	check(scene.state.active_id == "p01", "aktive Person wieder Alex")
	check(scene.current_screen == "entdecken", "zurück im Entdecken")

	# 6. Leerzustand
	scene.show_screen("matches")
	await wait(0.3)
	check((scene.screen as MatchesScreen).empty_label.visible, "Leerzustand ohne Matches")
	shot("leer")

	# 7. Aufräumen
	if dir.file_exists(STORE):
		dir.remove(STORE)
