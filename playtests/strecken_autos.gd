extends "res://playtests/_drift.gd"
## Jede Strecke und jedes Auto kurz mit Autopilot fahren: lädt alles, fährt alles, wie unterscheiden sie sich?


func describe() -> String:
	return "Alle Strecken und alle Autos kurz fahren, Bild und Messwerte je Strecke und Auto"


func run() -> void:
	var track_before := GameSettings.track_id
	var car_before := GameSettings.car_id
	for id in TrackCatalog.ids():
		GameSettings.track_id = id
		await _drive_a_bit("strecke_" + id, 15.0)
	GameSettings.track_id = track_before
	for id in CarCatalog.ids():
		GameSettings.car_id = id
		await _drive_a_bit("auto_" + id, 12.0)
	GameSettings.car_id = car_before


func _drive_a_bit(label: String, seconds: float) -> void:
	stop_driving()
	top_speed = 0.0
	await reload_scene()
	if not await wait_for_start():
		return
	autopilot = true
	var start_distance: float = scene.lap_timer.distance()
	var slip_sum := 0.0
	var samples := 0
	var end := now() + seconds
	while now() < end:
		await get_tree().physics_frame
		slip_sum += absf(scene.car.physics.slip_angle_deg())
		samples += 1
	shot(label)
	var driven: float = scene.lap_timer.distance() - start_distance
	measure(label + "_hoechsttempo", roundi(top_speed))
	measure(label + "_schraeglauf", snappedf(slip_sum / maxi(samples, 1), 0.1))
	measure(label + "_strecke", roundi(driven))
	check(driven > 1000.0, "%s: Das Auto kommt voran (%d px in %.0f s)" % [label, roundi(driven), seconds])
	stop_driving()
