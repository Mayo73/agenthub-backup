---
id: T-0173
title: Augen der Spielerzelle mit Pupille und Blinzeln zeichnen
project: zellenphase
priority: 2
after: T-0171, T-0172
---
## Ziel
Eingebaute Augen der Spielerzelle werden als weißer Augapfel mit dunkler Pupille gezeichnet, die in Schwimmrichtung schaut, und blinzeln ab und zu. Das Stielauge sitzt auf einem Stiel. Die übrigen Teile bleiben wie bisher.

## Dateien
- `scripts/player_cell.gd`
- `tests/test_player_cell.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
In `scripts/player_cell.gd`:
- In `_draw()` die zweite Schleife (zeichnet alle Teile außer Antrieben):
```gdscript
	for part in build.parts:
		if PartCatalog.category_of(part["id"]) != "antrieb":
			draw_colored_polygon(PartShapes.placed(part, radius), PartShapes.color_of(part["id"]))
```
  ersetzen durch:
```gdscript
	for part in build.parts:
		var category := PartCatalog.category_of(part["id"])
		if category == "auge":
			draw_eye(part)
		elif category != "antrieb":
			draw_colored_polygon(PartShapes.placed(part, radius), PartShapes.color_of(part["id"]))
```
- Neue Funktionen am Ende:
```gdscript
## Auge mit Pupille in Schwimmrichtung (+x), blinzelt ab und zu; das Stielauge mit Stiel.
func draw_eye(part: Dictionary) -> void:
	var pos: Vector2 = part["pos"]
	var center := EyeLook.eye_center(part, radius)
	var eye_r := EyeLook.eye_radius(part["id"], radius)
	if part["id"] == "stielauge":
		draw_line(pos * radius, center, look.color.darkened(0.3), maxf(1.0, radius * 0.06))
	draw_set_transform(center, 0.0, Vector2(1.0, eye_openness(part)))
	draw_circle(Vector2.ZERO, eye_r, Color.WHITE)
	draw_circle(EyeLook.pupil_offset(Vector2.RIGHT, eye_r), eye_r * 0.5, Color(0.05, 0.05, 0.1))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Wie weit ein Auge gerade offen ist; jedes Auge blinzelt etwas versetzt.
func eye_openness(part: Dictionary) -> float:
	var pos: Vector2 = part["pos"]
	return EyeLook.openness(time, pos.y)
```
- Sonst nichts ändern.

## Tests
In `tests/test_player_cell.gd` anhängen:
- `test_auge_offen`: `cell.drive(1.0, Vector2.ZERO)` → `cell.eye_openness({"id": "knopfauge", "pos": Vector2(0.5, 0.0), "angle": 0.0})` ist 1.0
- `test_auge_blinzelt`: `cell.drive(0.05, Vector2.ZERO)` → `cell.eye_openness({"id": "knopfauge", "pos": Vector2(0.5, 0.0), "angle": 0.0})` ist 0.1
- `test_auge_versetzt`: `cell.drive(0.05, Vector2.ZERO)` → `cell.eye_openness({"id": "knopfauge", "pos": Vector2(0.5, 1.0), "angle": 0.0})` ist 1.0

Review (16.10.2026): gemergt.
