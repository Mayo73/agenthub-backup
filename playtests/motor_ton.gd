extends "res://playtests/_drift.gd"
## Motorklang ohne Musik: beschleunigen, eine Weile fahren, dann bremsen. Im Filmlauf zeigt der
## Tonbericht, ob die Tonhöhe dem Tempo folgt.


func describe() -> String:
	return "Motorklang ohne Musik beim Beschleunigen und Bremsen (Tonbericht im Filmlauf)"


func run() -> void:
	scene.music.stop()
	if not await wait_for_start():
		return
	autopilot = true
	await wait(8.0)
	check(top_speed > 400.0, "Das Auto beschleunigt kräftig")
	stop_driving()
	press("bremse")
	await until(func() -> bool: return scene.car.physics.speed() < 30.0, 8.0, "Das Auto bremst bis zum Stand")
	release("bremse")
	await wait(2.0)
