extends "res://playtests/playtest.gd"
## Spieltest der Fischphase: Vorwärts schwimmen, auf- und abtauchen, drehen und das Entwicklungsmenü öffnen.


func _init() -> void:
	scene_path = "res://scenes/fish.tscn"


func describe() -> String:
	return "Fischphase: schwimmen, tauchen, drehen, entwickeln"


func run() -> void:
	await wait(0.5)
	scene.intro.close()

	var start: Vector3 = scene.player.motion.position
	await hold("hoch", 2.0)
	check(scene.player.motion.position.distance_to(start) > 5.0, "W schwimmt vorwärts")
	measure("tempo", scene.player.motion.speed())

	# Tauchen neigt den Fisch nur; die Tiefe ändert sich beim Vorwärtsschwimmen.
	var tiefe: float = scene.player.motion.depth()
	press("hoch")
	await hold("abtauchen", 2.0)
	release("hoch")
	check(scene.player.motion.depth() > tiefe + 1.0, "Umschalt taucht beim Schwimmen ab")

	# Nach dem Abtauchen dreht der Fisch erst nach oben, dann steigt er.
	press("hoch")
	press("auftauchen")
	await wait(1.5)
	tiefe = scene.player.motion.depth()
	await wait(1.5)
	release("auftauchen")
	release("hoch")
	check(scene.player.motion.depth() < tiefe - 1.0, "Leertaste taucht beim Schwimmen auf")

	var yaw: float = scene.player.motion.yaw
	press("hoch")
	await hold("links", 1.0)
	release("hoch")
	check(scene.player.motion.yaw > yaw + 0.5, "A dreht nach links")

	await tap("entwickeln")
	check(scene.evolve.visible, "E öffnet das Entwicklungsmenü")
	shot("entwicklung")
	await tap("entwickeln")
	check(not scene.evolve.visible, "E schließt das Menü wieder")
