---
id: T-0058
title: Reifenquietschen beim Driften
project: drift
priority: 3
after: T-0057
---
## Ziel
Beim Driften quietschen die Reifen, umso lauter, je querer das Auto steht. Ohne Drift ist das Quietschen stumm.

## Dateien
- `scripts/car.gd`
- `tests/test_car_sound.gd`: Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Neue Variable in `car.gd` (unter `var engine_player`): `var squeal_player: AudioStreamPlayer2D`
- Am **Ende** von `_ready()` (nach `engine_player.play()`):
```gdscript
	squeal_player = AudioStreamPlayer2D.new()
	squeal_player.name = "Squeal"
	squeal_player.stream = SoundBank.squeal_loop()
	squeal_player.volume_db = EngineAudio.SILENT_DB
	add_child(squeal_player)
	squeal_player.play()
```
- In `update_sound()` als letzte Zeilen:
```gdscript
	if squeal_player:
		squeal_player.volume_db = EngineAudio.squeal_db(physics.is_drifting(), physics.slip_angle_deg())
```
- Sonst nichts an `car.gd` ändern.

## Tests
In `tests/test_car_sound.gd` anhängen:
- `test_quietschen_vorhanden`: `car.get_node("Squeal") is AudioStreamPlayer2D` ist wahr; `car.squeal_player.volume_db` ist -80.0
- `test_quietschen_im_drift`: `car.physics.heading = 0.0`, `car.physics.velocity = Vector2(300.0, 300.0)`, `car.physics.sliding = true`, `car.update_sound()` → `absf(car.squeal_player.volume_db - (-6.0)) < 0.01`
- `test_kein_quietschen_ohne_drift`: `car.physics.heading = 0.0`, `car.physics.velocity = Vector2(300.0, 0.0)`, `car.physics.sliding = false`, `car.update_sound()` → `car.squeal_player.volume_db` ist -80.0

Review (16.10.2026): gemergt.
