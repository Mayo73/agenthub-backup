---
id: T-0161
title: Teilefund als Bild zeichnen (PickupView)
project: zellenphase
priority: 5
after: A-0010
model: qwen3.5:27b
timeout_minutes: 60
---
## Ziel
Teilefunde werden mit dem Higgsfield-Bild `assets/pickups/teilefund.png` (leuchtende Kugel) gezeichnet statt als Raute. Die Größe pulsiert weiter wie bisher.

## Dateien
- `scripts/pickup_view.gd`
- `tests/test_pickup_view_bild.gd`: neu

## Akzeptanzkriterien
In `scripts/pickup_view.gd`:
- Unter `const COLOR := ...`:
```gdscript
const TEXTURE: Texture2D = preload("res://assets/pickups/teilefund.png")
## Das Bild ist etwas größer als der Berührungsradius, weil es einen leuchtenden Rand hat.
const SPRITE_SCALE := 1.3
```
- Neue statische Funktion am Ende:
```gdscript
## Rechteck für das Bild eines Fundes bei pos; pulsiert mit der Zeit t wie diamond().
static func sprite_rect(pos: Vector2, t: float) -> Rect2:
	var s := PartPickups.RADIUS * (1.0 + 0.2 * sin(t * 4.0)) * SPRITE_SCALE
	return Rect2(pos - Vector2(s, s), Vector2(s, s) * 2.0)
```
- In `_draw()` die Zeile `draw_colored_polygon(diamond(p, time), COLOR)` ersetzen durch `draw_texture_rect(TEXTURE, sprite_rect(p, time), false)`.
- `diamond()` und `COLOR` bleiben stehen (vorhandene Tests nutzen sie); sonst nichts ändern.

## Tests
`tests/test_pickup_view_bild.gd` mit `extends "res://tests/base_test.gd"`:
- `test_bild`: `PickupView.TEXTURE != null` wahr
- `test_rechteck`: `var r := PickupView.sprite_rect(Vector2(100, 50), 0.0)` → `r.size.x` ist `PartPickups.RADIUS * 2.0 * 1.3`; `r.get_center()` ist `Vector2(100, 50)`
- `test_pulsieren`: `PickupView.sprite_rect(Vector2.ZERO, PI / 8).size.x` ist `PartPickups.RADIUS * 1.2 * 2.0 * 1.3`

Review (16.10.2026): gemergt, Merge-Konflikt mit T-0109 in pickup_view.gd aufgelöst.
