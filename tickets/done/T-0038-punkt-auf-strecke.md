---
id: T-0038
title: Punkt auf der Mittellinie nach Streckenlänge (TrackPath.point_at)
project: drift
priority: 3
---
## Ziel
Die KI-Gegner brauchen einen Zielpunkt ein Stück voraus auf der Strecke. Dafür bekommt `TrackPath` eine Funktion, die zu einer Strecke ab Start (in Pixeln) den Punkt auf der Mittellinie liefert, auch über das Rundenende hinaus.

## Dateien
- `scripts/track_path.gd`
- `tests/test_track_path.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Neue Funktion in `track_path.gd` (z. B. nach `progress_at`):
  ```gdscript
  ## Punkt auf der Mittellinie nach `progress` Pixeln ab Start. Werte über length oder unter 0 laufen im Kreis weiter.
  func point_at(progress: float) -> Vector2:
  	if points.is_empty() or length <= 0.0:
  		return Vector2.ZERO
  	var p := fposmod(progress, length)
  	var n := points.size()
  	for i in n:
  		var a := points[i]
  		var b := points[(i + 1) % n]
  		var seg_len := a.distance_to(b)
  		if p <= _segment_start[i] + seg_len:
  			if seg_len <= 0.0:
  				return a
  			return a.lerp(b, (p - _segment_start[i]) / seg_len)
  	return points[0]
  ```
- Sonst nichts an `track_path.gd` ändern.

## Tests
In `tests/test_track_path.gd` neue Methode `test_punkt_nach_strecke` anhängen. Eigene Strecke im Test anlegen (Quadrat, Länge 8000):
`var square := TrackPath.new(PackedVector2Array([Vector2(0, 0), Vector2(2000, 0), Vector2(2000, 2000), Vector2(0, 2000)]), 280.0)`
- `square.point_at(0.0)` ist `Vector2(0, 0)`
- `square.point_at(500.0)` ist `Vector2(500, 0)`
- `square.point_at(2500.0)` ist `Vector2(2000, 500)`
- `square.point_at(8500.0)` ist `Vector2(500, 0)`
- `square.point_at(-500.0)` ist `Vector2(0, 500)`

Vergleiche jeweils mit `check(square.point_at(…).distance_to(…) < 0.01, "…")`.

Review (16.10.2026): gemergt.
