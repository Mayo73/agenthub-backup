---
id: T-0184
title: KI-Zellen bekommen ein Auge, das in Schwimmrichtung schaut
project: zellenphase
priority: 3
after: T-0177, T-0172
---
## Ziel
KI-Zellen wirken lebendiger mit einem Auge, dessen Pupille dorthin schaut, wohin die Zelle schwimmen will (`wish`): zur Beute, zur Nahrung oder weg von der Gefahr.

## Dateien
- `scripts/ai_cell.gd`
- `tests/test_ai_cell.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
In `scripts/ai_cell.gd`:
- Neue Funktion direkt über `func _draw()`:
```gdscript
## Blickrichtung der Pupille in Zellkoordinaten (die Zelle ist um motion.heading gedreht).
func pupil_dir() -> Vector2:
	return wish.rotated(-motion.heading)
```
- Am Ende von `_draw()` (nach der Zeile, die das Maul mit `draw_circle(Vector2(radius * 0.8 * look.stretch, 0), …)` zeichnet, und nach der Überlagerung des Aufblitzens):
```gdscript
	var eye_pos := Vector2(radius * 0.35 * look.stretch, -radius * 0.35)
	var eye_r := radius * 0.16
	draw_circle(eye_pos, eye_r, Color.WHITE)
	draw_circle(eye_pos + EyeLook.pupil_offset(pupil_dir(), eye_r), eye_r * 0.5, Color(0.05, 0.05, 0.1))
```
- Sonst nichts ändern.

## Tests
In `tests/test_ai_cell.gd` anhängen; jeder Test legt seine Zelle selbst an und gibt sie am Ende mit `free()` frei:
- `test_blick_geradeaus`: `var c := AiCell.new()`, `c.setup("blasenling", Vector2.ZERO)`, `c.motion.heading = 0.0`, `c.wish = Vector2(0, 1)` → `c.pupil_dir().is_equal_approx(Vector2(0, 1))` wahr
- `test_blick_gedreht`: wie oben, aber `c.motion.heading = PI / 2.0` → `c.pupil_dir().is_equal_approx(Vector2(1, 0))` wahr
- `test_kein_ziel`: `var c := AiCell.new()`, `c.setup("blasenling", Vector2.ZERO)` → `c.pupil_dir() == Vector2.ZERO` wahr

Review (17.10.2026): gemergt.
