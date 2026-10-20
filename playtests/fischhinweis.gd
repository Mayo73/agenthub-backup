extends "res://playtests/_zelle.gd"
## Spieltest prüft HUD-Hinweis auf den Fisch und gesperrten Editor-Knopf vor Fertigstellung.


func describe() -> String:
	return "Hinweis auf den Fisch im HUD und gesperrter Knopf im Editor"


func run() -> void:
	await start_game()

	# Am Anfang ist der Fisch-Hinweis unsichtbar (noch nicht im letzten Abschnitt)
	check(not scene.hud.fish_label.visible, "Zu Beginn ist der Fisch-Hinweis unsichtbar")
	shot("hud_start")

	# Letzten Abschnitt herstellen (CellProgress.STAGE_COUNT - 1)
	scene.progress.stage = CellProgress.STAGE_COUNT - 1
	await wait(0.3)

	# Erste 5 Teile aus PartCatalog.UNLOCK_ORDER freischalten
	var unlock_order := PartCatalog.UNLOCK_ORDER
	for i in range(min(5, unlock_order.size())):
		scene.unlocks.unlock(unlock_order[i])
	await wait(0.3)

	# HUD zeigt korrekten Fortschritt
	check(scene.hud.fish_label.visible, "HUD zeigt Fisch-Hinweis im letzten Abschnitt")
	check(scene.hud.fish_label.text == "Teile 5/8 – ab 6 kannst du im Editor zum Fisch werden", \
		"HUD-Text stimmt bei 5 Teilen")
	shot("hud_5")

	# Editor öffnen wie in editor.gd: Ladung geben, rufen, zum Partner steuern
	scene.mate.add_charge()
	await tap("rufen")
	target = scene.mate.partner_pos
	if not await until(func() -> bool: return scene.editor_open, 60.0, \
			"Beim Partner öffnet sich der Zelleditor"):
		stop_steering()
		return
	stop_steering()
	await wait(0.5)

	# Editor-Knopf ist gesperrt mit Hinweis
	check(scene.editor.evolve_button.disabled, "Editor-Knopf ist bei 5 Teilen gesperrt")
	check(scene.editor.evolve_hint.text == "Noch 1 Teil finden", \
		"Editor-Hinweis zeigt fehlendes Teil bei 5 Teilen")
	shot("editor_gesperrt")

	# Editor schließen
	scene.editor.cancel()
	await wait(0.5)
	check(not scene.editor_open, "Cancel schließt den Editor")

	# 6. Teil freischalten
	scene.unlocks.unlock(unlock_order[5])
	await wait(0.3)

	# HUD zeigt bereit
	check(scene.hud.fish_label.text == "Bereit: Im Editor kannst du zum Fisch werden", \
		"HUD-Text zeigt 'Bereit' bei 6 Teilen")

	# Editor erneut öffnen
	scene.mate.add_charge()
	await tap("rufen")
	target = scene.mate.partner_pos
	if not await until(func() -> bool: return scene.editor_open, 60.0, \
			"Beim Partner öffnet sich der Zelleditor"):
		stop_steering()
		return
	stop_steering()
	await wait(0.5)

	# Editor-Knopf ist nun freigegeben
	check(not scene.editor.evolve_button.disabled, "Editor-Knopf ist bei 6 Teilen freigegeben")
	shot("editor_frei")

	# Test abschließen
	scene.editor.cancel()
	await wait(0.5)
