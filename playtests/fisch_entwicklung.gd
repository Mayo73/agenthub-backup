extends "res://playtests/playtest.gd"
## Spieltest der Fischphase: Verbesserungen im Entwicklungsmenü wirken spürbar.


func _init() -> void:
	scene_path = "res://scenes/fish.tscn"


func describe() -> String:
	return "Fischphase: Verbesserungen machen schneller und lichten den Nebel"


func run() -> void:
	await wait(0.5)
	scene.intro.close()

	# Schwimmen vorwärts ohne Verbesserung
	await hold("hoch", 3.0)
	var vorher: float = scene.player.motion.speed()
	measure("tempo_vorher", vorher)
	await wait(2.0)  # ausrollen

	# Hinweis auf Verbesserungen prüfen
	scene.progress.dna = 65
	scene.update_upgrade_hint()
	check(scene.hud.upgrade_label.visible, "Hinweis bei genug DNA")

	# Entwicklungsmenü öffnen und Schwanzflosse verbessern
	await tap("entwickeln")
	check(scene.evolve.visible, "E öffnet das Entwicklungsmenü")
	for i in 3:
		scene.evolve.buttons["schwanz"].pressed.emit()
	check(scene.player.build.level("schwanz") == 3, "Schwanzflosse auf Stufe 3")
	shot("menue")

	await tap("entwickeln")
	check(not scene.evolve.visible, "E schließt das Menü")

	# Hinweis sollte weg sein, da DNA nicht mehr reicht
	check(not scene.hud.upgrade_label.visible, "Hinweis weg, wenn die DNA nicht mehr reicht")

	# Schwimmen mit Verbesserung
	await hold("hoch", 3.0)
	var nachher: float = scene.player.motion.speed()
	measure("tempo_nachher", nachher)
	check(nachher > vorher + 2.0, "Mit ausgebauter Schwanzflosse deutlich schneller")

	# Bessere Augen lichten den Nebel
	var nebel: float = scene.water.environment.fog_density
	scene.progress.dna = 10
	scene.evolve.open(scene.player.build, scene.progress)
	scene.evolve.buttons["augen"].pressed.emit()
	scene.evolve.close()
	check(scene.water.environment.fog_density < nebel, "Bessere Augen lichten den Nebel")
	shot("klare_sicht")
