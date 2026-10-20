extends "res://playtests/_zelle.gd"
## Spieltest zum Übergang vom Editor zur Fischphase: Im letzten Wachstumsabschnitt mit 5 Teilen
## wird der Evolution-Button gesperrt, nach Freischalten eines sechsten Teils ist er aktiv.


func _init() -> void:
	scene_path = "res://scenes/main.tscn"


func describe() -> String:
	return "Zellenphase: im Editor zum Fisch werden"


func run() -> void:
	await start_game()

	# Letzten Wachstumsabschnitt erreichen.
	scene.progress.stage = CellProgress.STAGE_COUNT - 1

	# Fünf Teile freischalten (laut UNLOCK_ORDER).
	for i in 5:
		var part: String = PartCatalog.UNLOCK_ORDER[i]
		scene.unlocks.unlock(part)

	# Editor öffnen und prüfen, dass Evolution-Button gesperrt ist.
	scene.open_editor()
	check(scene.editor.evolve_button.disabled, "Knopf mit 5 Teilen gesperrt")
	shot("gesperrt")

	# Editor verlassen.
	scene.editor.cancel()
	await wait(0.5)

	# Ein sechstes Teil freischalten.
	var sixth := PartCatalog.UNLOCK_ORDER[5]
	scene.unlocks.unlock(sixth)

	# Editor wieder öffnen.
	scene.open_editor()
	check(not scene.editor.evolve_button.disabled, "Knopf mit 6 Teilen frei")
	shot("frei")

	# Evolution auslösen.
	scene.editor.evolve_button.pressed.emit()
	await wait(1.2)
	shot("verwandlung")

	# Auf Szenenwechsel warten (nur über Engine.get_main_loop().current_scene prüfen).
	await until(func() -> bool: return Engine.get_main_loop().current_scene != null and Engine.get_main_loop().current_scene.scene_file_path == "res://scenes/fish.tscn", 6.0, "Fischszene geladen")
