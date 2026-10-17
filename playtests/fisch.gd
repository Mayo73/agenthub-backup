extends "res://playtests/playtest.gd"
## Spieltest der Fischphase: Vorwärts schwimmen, auf- und abtauchen, drehen und das Entwicklungsmenü öffnen.


func describe() -> String:
	return "Fischphase: schwimmen, tauchen, drehen, entwickeln"


func run() -> void:
	scene_path = "res://scenes/fish.tscn"

	await wait(0.5)
	scene.intro.close()

	var start: Vector3 = scene.player.motion.position
	await hold("hoch", 2.0)
	check(scene.player.motion.position.distance_to(start) > 5.0, "W schwimmt vorwärts")
	measure("tempo", scene.player.motion.speed())

	var tiefe: float = scene.player.motion.depth()
	press("abtauchen")
	await hold("abtauchen", 1.5)
	release("abtauchen")
	check(scene.player.motion.depth() > tiefe + 1.0, "Umschalt taucht ab")

	tiefe = scene.player.motion.depth()
	press("hoch")
	await hold("auftauchen", 1.5)
	release("hoch")
	check(scene.player.motion.depth() < tiefe - 1.0, "Leertaste taucht auf")

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
