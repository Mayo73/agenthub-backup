---
id: T-0075
title: Geisterauto mit halbdurchsichtigem Autobild
project: drift
priority: 5
after: T-0074
model: qwen3.5:27b
timeout_minutes: 60
---
## Ziel
Das Geisterauto zeigt das Bild des gewählten Autos halbdurchsichtig statt eines hellblauen Rechtecks.

## Dateien
- `scripts/ghost_car.gd`
- `scripts/main.gd`
- `tests/test_ghost_car.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `ghost_car.gd`: neue Variable direkt unter den Konstanten: `var texture: Texture2D`. Neue Funktion direkt vor `_draw()`:
```gdscript
## Wählt das Bild des Geisterautos aus dem CarCatalog. Unbekannte IDs werden ignoriert.
func set_car(id: String) -> void:
	if not CarCatalog.has_car(id):
		return
	texture = load(CarCatalog.sprite_of(id)) as Texture2D
	queue_redraw()
```
- `_draw()` wird zu:
```gdscript
func _draw() -> void:
	if texture:
		draw_texture_rect(texture, Rect2(-LENGTH * 0.5, -WIDTH * 0.5, LENGTH, WIDTH), false, COLOR)
	else:
		draw_rect(Rect2(-LENGTH * 0.5, -WIDTH * 0.5, LENGTH, WIDTH), COLOR)
```
- `main.gd`: in `_ready()` direkt nach `ghost.name = "Ghost"` die Zeile `ghost.set_car(GameSettings.car_id)`. Sonst nichts an `main.gd` ändern.

## Tests
In `tests/test_ghost_car.gd` neue Methode `test_auto_bild`:
- vorher ist `ghost.texture == null`
- `ghost.set_car("grip")` → `ghost.texture.resource_path` ist `"res://assets/cars/car_grip.png"`
- `ghost.set_car("gibtsnicht")` → `ghost.texture.resource_path` bleibt `"res://assets/cars/car_grip.png"`

Review (16.10.2026): gemergt.
