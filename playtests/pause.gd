extends "res://playtests/_zelle.gd"
## Pausemenü mit der Aktion „pause“ und mit der echten Esc-Taste öffnen und wieder schließen.


func describe() -> String:
	return "Pausemenü mit Esc öffnen und schließen, Spielwelt steht währenddessen"


func run() -> void:
	await start_game()
	await tap("pause")
	check(scene.paused, "Esc (Aktion pause) pausiert das Spiel")
	check(scene.pause_menu.visible, "Esc öffnet das Pausemenü")
	shot("pausemenue")
	var pos: Vector2 = scene.player.position
	await hold("rechts", 1.0)
	check(scene.player.position.distance_to(pos) < 1.0, "In der Pause bewegt sich die Zelle nicht")
	await tap("pause")
	check(not scene.paused and not scene.pause_menu.visible, "Erneutes Esc setzt das Spiel fort")
	await tap_key(KEY_ESCAPE)
	check(scene.pause_menu.visible, "Die echte Esc-Taste öffnet das Pausemenü")
	await tap_key(KEY_ESCAPE)
	check(not scene.pause_menu.visible, "Die echte Esc-Taste schließt das Pausemenü")
