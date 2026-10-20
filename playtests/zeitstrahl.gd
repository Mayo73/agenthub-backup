extends "res://playtests/_zelle.gd"
## Zellenphase: Taste T zeigt den Entwicklungszeitstrahl mit allen bisherigen Schritten.


func describe() -> String:
	return "Zellenphase: Taste T zeigt den Entwicklungszeitstrahl"


func run() -> void:
	await start_game(Diet.PFLANZENFRESSER)
	shot("start")

	## Zweimal wachsen lassen (zwei neue Abschnitte erreichen)
	var eaten_before: int = scene.stats.food_eaten
	var end := now() + 300.0
	while now() < end and scene.progress.stage < 2:
		var item := nearest_food()
		if item != null:
			target = item.position
		await wait(0.25)
		if scene.stats.food_eaten > eaten_before:
			eaten_before = scene.stats.food_eaten

	stop_steering()
	check(scene.progress.stage >= 2, "Zwei neue Abschnitte erreicht")
	shot("nach_zwei_groessen")

	## Editor einmal öffnen und bestätigen
	await tap("editor")
	if not await until(func() -> bool: return scene.editor_open, 60.0, "Editor öffnet sich"):
		stop_steering()
		return
	shot("editor_offen")
	scene.editor.cancel()
	await wait(0.5)
	check(not scene.editor_open, "Editor wieder geschlossen")
	shot("editor_zu")

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
