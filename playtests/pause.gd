extends "res://playtests/_drift.gd"
## Pausemenü mit der Aktion „pause“ und mit der echten Esc-Taste öffnen und wieder schließen.


func describe() -> String:
	return "Pausemenü mit Esc öffnen und schließen, Spiel steht währenddessen"


func run() -> void:
	if not await wait_for_start():
		return
	autopilot = true
	await wait(3.0)
	stop_driving()
	await tap("pause")
	check(scene.pause_menu.visible, "Esc (Aktion pause) öffnet das Pausemenü")
	check(get_tree().paused, "Im Pausemenü steht das Spiel")
	shot("pausemenue")
	var time_before: float = scene.race.race_time
	await wait(1.0)
	check(is_equal_approx(scene.race.race_time, time_before), "Die Rennzeit läuft in der Pause nicht weiter")
	await tap("pause")
	check(not scene.pause_menu.visible, "Erneutes Esc schließt das Pausemenü")
	check(not get_tree().paused, "Nach der Pause läuft das Spiel weiter")
	await tap_key(KEY_ESCAPE)
	check(scene.pause_menu.visible, "Die echte Esc-Taste öffnet das Pausemenü")
	await tap_key(KEY_ESCAPE)
	check(not scene.pause_menu.visible, "Die echte Esc-Taste schließt das Pausemenü")
