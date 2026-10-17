---
id: T-0183
title: Nahrung schwebt sanft auf und ab
project: zellenphase
priority: 3
---
## Ziel
Nahrungsstücke wirken lebendiger, wenn sie leicht im Wasser schweben. Jedes Stück bewegt sich etwas versetzt auf und ab; die Berührungslage für das Fressen bleibt unverändert (nur die Zeichnung verschiebt sich).

## Dateien
- `scripts/food_view.gd`
- `tests/test_food_view_schweben.gd`: neu

## Akzeptanzkriterien
In `scripts/food_view.gd`:
- Neue Variable direkt unter `var field: FoodField`: `var time := 0.0`
- `_process` ersetzen durch:
```gdscript
func _process(delta: float) -> void:
	time += delta
	queue_redraw()
```
- In `_draw()` die Zeile `draw_texture_rect(texture, sprite_rect(item), false)` ersetzen durch:
```gdscript
		var rect := sprite_rect(item)
		rect.position += bob(item.position, time)
		draw_texture_rect(texture, rect, false)
```
- Neue Funktion am Ende:
```gdscript
## Verschiebung der Zeichnung beim Schweben; jedes Stück ist nach seiner x-Lage versetzt.
static func bob(pos: Vector2, t: float) -> Vector2:
	return Vector2(0, 1.5 * sin(t * 2.0 + pos.x * 0.05))
```
- Sonst nichts ändern.

## Tests
`tests/test_food_view_schweben.gd` mit `extends "res://tests/base_test.gd"`:
- `test_ruhe`: `FoodView.bob(Vector2.ZERO, 0.0).is_equal_approx(Vector2.ZERO)` wahr
- `test_oben`: `FoodView.bob(Vector2.ZERO, PI / 4.0).is_equal_approx(Vector2(0, 1.5))` wahr
- `test_versetzt`: `FoodView.bob(Vector2(10, 0), 0.0).is_equal_approx(FoodView.bob(Vector2(40, 0), 0.0))` falsch
- `test_zeit`: `var v := FoodView.new()`, `v._process(0.5)`, `v._process(0.25)` → `v.time` ist 0.75; danach `v.free()`

Review (17.10.2026): gemergt.
