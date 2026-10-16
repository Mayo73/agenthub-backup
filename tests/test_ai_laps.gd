extends "res://tests/base_test.gd"


func test_ki_faehrt_alle_strecken() -> void:
	var dt := 1.0 / 60.0
	for id in TrackCatalog.ids():
		var path := TrackPath.new(TrackPath.smooth_closed(TrackCatalog.points_of(id), 10), TrackCatalog.width_of(id))
		var physics := CarPhysics.new()
		physics.position = path.start_position()
		physics.heading = path.start_heading()
		var driver := AiDriver.new()
		driver.skill = 0.9
		var timer := LapTimer.new(path.length)
		var off_track := 0.0
		var t := 0.0
		while t < 150.0 and timer.lap < 3:
			driver.drive(physics, path)
			var on_track := path.is_on_track(physics.position)
			physics.surface = CarPhysics.Surface.ROAD if on_track else CarPhysics.Surface.GRASS
			if not on_track:
				off_track += dt
			physics.step(dt)
			timer.update(dt, path.progress_at(physics.position))
			t += dt
		check_eq(timer.lap, 3, "KI schafft 3 Runden auf '%s'" % id)
		check(off_track < 1.0, "KI bleibt auf '%s' auf der Strecke (%.1f s daneben)" % [id, off_track])
