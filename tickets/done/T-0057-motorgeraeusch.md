---
id: T-0057
title: Motorgeräusch im Spielerauto
project: drift
priority: 3
after: T-0054, T-0056
---
## Ziel
Das Spielerauto brummt: Ein `AudioStreamPlayer2D` spielt die Motorschleife, Tonhöhe und Lautstärke folgen Tempo und Gas.

## Dateien
- `scripts/car.gd`
- `tests/test_car_sound.gd`: neu

## Akzeptanzkriterien
- Neue Variable in `car.gd` (unter `var car_id`): `var engine_player: AudioStreamPlayer2D`
- Am **Ende** von `_ready()`:
```gdscript
	engine_player = AudioStreamPlayer2D.new()
	engine_player.name = "Engine"
	engine_player.stream = SoundBank.engine_loop()
	engine_player.volume_db = EngineAudio.engine_db(0.0)
	engine_player.pitch_scale = EngineAudio.pitch_for(0.0, physics.max_speed)
	add_child(engine_player)
	engine_player.play()
```
- Neue Funktion am Ende der Datei:
```gdscript


## Passt die Motorklänge an den Fahrzustand an.
func update_sound() -> void:
	if engine_player == null:
		return
	engine_player.pitch_scale = EngineAudio.pitch_for(physics.speed(), physics.max_speed)
	engine_player.volume_db = EngineAudio.engine_db(physics.throttle)
```
- In `_physics_process` als **letzte** Zeile (nach `rotation = physics.heading`): `update_sound()`
- Sonst nichts an `car.gd` ändern.

## Tests
Neue Datei `tests/test_car_sound.gd` mit `extends "res://tests/base_test.gd"` und `var car: Node2D`:
```gdscript
func setup() -> void:
	car = load("res://scenes/car.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(car)


func teardown() -> void:
	car.free()
	car = null
```
- `test_motor_vorhanden`: `car.get_node("Engine") is AudioStreamPlayer2D` ist wahr; `car.engine_player.stream is AudioStreamWAV` ist wahr; `absf(car.engine_player.pitch_scale - 0.6) < 0.001`
- `test_motor_folgt_tempo`: `car.physics.velocity = Vector2(car.physics.max_speed * 0.5, 0.0)`, `car.physics.throttle = 1.0`, `car.update_sound()` → `absf(car.engine_player.pitch_scale - 1.3) < 0.001` und `absf(car.engine_player.volume_db - (-6.0)) < 0.001`

Review (16.10.2026): gemergt, nachgebessert: chinesische Testmeldung eingedeutscht.
