extends "res://playtests/playtest.gd"
## Spieltest der Fischphase: Biss zeigt kurz einen roten Rand und eine vorrangige Meldung.


func _init() -> void:
	scene_path = "res://scenes/fish.tscn"


func describe() -> String:
	return "Fischphase: Biss zeigt kurz einen roten Rand und eine vorrangige Meldung"


func run() -> void:
	await wait(0.5)
	scene.intro.close()
	scene.hud.clear_message()

	# 1. Zustand vor dem Biss feststellen
	await wait(0.2)
	shot("vorher")
	var rand_vorher: float = scene.hud.flash_rect.color.a
	measure("rand_vorher", rand_vorher)
	check(rand_vorher < 0.1, "Der rote Rand ist vorher kaum sichtbar")

	# 2. Biss simulieren: flash() zeigt den Rand und die Bissmeldung (2 s Vorrang)
	scene.hud.flash()
	await wait(0.05)
	shot("biss")
	var rand_biss: float = scene.hud.flash_rect.color.a
	measure("rand_biss", rand_biss)
	check(rand_biss > 0.25, "Der rote Rand beim Biss ist deutlich (über 0.25, Höchstwert 0.35)")
	check(scene.hud.message_label.text == FishHud.BITE_MESSAGE, "Die Bissmeldung ist noch aktiv")

	# 3. Gewöhnliche Meldung zeigt, dass Bissmeldung noch aktiv ist
	scene.hud.show_message("Silberling gefressen!")
	await wait(0.5)
	var rand_nachher: float = scene.hud.flash_rect.color.a
	measure("rand_nachher", rand_nachher)
	check(rand_nachher == 0.0, "Der rote Rand ist nach 0,4 s verblasst")
	shot("danach")
	check(scene.hud.message_label.text == FishHud.BITE_MESSAGE, "Die Bissmeldung ist noch aktiv")

	# 4. Nach 2.0 s ersetzt die gewöhnliche Meldung die Bissmeldung
	await wait(2.0)
	scene.hud.show_message("Eine neue gewöhnliche Meldung")
	check(scene.hud.message_label.text == "Eine neue gewöhnliche Meldung", "Die Bissmeldung wurde ersetzt")
