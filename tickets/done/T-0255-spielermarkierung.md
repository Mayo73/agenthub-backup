---
id: T-0255
title: Leuchtender Ring markiert das eigene Auto
project: drift
priority: 2
after: T-0254
---
## Ziel
Beim Ansehen der Rennbilder war das eigene Auto nicht von einem gleichfarbigen Gegner zu unterscheiden (bei drei Autos fährt ein Gegner immer dasselbe Modell). Ein heller Ring auf dem Boden unter dem Spielerauto macht es auf einen Blick erkennbar. Der Ring liegt unter `World` und wird in Weltkoordinaten gezeichnet; durch die isometrische Schräge erscheint er als flache Ellipse.

## Dateien
- `scripts/player_marker.gd` – neu
- `scripts/main.gd`
- `tests/test_player_marker.gd` – neu

## Akzeptanzkriterien
- Neue Datei `scripts/player_marker.gd`:
```gdscript
class_name PlayerMarker
extends Node2D
## Heller Ring auf dem Boden unter dem Spielerauto, damit man es von gleichfarbigen Gegnern unterscheidet.
## Liegt unter "World" (Weltkoordinaten) und folgt dem Auto in target.

const RADIUS := 34.0
const WIDTH := 5.0
const COLOR := Color(1.0, 0.92, 0.3, 0.9)
const FILL := Color(1.0, 0.92, 0.3, 0.18)

var target: Node2D


## Übernimmt die Lage des Autos (ohne Drehung, der Ring ist rund).
func follow() -> void:
	if target:
		position = target.position


func _process(_delta: float) -> void:
	follow()


func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, FILL)
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 48, COLOR, WIDTH, true)
```
- In `scripts/main.gd`: unter `var ghost: Node2D` die Zeile `var player_marker: PlayerMarker`. In `_ready()` direkt nach der Zeile `world.move_child(ghost, car.get_index())`:
```gdscript

	player_marker = PlayerMarker.new()
	player_marker.name = "PlayerMarker"
	player_marker.target = car
	world.add_child(player_marker)
	world.move_child(player_marker, car.get_index())
	player_marker.follow()
```
- Sonst nichts ändern.

## Tests
`tests/test_player_marker.gd` (neu, `extends "res://tests/base_test.gd"`), Aufbau wie `tests/test_main_wiring.gd` (Hauptszene laden, an die Wurzel hängen, in `teardown()` freigeben):
- `test_vorhanden`: `main.world.get_node("PlayerMarker") is PlayerMarker` wahr; `main.player_marker.target == main.car` wahr
- `test_unter_dem_auto`: `main.player_marker.get_index() < main.car.get_index()` wahr
- `test_folgt`: `main.car.position = Vector2(300, 120)`; `main.player_marker.follow()` → `main.player_marker.position` ist `Vector2(300, 120)`; `main.player_marker.rotation` ist `0.0`
- `test_ohne_ziel`: `var m := PlayerMarker.new()`; `m.follow()` → `m.position` ist `Vector2.ZERO`; `m.free()`

Review (17.10.2026): gemergt.
