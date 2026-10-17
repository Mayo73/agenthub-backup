---
id: T-0068
title: Lage der Tribüne an der Startlinie berechnen
project: drift
priority: 3
after: T-0065
---
## Ziel
Neben der Startlinie soll eine Tribüne stehen. `TrackDecor` berechnet dafür ein Rechteck neben der Strecke, parallel zur Fahrtrichtung.

## Dateien
- `scripts/track_decor.gd`: Konstanten und eine Funktion anhängen, sonst nichts ändern
- `tests/test_track_decor.gd`: Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
Am Ende von `scripts/track_decor.gd` anhängen:
```gdscript


const STAND_LENGTH := 420.0
const STAND_DEPTH := 120.0
const STAND_GAP := 90.0


## Rechteck (4 Ecken) der Tribüne: links neben der Startlinie, mit STAND_GAP Abstand zum Streckenrand.
static func grandstand(path: TrackPath) -> PackedVector2Array:
	if path == null or path.length <= 0.0:
		return PackedVector2Array()
	var start := path.start_position()
	var forward := Vector2.from_angle(path.start_heading())
	var side := forward.rotated(-PI / 2.0)
	var near := path.width * 0.5 + STAND_GAP
	var a := start + side * near - forward * STAND_LENGTH * 0.5
	var b := start + side * near + forward * STAND_LENGTH * 0.5
	var c := b + side * STAND_DEPTH
	var d := a + side * STAND_DEPTH
	return PackedVector2Array([a, b, c, d])
```

## Tests
In `tests/test_track_decor.gd` anhängen:
- `test_tribuene_vier_ecken`: `var s := TrackDecor.grandstand(square)` → `s.size()` ist 4; `absf(s[0].distance_to(s[1]) - TrackDecor.STAND_LENGTH) < 0.01`; `absf(s[1].distance_to(s[2]) - TrackDecor.STAND_DEPTH) < 0.01`
- `test_tribuene_neben_strecke`: `var path := TrackPath.new(TrackPath.smooth_closed(TrackCatalog.points_of("hafen"), 10), 280.0)`, `var s := TrackDecor.grandstand(path)` → für keine der 4 Ecken ist `path.is_on_track(ecke)` wahr; der Mittelpunkt `(s[0] + s[2]) * 0.5` hat zu `path.start_position()` einen Abstand zwischen 200.0 und 400.0
- `test_tribuene_ohne_strecke`: `TrackDecor.grandstand(null).size()` ist 0

Review (16.10.2026): gemergt.
