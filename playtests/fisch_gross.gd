extends "res://playtests/playtest.gd"
## Spieltest der Fischphase: Raubfisch flieht vor großem Fisch.


func _init() -> void:
	scene_path = "res://scenes/fish.tscn"


func describe() -> String:
	return "Fischphase: Raubfisch flieht vor großem Fisch"


func run() -> void:
	await wait(0.5)
	scene.intro.close()

	# 1. Alle KI-Fische entfernen
	for f in scene.fishes.duplicate():
		scene.remove_fish(f)

	# 2. Spielerfisch auf Größe 3 vergrößern
	scene.progress.stage = 3
	scene.player.set_size(scene.progress.size())

	# 3. Zackenbarsch spawnieren hinter dem Spieler
	var hunter: Node3D = scene.add_fish("zackenbarsch", scene.player.motion.position + Vector3(0, 0, -10))

	# 4. Startabstand messen
	var start_dist: float = hunter.motion.position.distance_to(scene.player.motion.position)

	# 5. Warten
	await wait(3.0)

	# 6. Endabstand messen
	var end_dist: float = hunter.motion.position.distance_to(scene.player.motion.position)

	# 7. Shot für Flucht
	shot("flucht")

	# 8. Prüfen ob Zackenbarsch wegschwimmt
	check(end_dist > start_dist + 3.0, "Der Zackenbarsch schwimmt vom großen Fisch weg")

	# 9. Abstände messen
	measure("abstand_start", start_dist)
	measure("abstand_ende", end_dist)
