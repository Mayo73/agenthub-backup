extends "res://playtests/_zelle.gd"
## Zellenphase: Taste T zeigt den Entwicklungszeitstrahl mit allen bisherigen Schritten.


func describe() -> String:
	return "Zellenphase: Taste T zeigt den Entwicklungszeitstrahl"


func run() -> void:
	await start_game(Diet.PFLANZENFRESSER)
	shot("start")

	## Zweimal wachsen lassen: Nahrung direkt verbuchen wie beim Fressen (schneller als Hinschwimmen)
	for i in 400:
		if scene.progress.stage >= 2:
			break
		scene.eat_value(Diet.PFLANZE, 5)
		await wait(0.02)
	check(scene.progress.stage >= 2, "Zwei neue Abschnitte erreicht")
	shot("nach_zwei_groessen")
	await wait(0.3)

	## Editor über den Partner öffnen (wie in fischhinweis.gd) und bestätigen
	scene.mate.add_charge()
	await tap("rufen")
	target = scene.mate.partner_pos
	if not await until(func() -> bool: return scene.editor_open, 60.0, "Editor öffnet sich"):
		stop_steering()
		return
	stop_steering()
	shot("editor_offen")
	await wait(0.3)
	scene.editor.confirm()
	await wait(0.5)
	check(not scene.editor_open, "Editor nach dem Bestätigen geschlossen")

	## Taste T drücken (Zeitstrahl zeigen)
	await tap_key(KEY_T, false)
	await wait(0.3)
	check(scene.timeline_view.visible, "Taste T zeigt den Zeitstrahl")
	shot("zeitstrahl_offen")

	## Mindestens 4 Einträge: Start, zwei Größen und Editor
	check(scene.timeline_view.item_count() >= 4, "Start, zwei Größen und Editor")
	shot("leiste")

	## Taste T nochmals drücken (Zeitstrahl verstecken)
	await tap_key(KEY_T, false)
	await wait(0.3)
	check(not scene.timeline_view.visible, "Taste T versteckt den Zeitstrahl")
	shot("zeitstrahl_zu")
