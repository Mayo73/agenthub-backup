extends "res://playtests/playtest.gd"
## Spieltest der Fischphase: vom Raubfisch gefressen, Wiedereinstieg.


func _init() -> void:
	scene_path = "res://scenes/fish.tscn"


func describe() -> String:
	return "Fischphase: vom Raubfisch gefressen, Wiedereinstieg"


func run() -> void:
	await wait(0.5)
	scene.intro.close()

	# 1. Alle KI-Fische entfernen
	for f in scene.fishes.duplicate():
		scene.remove_fish(f)

	# 2. DNA setzen und Spieler an Startnähe platzieren
	scene.progress.dna = 25
	scene.player.motion.position = FishWorld.START + Vector3(40, 0, 0)
	scene.player.sync()
	scene.player_health.hp = 10.0

	# 3. Zackenbarsch spawnieren
	scene.add_fish("zackenbarsch", scene.player.motion.position + Vector3(0, 0, -12))

	# 4. Warten bis Spielerfisch gefressen wurde
	await until(func() -> bool: return scene.deaths >= 1, 10.0, "Der Zackenbarsch frisst den Spielerfisch")

	# 5. Shot für Wiedereinstieg
	shot("wiedereinstieg")

	# 6. Prüfen ob Fisch an Startstelle wieder auftaucht
	check(scene.player.motion.position.distance_to(FishWorld.START) < 3.0, "Der Fisch taucht an der Startstelle wieder auf")

	# 7. Prüfen volle Gesundheit nach Wiedereinstieg
	check(scene.player_health.hp > 90.0, "Nach dem Wiedereinstieg volle Gesundheit")

	# 8. Prüfen dass DNA erhalten bleibt
	check(scene.progress.dna == 25, "DNA bleibt nach dem Tod erhalten")

	# 9. Todeszähler messen
	measure("tode", scene.deaths)
