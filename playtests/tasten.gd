extends "res://playtests/_zelle.gd"
## Tastatur ohne physischen Tastencode: So schicken Fernsteuerungen wie Computer Use die Tasten.
## Schlägt dieser Test fehl, reagiert das Spiel bei ihnen nicht auf WASD oder Esc.


func describe() -> String:
	return "Tasten nur mit logischem Tastencode (wie Computer Use): Schwimmen (D) und Pause (Esc)"


func run() -> void:
	await start_game()
	var pos: Vector2 = scene.player.position
	key(KEY_D, true, false)
	await wait(1.5)
	key(KEY_D, false, false)
	check(scene.player.position.x > pos.x + 20.0, "D ohne physischen Tastencode lässt die Zelle schwimmen")
	await tap_key(KEY_ESCAPE, false)
	check(scene.pause_menu.visible, "Esc ohne physischen Tastencode öffnet das Pausemenü")
	if scene.pause_menu.visible:
		await tap("pause")
