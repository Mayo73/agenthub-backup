---
id: T-0252
title: Fischphase – Fressen und Wachsen in der Fischszene
project: zellenphase
priority: 3
after: T-0249, T-0251
---
## Ziel
In der Fischszene liegt Nahrung im 3D-Raum. Berührt das Maul des Fischs passende Nahrung, frisst er sie: DNA und Wachstum steigen, und nach genug Wachstum wird der Fisch sichtbar größer. Nahrung, die weit weg ist, verschwindet; neue wird um den Fisch gestreut.

## Dateien
- `scripts/fish_main.gd`
- `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- In `scripts/fish_main.gd`:
  - direkt unter `extends Node3D` und den Kommentarzeilen darunter (vor `## Spielwelt: …`) einfügen:
```gdscript
## Reichweite des Mauls beim Fressen in Metern (wächst mit der Größe des Fischs).
const MOUTH_REACH := 0.5

```
  - unter `var progress := FishProgress.new()` einfügen:
```gdscript
var food := FishFood.new()
var food_view: FishFoodView
```
  - in `_ready()` direkt nach `world.add_child(reef)` einfügen:
```gdscript
	food.spawn_around(FishWorld.START, 60, 5.0, 60.0, 0.3)
	food_view = FishFoodView.new()
	food_view.name = "Food"
	food_view.field = food
	world.add_child(food_view)
```
  - `_physics_process()` endet danach so (zwei Zeilen am Ende ergänzen):
```gdscript
func _physics_process(delta: float) -> void:
	player.drive(FishInput.read(), delta)
	hud.show_depth(player.motion.depth())
	feed_player()
	refill_food()
```
  - nach `_process()` einfügen:
```gdscript


## Frisst, was das Maul berührt und zur Ernährung passt. Wächst der Fisch, wird er größer.
func feed_player() -> void:
	for item in food.take_at(player.mouth_point(), MOUTH_REACH * player.size, player.build.diet):
		if progress.eat(item["value"]):
			player.set_size(progress.size())
			hud.show_message("Dein Fisch ist gewachsen!")
	hud.show_progress(progress)


## Entfernt weit entfernte Nahrung und streut neue um den Fisch, wenn sie knapp wird.
func refill_food() -> void:
	food.remove_far(player.motion.position, 90.0)
	if food.items.size() < 40:
		food.spawn_around(player.motion.position, 20, 15.0, 70.0, 0.3)
```
- Sonst nichts ändern.

## Tests
In `tests/test_fish_main.gd` am Ende anhängen (der Spielerfisch ist ohne Übergabe Pflanzenfresser und steht bei `FishWorld.START` mit Blick nach -z, sein Maul liegt bei `FishWorld.START + Vector3(0, 0, -0.8)`):
- `test_nahrung_da`: `fish.food.items.size()` ist 60; `fish.get_node("World/Food") is FishFoodView` wahr
- `test_fressen`: `fish.food.items.clear()`; `fish.food.add_item(Diet.PFLANZE, FishWorld.START + Vector3(0, 0, -1))`; `fish.feed_player()` → `fish.progress.dna` ist 2; `fish.food.items.size()` ist 0; `fish.hud.dna_label.text` ist `"DNA: 2"`
- `test_falsche_nahrung`: `fish.food.items.clear()`; `fish.food.add_item(Diet.FLEISCH, FishWorld.START + Vector3(0, 0, -1))`; `fish.feed_player()` → `fish.progress.dna` ist 0; `fish.food.items.size()` ist 1
- `test_wachsen`: `fish.food.items.clear()`; `fish.progress.growth = 19`; `fish.food.add_item(Diet.PFLANZE, FishWorld.START + Vector3(0, 0, -1))`; `fish.feed_player()` → `fish.progress.stage` ist 1; `fish.player.size` ist 1.4; `fish.player.model.scale` ist `Vector3(1.4, 1.4, 1.4)`; `fish.hud.message_label.visible` wahr
- `test_nachstreuen`: `fish.food.items.clear()`; `fish.refill_food()` → `fish.food.items.size()` ist 20

Review (17.10.2026): gemergt.
