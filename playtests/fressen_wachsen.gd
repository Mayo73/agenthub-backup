extends "res://playtests/_zelle.gd"
## Als Pflanzenfresser zur Nahrung schwimmen, fressen, DNA sammeln und eine Größenstufe wachsen.


func describe() -> String:
	return "Pflanzenfresser schwimmt zur Nahrung, frisst, sammelt DNA und wächst eine Stufe"


func run() -> void:
	await start_game(Diet.PFLANZENFRESSER)
	shot("start")
	var radius_before: float = scene.player.radius
	var start_pos: Vector2 = scene.player.position
	var eaten_before: int = scene.stats.food_eaten
	var end := now() + 300.0
	while now() < end and scene.progress.stage < 1:
		var item := nearest_food()
		target = item.position if item != null else null
		await wait(0.25)
		if scene.stats.food_eaten == eaten_before + 1:
			shot("erstes_fressen")
			eaten_before = -1000
	stop_steering()
	check(scene.player.position.distance_to(start_pos) > 50.0, "Die Zelle schwimmt mit WASD")
	check(scene.stats.food_eaten > 0, "Die Zelle frisst Pflanzennahrung")
	check(scene.progress.dna > 0, "Fressen bringt DNA")
	check(scene.progress.stage >= 1, "Die Zelle wächst nach genug Nahrung eine Stufe (nach 300 s nicht erreicht)")
	check(scene.player.radius > radius_before, "Nach dem Wachsen ist die Zelle größer")
	measure("gefressen", scene.stats.food_eaten)
	measure("dna", scene.progress.dna)
	measure("stufe", scene.progress.stage)
	measure("sekunden", snappedf(now(), 0.1))
	await wait(1.0)
	shot("gewachsen")
