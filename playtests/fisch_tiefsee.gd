extends "res://playtests/playtest.gd"
## Spieltest der Fischphase: Laternenfische in der Tiefe.


func _init() -> void:
	scene_path = "res://scenes/fish.tscn"


func describe() -> String:
	return "Fischphase: Laternenfische in der Tiefe"


func run() -> void:
	await wait(0.5)
	scene.intro.close()

	var lanterns: Array = scene.fishes.filter(func(f) -> bool: return f.species_id == "laternenfisch")
	check(lanterns.size() == 3, "Drei Laternenfische im Meer")

	if lanterns.is_empty():
		return

	scene.player.motion.position = lanterns[0].motion.position + Vector3(0, 2, 6)
	scene.player.sync()

	await wait(1.5)
	shot("tiefsee")
	check(scene.player.motion.depth() > 40.0, "Der Spielerfisch ist in der Tiefe")
	check(lanterns[0].has_node("Glow"), "Der Laternenfisch leuchtet")
	measure("tiefe", scene.player.motion.depth())
