extends "res://playtests/playtest.gd"
## Spieltest der Fischphase: Raubfisch greift an, Beute wird gefressen.


func _init() -> void:
	scene_path = "res://scenes/fish.tscn"


func describe() -> String:
	return "Fischphase: Raubfisch greift an, Beute wird gefressen"


func run() -> void:
	await wait(0.5)
	scene.intro.close()

	# 1. Alle KI-Fische entfernen
	for f in scene.fishes.duplicate():
		scene.remove_fish(f)

	# 2. Zackenbarsch spawnieren und angreifen lassen
	var r = scene.add_fish("zackenbarsch", scene.player.motion.position + Vector3(0, 0, -12))
	await until(func() -> bool: return scene.player_health.hp < 100.0, 8.0, "Der Zackenbarsch greift an und beißt")
	measure("gesundheit", scene.player_health.hp)
	shot("raubfisch")

	# Zackenbarsch wieder entfernen
	scene.remove_fish(r)

	# 3. Fleischfresser-Fisch frisst Silberling
	scene.player.build.diet = Diet.FLEISCHFRESSER
	var dna: int = scene.progress.dna
	var s = scene.add_fish("silberling", scene.player.mouth_point())
	s.health.hp = 5.0
	await wait(0.3)
	check(not is_instance_valid(s) or not scene.fishes.has(s), "Der Silberling vor dem Maul wird gefressen")
	check(scene.progress.dna > dna, "Fressen bringt DNA")
