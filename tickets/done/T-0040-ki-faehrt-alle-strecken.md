---
id: T-0040
title: Test – KI fährt alle Strecken
project: drift
priority: 5
after: T-0039
model: qwen3.5:27b
timeout_minutes: 60
---
## Ziel
Abnahmekriterium 4 des Lastenhefts automatisch prüfen: Ein KI-Fahrer schafft auf jeder Strecke aus dem `TrackCatalog` 3 Runden, ohne hängen zu bleiben oder nennenswert neben die Strecke zu geraten.

## Dateien
- `tests/test_ai_laps.gd`: neu (nur diese Datei anlegen, sonst nichts ändern)

## Akzeptanzkriterien
- Der Test simuliert ohne Nodes, nur mit `TrackPath`, `CarPhysics`, `AiDriver` und `LapTimer`.
- Er läuft für jede Strecke höchstens 150 simulierte Sekunden in Schritten von 1/60 s.

## Tests
Neue Datei `tests/test_ai_laps.gd` mit `extends "res://tests/base_test.gd"` und einer Methode `test_ki_faehrt_alle_strecken`:
```gdscript
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
```

Review (16.10.2026): gemergt.
