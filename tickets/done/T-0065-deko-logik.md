---
id: T-0065
title: Positionen für Strecken-Deko (TrackDecor)
project: drift
priority: 3
---
## Ziel
Neben der Strecke sollen Reifenstapel und Bäume stehen. Diese Klasse berechnet nur die Positionen; gezeichnet wird in einem späteren Ticket.

## Dateien
- `scripts/track_decor.gd`: neu, beginnt mit `class_name TrackDecor` und `extends RefCounted`
- `tests/test_track_decor.gd`: neu

## Akzeptanzkriterien
Genau dieser Code in `scripts/track_decor.gd`:
```gdscript
class_name TrackDecor
extends RefCounted
## Berechnet, wo neben der Strecke Deko steht (Reifenstapel, Bäume). Zeichnet selbst nichts.

enum Kind { TIRES, TREE }


## Punkte im Abstand `spacing` entlang der Strecke, jeweils `offset` links und rechts der Mittellinie.
## Punkte, die in engen Kurven zu nah an die Mittellinie geraten (unter offset * 0.9), fallen weg.
static func side_points(path: TrackPath, spacing: float, offset: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	if path == null or path.length <= 0.0 or spacing <= 0.0:
		return out
	var d := 0.0
	while d < path.length:
		var p := path.point_at(d)
		var dir := (path.point_at(d + 1.0) - p).normalized()
		var normal := dir.orthogonal()
		for side in [1.0, -1.0]:
			var q: Vector2 = p + normal * offset * side
			if path.distance_from_center(q) >= offset * 0.9:
				out.append(q)
		d += spacing
	return out


## Deko einer Strecke: Reifenstapel knapp neben dem Rand, Bäume weiter draußen.
## Jeder Eintrag: {"kind": Kind, "position": Vector2}.
static func build(path: TrackPath) -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	if path == null:
		return items
	for q in side_points(path, 320.0, path.width * 0.5 + 60.0):
		items.append({"kind": Kind.TIRES, "position": q})
	for q in side_points(path, 450.0, path.width * 0.5 + 260.0):
		items.append({"kind": Kind.TREE, "position": q})
	return items
```

## Tests
Neue Datei `tests/test_track_decor.gd` mit `extends "res://tests/base_test.gd"`, Variable `var square: TrackPath`, in `setup()`:
`square = TrackPath.new(PackedVector2Array([Vector2(0, 0), Vector2(2000, 0), Vector2(2000, 2000), Vector2(0, 2000)]), 280.0)`
- `test_seitenpunkte`: `var pts := TrackDecor.side_points(square, 1000.0, 200.0)` → `pts.size() >= 8`; jeder Punkt hat `square.distance_from_center(p) >= 179.0`; es gibt einen Punkt mit `p.distance_to(Vector2(1000, -200)) < 1.0` und einen mit `p.distance_to(Vector2(1000, 200)) < 1.0`
- `test_ohne_abstand`: `TrackDecor.side_points(square, 0.0, 200.0).size()` ist 0; `TrackDecor.side_points(null, 100.0, 200.0).size()` ist 0
- `test_deko_aufbauen`: `var items := TrackDecor.build(square)` → es gibt mindestens einen Eintrag mit `item["kind"] == TrackDecor.Kind.TIRES` und mindestens einen mit `item["kind"] == TrackDecor.Kind.TREE`; jeder Eintrag mit `TIRES` hat `square.distance_from_center(item["position"]) >= 180.0`
- `test_echte_strecke`: `var path := TrackPath.new(TrackPath.smooth_closed(TrackCatalog.points_of("hafen"), 10), 280.0)` → `TrackDecor.build(path).size() > 10`; für keinen Eintrag ist `path.is_on_track(item["position"])` wahr

Review (16.10.2026): gemergt.
