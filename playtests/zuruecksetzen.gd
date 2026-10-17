extends "res://playtests/_drift.gd"
## Von der Strecke abkommen und mit R zurücksetzen.


func describe() -> String:
	return "Von der Strecke abkommen und mit R zurück auf die Strecke"


func run() -> void:
	if not await wait_for_start():
		return
	press("gas")
	press("rechts")
	var left_track := await until(func() -> bool: return not scene.track.path.is_on_track(scene.car.physics.position), 15.0, "Auto kommt mit Vollgas und Lenkung von der Strecke ab")
	release("rechts")
	release("gas")
	if not left_track:
		return
	await wait(0.5)
	shot("neben_der_strecke")
	await tap("zuruecksetzen")
	check(scene.track.path.is_on_track(scene.car.physics.position), "R setzt das Auto zurück auf die Strecke")
	check(scene.car.physics.speed() < 50.0, "Nach dem Zurücksetzen steht das Auto")
	shot("zurueckgesetzt")
