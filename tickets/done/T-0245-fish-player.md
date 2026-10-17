---
id: T-0245
title: Fischphase – Spielerfisch (FishPlayer)
project: zellenphase
priority: 3
after: T-0241, T-0244
---
## Ziel
Der Spielerfisch verbindet Bewegung (`FishMotion`) und Aussehen (`FishModel`): Er schwimmt nach den Befehlen aus `FishInput`, richtet sich in Schwimmrichtung aus, wächst mit `set_size()` und kennt seine Maulspitze für das Fressen.

## Dateien
- `scripts/fish_player.gd` – neu
- `tests/test_fish_player.gd` – neu

## Akzeptanzkriterien
`scripts/fish_player.gd` genau so:
```gdscript
class_name FishPlayer
extends Node3D
## Spielerfisch: bewegt sich mit FishMotion und zeigt sich als FishModel.

var motion := FishMotion.new()
var build := FishBuild.new()
var model: FishModel
## Größe (1 = Anfang); skaliert das Modell.
var size := 1.0


func _init() -> void:
	model = FishModel.new()
	model.name = "Model"
	add_child(model)
	model.rebuild(build)
	sync()


## Übernimmt einen neuen Ausbau (Übergang, Entwicklung) und baut das Aussehen neu.
func set_build(b: FishBuild) -> void:
	build = b
	model.rebuild(b)


func set_size(s: float) -> void:
	size = s
	model.scale = Vector3.ONE * s


## Ein Schritt mit dem Schwimmbefehl aus FishInput: command = Vector3(thrust, turn, climb).
func drive(command: Vector3, delta: float) -> void:
	motion.step(command.x, command.y, command.z, delta)
	sync()
	model.animate(delta, motion.speed())


## Überträgt Lage und Ausrichtung aus FishMotion auf den Knoten.
func sync() -> void:
	position = motion.position
	rotation = Vector3(motion.pitch, motion.yaw, 0.0)


## Maulspitze in Weltkoordinaten (vorn am Körper), für Fressen und Beißen.
func mouth_point() -> Vector3:
	return motion.position + motion.forward() * 0.8 * size
```
- Keine andere Datei ändern.

## Tests
`tests/test_fish_player.gd` mit `extends "res://tests/base_test.gd"`, `var fish: FishPlayer`; `setup()`: `fish = FishPlayer.new()`; `teardown()`: `fish.free()`:
- `test_start`: `fish.position` ist `FishWorld.START`; `fish.get_node("Model") is FishModel` wahr; `fish.size` ist 1.0
- `test_schwimmen`: `fish.drive(Vector3(1, 0, 0), 0.1)` → `fish.position.z < 0.0` wahr; `fish.position` ist `fish.motion.position`
- `test_ausrichtung`: `fish.drive(Vector3(0, 1, 1), 0.5)` → `fish.rotation.y` ist `fish.motion.yaw`; `fish.rotation.x` ist `fish.motion.pitch`; `fish.rotation.x > 0.0` wahr
- `test_ausbau`: `var b := FishBuild.new()`; `b.upgrade("schwanz")`; `b.upgrade("schwanz")`; `fish.set_build(b)` → `fish.build.level("schwanz")` ist 2; `fish.model.build == b` wahr
- `test_groesse`: `fish.set_size(2.0)` → `fish.model.scale` ist `Vector3(2, 2, 2)`; `fish.mouth_point().is_equal_approx(FishWorld.START + Vector3(0, 0, -1.6))` wahr
- `test_maul`: `fish.mouth_point().is_equal_approx(FishWorld.START + Vector3(0, 0, -0.8))` wahr

Review (17.10.2026): gemergt.
