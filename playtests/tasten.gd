extends "res://playtests/_drift.gd"
## Tastatur ohne physischen Tastencode: So schicken Fernsteuerungen wie Computer Use die Tasten.
## Schlägt dieser Test fehl, reagiert das Spiel bei ihnen nicht auf Gas, Lenken, R oder Esc.


func describe() -> String:
	return "Tasten nur mit logischem Tastencode (wie Computer Use): Gas (W) und Pause (Esc)"


func run() -> void:
	if not await wait_for_start():
		return
	key(KEY_W, true, false)
	await wait(1.5)
	key(KEY_W, false, false)
	check(scene.car.physics.speed() > 50.0, "W ohne physischen Tastencode gibt Gas")
	await tap_key(KEY_ESCAPE, false)
	check(scene.pause_menu.visible, "Esc ohne physischen Tastencode öffnet das Pausemenü")
	if scene.pause_menu.visible:
		await tap("pause")
