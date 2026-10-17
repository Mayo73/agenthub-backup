---
id: T-0073
title: KI-Autos mit Bild statt Polygon
project: drift
priority: 2
after: T-0071, T-0067
---
## Ziel
Die KI-Autos zeichnen sich mit einem Autobild aus dem `CarCatalog` und einem Schatten statt als einfarbiges Polygon.

## Dateien
- `scripts/ai_car.gd`
- `tests/test_ai_car.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Neue Variablen in `ai_car.gd` direkt unter `var color := …`: `var car_id := ""` und `var texture: Texture2D`
- Neue Funktion direkt vor `_physics_process`:
```gdscript
## Wählt das Auto (Bild) aus dem CarCatalog. Unbekannte IDs werden ignoriert.
func set_car(id: String) -> void:
	if not CarCatalog.has_car(id):
		return
	car_id = id
	texture = load(CarCatalog.sprite_of(id)) as Texture2D
	queue_redraw()
```
- `_draw()` wird zu:
```gdscript
func _draw() -> void:
	var shadow := PackedVector2Array()
	for p in BODY:
		shadow.append(p + Vector2(5, 5))
	draw_colored_polygon(shadow, Color(0, 0, 0, 0.35))
	if texture:
		draw_texture_rect(texture, Rect2(-26, -12, 52, 24), false)
	else:
		draw_colored_polygon(PackedVector2Array(BODY), color)
```
- Sonst nichts an `ai_car.gd` ändern.

## Tests
In `tests/test_ai_car.gd` neue Methode `test_auto_waehlen`:
- vor dem Aufruf ist `ai.texture == null`
- `ai.set_car("drifter")` → `ai.car_id` ist `"drifter"`, `ai.texture.resource_path` ist `"res://assets/cars/car_drifter.png"`
- `ai.set_car("gibtsnicht")` → `ai.car_id` bleibt `"drifter"`

Review (16.10.2026): gemergt.
