---
id: T-0088
title: Nahrung zeichnen und im Spiel fressen
project: zellenphase
priority: 4
after: T-0083, T-0085, T-0087
---
## Ziel
In der Hauptszene schwebt Nahrung (grün = Pflanze, rot = Fleisch). Die Spielerzelle frisst passende Nahrung mit dem Maul und bekommt DNA und Wachstum. Nahrung wird nachgefüllt, wenn sie knapp wird.

## Dateien
- `scripts/food_view.gd`: neu
- `scripts/player_cell.gd`
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `scripts/food_view.gd` genau so:
```gdscript
class_name FoodView
extends Node2D
## Zeichnet alle Nahrungsstücke eines FoodField (Platzhalter: Kreise).

const PLANT_COLOR := Color(0.42, 0.8, 0.37)
const MEAT_COLOR := Color(0.85, 0.33, 0.31)

var field: FoodField


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if field == null:
		return
	for item in field.items:
		draw_circle(item.position, item.radius, PLANT_COLOR if item.kind == Diet.PFLANZE else MEAT_COLOR)
```
- `scripts/player_cell.gd`: neue Variable direkt unter `var input_enabled := true`: `var diet := Diet.PFLANZENFRESSER`. Neue Funktion direkt nach `drive`:
```gdscript
func mouth_point() -> Vector2:
	return MouthContact.mouth_point(motion.position, motion.heading, radius)
```
- `scripts/main.gd`:
  - neue Konstante oben: `const MOUTH_REACH := 4.0`
  - neue Variablen unter `var player: PlayerCell`: `var progress := CellProgress.new()`, `var food := FoodField.new(7)`, `var food_view: FoodView`
  - in `_ready()` am Ende:
```gdscript
	food.spawn_around(Vector2.ZERO, 60, 60.0, 900.0, 0.3)
	food_view = FoodView.new()
	food_view.name = "Food"
	food_view.field = food
	world.add_child(food_view)
	world.move_child(food_view, 0)
```
  - neue Funktionen am Ende:
```gdscript
func _physics_process(_delta: float) -> void:
	feed_player()
	refill_food()


## Frisst alles, was das Maul der Spielerzelle berührt und zur Ernährung passt.
func feed_player() -> void:
	for item in food.take_at(player.mouth_point(), MOUTH_REACH, player.diet):
		progress.eat(item.value)


## Entfernt weit entfernte Nahrung und streut neue um den Spieler, wenn sie knapp wird.
func refill_food() -> void:
	food.remove_far(player.position, 1400.0)
	if food.items.size() < 40:
		food.spawn_around(player.position, 20, 500.0, 1200.0, 0.3)
```

## Tests
In `tests/test_main_wiring.gd` anhängen:
- `test_nahrung_angelegt`: `main.food.items.size()` ist 60; `main.food_view.field == main.food` ist wahr; `main.food_view.get_index()` ist 0
- `test_pflanze_fressen`: `main.food.items.clear()`, `main.food.add_item(Diet.PFLANZE, main.player.mouth_point())`, `main.feed_player()` → `main.progress.dna` ist 1, `main.food.items.size()` ist 0
- `test_fleisch_nicht_fressen`: wie oben mit `Diet.FLEISCH` → `main.progress.dna` ist 0, `main.progress.growth` ist 0, `main.food.items.size()` ist 1
- `test_nachfuellen`: `main.food.items.clear()`, `main.refill_food()` → `main.food.items.size()` ist 20

Review (16.10.2026): gemergt.
