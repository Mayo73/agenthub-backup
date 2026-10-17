---
id: T-0160
title: Nahrung als Bild zeichnen (FoodView)
project: zellenphase
priority: 3
after: A-0008, A-0009
---
## Ziel
Pflanzen- und Fleischnahrung werden mit den Higgsfield-Bildern `assets/food/pflanze.png` und `assets/food/fleisch.png` gezeichnet statt als einfache Kreise (Lastenheft: Platzhalter ersetzen; Nahrung muss unterscheidbar bleiben).

## Dateien
- `scripts/food_view.gd`
- `tests/test_food_view_bild.gd`: neu

## Akzeptanzkriterien
In `scripts/food_view.gd`:
- Unter den vorhandenen Farbkonstanten:
```gdscript
const PLANT_TEXTURE: Texture2D = preload("res://assets/food/pflanze.png")
const MEAT_TEXTURE: Texture2D = preload("res://assets/food/fleisch.png")
## Das Bild ist etwas größer als der Berührungsradius, weil es einen weichen Rand hat.
const SPRITE_SCALE := 1.4
```
- Neue statische Funktionen am Ende:
```gdscript
static func texture_for(kind: String) -> Texture2D:
	return PLANT_TEXTURE if kind == Diet.PFLANZE else MEAT_TEXTURE


## Rechteck, in das das Bild eines Nahrungsstücks gezeichnet wird (Mitte = Lage des Stücks).
static func sprite_rect(item: FoodItem) -> Rect2:
	var half := item.radius * SPRITE_SCALE
	return Rect2(item.position - Vector2(half, half), Vector2(half, half) * 2.0)
```
- In `_draw()` die Zeile mit `draw_circle(...)` ersetzen durch:
```gdscript
		draw_texture_rect(texture_for(item.kind), sprite_rect(item), false)
```
- Die Farbkonstanten bleiben stehen; sonst nichts ändern.

## Tests
`tests/test_food_view_bild.gd` mit `extends "res://tests/base_test.gd"`:
- `test_bilder`: `FoodView.texture_for(Diet.PFLANZE) != null` wahr; `FoodView.texture_for(Diet.FLEISCH) != null` wahr; `FoodView.texture_for(Diet.PFLANZE) != FoodView.texture_for(Diet.FLEISCH)` wahr
- `test_rechteck`: `var r := FoodView.sprite_rect(FoodItem.new(Diet.PFLANZE, Vector2(10, 20), 1, 5.0))` → `r.position` ist `Vector2(3, 13)`; `r.size` ist `Vector2(14, 14)`
- `test_mitte`: `FoodView.sprite_rect(FoodItem.new(Diet.FLEISCH, Vector2(-4, 8), 2, 6.0)).get_center()` ist `Vector2(-4, 8)`

Review (16.10.2026): gemergt.
