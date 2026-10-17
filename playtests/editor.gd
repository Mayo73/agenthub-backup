extends "res://playtests/_zelle.gd"
## Partner rufen (Taste „rufen“), zu ihm schwimmen, Zelleditor öffnen und wieder verlassen.


func describe() -> String:
	return "Partner rufen, hinschwimmen, Zelleditor öffnet sich und lässt sich wieder verlassen"


func run() -> void:
	await start_game()
	scene.mate.add_charge()
	await tap("rufen")
	if scene.mate.partner_pos == null:
		fail("Die Taste „rufen“ ruft mit vorhandener Ladung einen Partner")
		return
	shot("partner")
	target = scene.mate.partner_pos
	if not await until(func() -> bool: return scene.editor_open, 60.0, "Beim Partner öffnet sich der Zelleditor"):
		stop_steering()
		return
	stop_steering()
	await wait(1.0)
	shot("editor")
	check(not scene.world.visible, "Im Editor ist die Spielwelt ausgeblendet")
	check(scene.editor != null and scene.editor.view_layer.visible, "Der Editor ist sichtbar")
	scene.editor.symmetry_button.button_pressed = true
	await wait(0.3)
	shot("editor_symmetrie")
	scene.editor.cancel()
	await wait(0.5)
	check(not scene.editor_open, "Abbrechen schließt den Editor")
	check(scene.world.visible, "Nach dem Editor ist die Spielwelt wieder da")
	measure("editorbesuche", scene.stats.editor_visits)
