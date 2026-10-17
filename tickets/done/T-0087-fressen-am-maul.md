---
id: T-0087
title: Fressen nur mit dem Maul (MouthContact, take_at)
project: zellenphase
priority: 4
after: T-0086
---
## Ziel
Nahrung wird nur aufgenommen, wenn das Maul (vorn am Zellrand in Blickrichtung) sie berührt und die Ernährungsart passt. Was hinter der Zelle liegt, zählt nicht.

## Dateien
- `scripts/mouth_contact.gd`: neu
- `scripts/food_field.gd`: neue Funktion am Ende
- `tests/test_mouth_contact.gd`: neu
- `tests/test_food_field.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `scripts/mouth_contact.gd` genau so:
```gdscript
class_name MouthContact
extends RefCounted
## Berührungen mit dem Maul: Nur was vorn am Maul liegt, zählt.


## Lage des Mauls: vorn auf dem Zellrand in Blickrichtung.
static func mouth_point(center: Vector2, heading: float, radius: float) -> Vector2:
	return center + Vector2.from_angle(heading) * radius


## Berührt das Maul mit Reichweite reach den Kreis um target mit target_radius?
static func touches(mouth: Vector2, reach: float, target: Vector2, target_radius: float) -> bool:
	return mouth.distance_to(target) <= reach + target_radius
```
- `scripts/food_field.gd`, neue Funktion am Ende:
```gdscript
## Entfernt alle Stücke, die das Maul berührt und die zur Ernährung passen, und gibt sie zurück.
func take_at(mouth: Vector2, reach: float, diet: String) -> Array[FoodItem]:
	var taken: Array[FoodItem] = []
	for item in items:
		if Diet.can_eat(diet, item.kind) and MouthContact.touches(mouth, reach, item.position, item.radius):
			taken.append(item)
	for item in taken:
		items.erase(item)
	return taken
```

## Tests
- `tests/test_mouth_contact.gd` mit `extends "res://tests/base_test.gd"`:
  - `test_maulpunkt`: `MouthContact.mouth_point(Vector2.ZERO, 0.0, 10.0)` ist (10, 0); `MouthContact.mouth_point(Vector2(5, 5), PI / 2, 10.0).is_equal_approx(Vector2(5, 15))` ist wahr
  - `test_beruehren`: `MouthContact.touches(Vector2.ZERO, 4.0, Vector2(8, 0), 5.0)` wahr; mit `Vector2(10, 0)` falsch
- `tests/test_food_field.gd`, neue Methode `test_fressen_am_maul`: Feld mit `add_item(Diet.PFLANZE, Vector2(12, 0))` und `add_item(Diet.FLEISCH, Vector2(13, 0))`:
  - `take_at(Vector2(10, 0), 4.0, Diet.PFLANZENFRESSER)` hat Größe 1 und `[0].kind == Diet.PFLANZE`; danach `items.size()` ist 1
  - `take_at(Vector2(-30, 0), 4.0, Diet.FLEISCHFRESSER)` hat Größe 0 (Fleisch liegt nicht am Maul)
  - `take_at(Vector2(10, 0), 4.0, Diet.ALLESFRESSER)` hat Größe 1; danach `items.size()` ist 0

Review (16.10.2026): gemergt.
