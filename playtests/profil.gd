extends Playtest
## Profil bearbeiten, Neustart und prüfen, dass alle Änderungen erhalten bleiben.

const STORE := "user://spieltest_profil.json"


func _init() -> void:
	scene_path = "res://scenes/main.tscn"


func describe() -> String:
	return "Profil bearbeiten und nach Neustart wiederfinden"


func run() -> void:
	# Zu Beginn löschen, falls vorhanden
	var dir: DirAccess = DirAccess.open("user://")
	if dir.file_exists(STORE):
		dir.remove(STORE)

	scene.use_store(STORE)

	# 1. Profil-Reiter öffnen
	scene.tab_buttons["profil"].pressed.emit()
	await wait(0.3)
	var ps: ProfileScreen = scene.screen as ProfileScreen
	check(ps != null, "Profil-Reiter zeigt das Profil")

	# 2. Werte ändern und speichern
	ps.name_edit.text = "Alexa"
	ps.age_spin.value = 30
	ps.day_boxes["So"].button_pressed = true
	ps.save_button.pressed.emit()
	await wait(0.3)
	check(ps.error_label.text == "Gespeichert.", "Profil gespeichert")
	shot("profil")

	# 3. Name in der Demo-Leiste prüfen
	await wait(0.2)
	check(scene.perspective.picker.get_item_text(0).begins_with("Du bist: Alexa"), "Name in der Demo-Leiste aktualisiert")

	# 4. Neustart und Prüfung der Daten
	await reload_scene()
	scene.use_store(STORE)
	await wait(0.3)
	var p01: SparProfile = scene.state.profile("p01")
	check(p01 != null, "Profil p01 existiert nach Neustart")
	check(p01.name == "Alexa", "Name nach Neustart erhalten")
	check(p01.age == 30, "Alter nach Neustart erhalten")
	check(p01.days.has("So"), "Trainingstag nach Neustart erhalten")

	# 5. Profil-Reiter erneut öffnen und Werte prüfen
	scene.tab_buttons["profil"].pressed.emit()
	await wait(0.3)
	ps = scene.screen as ProfileScreen
	check(ps != null, "Profil-Reiter zeigt das Profil nach Neustart")
	check(ps.name_edit.text == "Alexa", "Feld zeigt den gespeicherten Namen")
	shot("profil_neustart")

	# Am Ende löschen
	if dir.file_exists(STORE):
		dir.remove(STORE)
