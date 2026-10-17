---
id: T-0067
title: Motorgeräusch der KI-Autos
project: drift
priority: 5
after: T-0046, T-0057
model: qwen3.5:27b
timeout_minutes: 60
---
## Ziel
Auch die KI-Gegner brummen, etwas leiser als das Spielerauto; die Tonhöhe folgt ihrem Tempo.

## Dateien
- `scripts/ai_car.gd`
- `tests/test_ai_car.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Neue Variable (unter `var driving_enabled`): `var engine_player: AudioStreamPlayer2D`
- Neue Funktion `_ready()` (gibt es schon eine, den Inhalt dort am Ende einfügen):
```gdscript
func _ready() -> void:
	engine_player = AudioStreamPlayer2D.new()
	engine_player.name = "Engine"
	engine_player.stream = SoundBank.engine_loop()
	engine_player.volume_db = -12.0
	engine_player.max_distance = 1500.0
	add_child(engine_player)
	engine_player.play()
```
- In `_physics_process` ganz am Ende:
```gdscript
	if engine_player:
		engine_player.pitch_scale = EngineAudio.pitch_for(physics.speed(), physics.max_speed)
```
- Sonst nichts ändern.

## Tests
In `tests/test_ai_car.gd` neue Methode `test_motorgeraeusch`:
- `(Engine.get_main_loop() as SceneTree).root.add_child(ai)` (damit `_ready()` läuft)
- `ai.get_node("Engine") is AudioStreamPlayer2D` ist wahr; `ai.engine_player.stream is AudioStreamWAV` ist wahr
- `ai.place_at(ai.track.start_position(), ai.track.start_heading())`, dann `ai.physics.velocity = Vector2.from_angle(ai.physics.heading) * ai.physics.max_speed`, `ai._physics_process(0.0)` → `ai.engine_player.pitch_scale > 1.9`

Review (16.10.2026): gemergt.
