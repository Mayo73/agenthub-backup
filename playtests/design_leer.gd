extends Playtest
## Spieltest: Leerzustände und Dialog im neuen Stil (Modernes Design M9).

const STORE := "user://spieltest_design_leer.json"


func _init() -> void:
	scene_path = "res://scenes/main.tscn"


func describe() -> String:
	return "Leerzustände und Dialog im neuen Stil"


func run() -> void:
	# Eigene Speicherdatei zu Beginn löschen, falls vorhanden
	DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))
	scene.use_store(STORE)
	await wait(0.3)

	# 1. Reiter Matches öffnen
	scene.tab_buttons["matches"].pressed.emit()
	await wait(0.3)
	if (scene.screen as MatchesScreen).empty_label.visible:
		check((scene.screen as MatchesScreen).empty_icon.visible, "Symbol bei leerer Matchliste")
		shot("matches_leer")
		await wait(0.3)  # das Bild entsteht erst im nächsten Frame

	# 2. Reiter Entdecken öffnen, alle Kandidaten überspringen bis Leerzustand
	scene.tab_buttons["entdecken"].pressed.emit()
	await wait(0.3)
	var discover: DiscoverScreen = scene.screen as DiscoverScreen
	for _i in range(20):
		if discover.current() == null:
			break
		discover.decide_pass()
		await wait(0.3)
	check((scene.screen as DiscoverScreen).empty_icon.visible, "Symbol bei leerem Entdecken")
	shot("entdecken_leer")
	await wait(0.3)  # das Bild entsteht erst im nächsten Frame

	# 3. Reiter Profil öffnen, Reset-Dialog öffnen und wieder schließen
	scene.tab_buttons["profil"].pressed.emit()
	await wait(0.3)
	(scene.screen as ProfileScreen).reset_button.pressed.emit()
	await wait(0.3)
	var dialog: ConfirmDialog = (scene.screen as ProfileScreen).dialog
	check(dialog.visible, "Dialog offen")
	shot("dialog")
	await wait(0.3)  # das Bild entsteht erst im nächsten Frame
	dialog.cancel_button.pressed.emit()

	# Eigene Speicherdatei am Ende löschen
	DirAccess.remove_absolute(ProjectSettings.globalize_path(STORE))
