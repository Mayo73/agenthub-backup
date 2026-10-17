extends "res://playtests/_drift.gd"
## Ganzes Rennen mit Autopilot: Countdown, alle Runden, Geisterauto, Ergebnis und Neustart.


func describe() -> String:
	return "Ganzes Rennen mit Autopilot: Countdown, %d Runden, Geisterauto, Ergebnis, Neustart mit Enter" % RaceState.TOTAL_LAPS


func run() -> void:
	await wait(0.5)
	shot("countdown")
	check(not scene.race.can_drive(), "Während des Countdowns darf das Auto nicht fahren")
	if not await wait_for_start():
		return
	autopilot = true
	await wait(6.0)
	shot("unterwegs")
	check(scene.car.physics.speed() > 150.0, "Das Auto fährt nach dem Start los")
	if not await until(func() -> bool: return scene.lap_timer.lap >= 1, 150.0, "Erste Runde beendet"):
		return
	measure("runde_1", snappedf(scene.lap_timer.last_lap_time, 0.01))
	await wait(3.0)
	check(scene.ghost_best != null, "Nach der ersten Runde gibt es ein Geisterauto")
	check(scene.ghost.visible, "Das Geisterauto ist in der zweiten Runde sichtbar")
	shot("geisterauto")
	if not await until(func() -> bool: return scene.race.phase == RaceState.Phase.FINISHED, 400.0, "Rennen über alle Runden beendet"):
		return
	stop_driving()
	await wait(1.0)
	shot("ergebnis")
	check(scene.hud.result_label.visible, "Das Ergebnis wird angezeigt")
	check(scene.hud.result_buttons.visible, "Die Knöpfe „Nochmal“ und „Zum Menü“ werden angezeigt")
	measure("rennzeit", snappedf(scene.race.race_time, 0.01))
	measure("platz", scene.place)
	measure("punkte", scene.scorer.total)
	measure("hoechsttempo", roundi(top_speed))
	await tap("neustart")
	await wait(0.5)
	check(scene.race.phase == RaceState.Phase.COUNTDOWN, "Enter startet nach dem Ergebnis ein neues Rennen")
