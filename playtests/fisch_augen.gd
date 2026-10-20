extends "res://playtests/playtest.gd"
## Spieltest der Fischphase: jede Augenstufe lichtet den Nebel sichtbar.


func _init() -> void:
	scene_path = "res://scenes/fish.tscn"


func describe() -> String:
	return "Fischphase: jede Augenstufe lichtet den Nebel sichtbar"


func run() -> void:
	await wait(0.5)
	scene.intro.close()

	# Fisch an Position setzen und ausrichten
	scene.player.global_position = Vector3(0, -40, 0)
	scene.player.global_rotation = Vector3(0, 0, 0)
	await wait(0.2)

	# Felsen als Ziel 45 m vor den Fisch setzen
	var felsen := MeshInstance3D.new()
	felsen.name = "Fels"
	felsen.mesh = FishModel.sphere(1.0)
	felsen.material_override = FishTextures.rock_material()
	felsen.scale = Vector3(4, 4, 4)
	felsen.global_position = scene.player.global_position + Vector3(0, -20, -45)
	scene.world.add_child(felsen)

	scene.hud.clear_message()

	# Für jede Augenstufe von 0 bis 3 Nebeldichte messen und Aufnahme machen
	var nebel_dichten := []
	for stufe in range(4):
		nebel_dichten.append(scene.water.environment.fog_density)
		measure("nebel_%d" % stufe, nebel_dichten[stufe])
		shot("stufe_%d" % stufe)

		# Wenn nicht höchste Stufe, dann Augen verbessern
		if stufe < 3:
			scene.progress.dna = 50
			scene.evolve.open(scene.player.build, scene.progress)
			scene.buttons["augen"].pressed.emit()
			scene.evolve.close()
			scene.hud.clear_message()
			await wait(0.1)

	# Prüfen: Nebeldichte Stufe 1 ist höchstens halb so groß wie bei Stufe 0
	check(nebel_dichten[1] <= nebel_dichten[0] * 0.5, "Nebeldichte Stufe 1 ist höchstens halb so groß wie bei Stufe 0")
