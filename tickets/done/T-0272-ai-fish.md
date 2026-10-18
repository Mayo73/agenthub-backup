---
id: T-0272
title: AiFish – ein KI-Fisch als 3D-Knoten
project: zellenphase
priority: 4
after: T-0270
---
## Ziel
Meilenstein „Fischphase – Leben im Meer“: Ein KI-Fisch übernimmt die Werte seiner Art, sieht aus wie ein Fisch (`FishModel` in seiner Farbe und Größe, Raubfische mit Kiefer) und schwimmt nach `FishBrain`.

## Dateien
- `scripts/ai_fish.gd` – neu
- `tests/test_ai_fish.gd` – neu

## Akzeptanzkriterien
Neue Datei `scripts/ai_fish.gd`:
```gdscript
class_name AiFish
extends Node3D
## KI-Fisch der Fischphase: Werte aus FishSpecies, Aussehen aus FishModel, Verhalten aus FishBrain.

var species_id := ""
var motion := FishMotion.new()
var health := CellHealth.new()
var size := 1.0
var model: FishModel


func _init() -> void:
	model = FishModel.new()
	model.name = "Model"
	add_child(model)


## Übernimmt die Werte der Art und setzt den Fisch an pos.
func setup(id: String, pos: Vector3) -> void:
	species_id = id
	var d := FishSpecies.data(id)
	size = float(d.get("size", 1.0))
	motion.max_speed = float(d.get("speed", 5.0))
	motion.position = FishWorld.clamp_to_water(pos)
	health = CellHealth.new(float(d.get("hp", 30.0)))
	var b := FishBuild.new()
	b.color = d.get("color", b.color)
	if FishSpecies.is_predator(id):
		b.levels["kiefer"] = 2
	model.rebuild(b)
	model.scale = Vector3.ONE * size
	sync()
```
Dazu (selbst schreiben):
- `radius() -> float`: `FishSpecies.radius(species_id)`
- `mouth_point() -> Vector3`: `motion.position + motion.forward() * 0.8 * size`
- `sync() -> void`: `position = motion.position`; `rotation = Vector3(motion.pitch, motion.yaw, 0.0)`
- `think(delta: float, player_pos: Vector3, player_size: float, flock_center: Variant) -> void`: Wunschrichtung mit `FishBrain.decide(behavior, motion.position, size, sight, player_pos, player_size, flock_center)` (`behavior` und `sight` aus `FishSpecies.data(species_id)`), dann `var c := FishBrain.steer(motion, dir)`, `motion.step(c.x, c.y, c.z, delta)`, `health.tick(delta)`, `sync()`, `model.animate(delta, motion.speed())`.

## Tests
Neue Datei `tests/test_ai_fish.gd` (`extends "res://tests/base_test.gd"`), in `setup()` `fish = AiFish.new()`, in `teardown()` `fish.free()`:
- `test_aufsetzen`: `fish.setup("zackenbarsch", Vector3(5, -20, 0))` → `fish.species_id` ist `"zackenbarsch"`; `fish.size` ist 1.8; `fish.motion.max_speed` ist 7.0; `fish.health.max_hp` ist 90.0; `fish.position` ist `Vector3(5, -20, 0)`; `fish.model.scale` ist `Vector3.ONE * 1.8`; `fish.model.build.level("kiefer")` ist 2
- `test_beute_ohne_kiefer`: `fish.setup("silberling", Vector3(0, -20, 0))` → `fish.model.build.level("kiefer")` ist 0; `fish.radius()` ist 0.3 (Toleranz 0,001)
- `test_im_wasser`: `fish.setup("grasfisch", Vector3(0, 5, 0))` → `fish.motion.position.y < 0.0` wahr
- `test_jagt`: `fish.setup("zackenbarsch", Vector3(0, -20, 0))`; `var player := Vector3(0, -20, -10)`; 20-mal `fish.think(0.1, player, 1.0, null)` → Abstand zu `player` kleiner als 10
- `test_flieht`: `fish.setup("grasfisch", Vector3(0, -20, 0))`; `var player := Vector3(0, -20, 5)` (hinter dem Fisch); 20-mal `fish.think(0.1, player, 1.5, null)` → Abstand zu `player` größer als 5
- `test_maul`: `fish.setup("grasfisch", Vector3(0, -20, 0))` → `fish.mouth_point()` ist `Vector3(0, -20, -0.8)` (Toleranz 0,001)

Review (17.10.2026): gemergt.
