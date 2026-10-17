---
id: T-0060
title: Musik und Countdown-Töne in der Rennszene
project: drift
priority: 5
after: T-0048, T-0055, T-0059
model: qwen3.5:27b
timeout_minutes: 60
---
## Ziel
In der Rennszene läuft die Hintergrundmusik, und der Countdown piept. Nach einem Neustart piept er wieder.

## Dateien
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Neue Variablen in `main.gd` (unter `var ai_cars`): `var race_sounds: Node` und `var music: AudioStreamPlayer`
- Am **Ende** von `_ready()`:
```gdscript
	race_sounds = preload("res://scripts/race_sounds.gd").new()
	race_sounds.name = "RaceSounds"
	add_child(race_sounds)
	music = AudioStreamPlayer.new()
	music.name = "Music"
	music.stream = MusicSynth.theme()
	music.volume_db = -14.0
	add_child(music)
	music.play()
```
- In `_physics_process` direkt nach `race.update(delta)`: `race_sounds.update(race)`
- In `restart()` am Ende: `race_sounds.reset()`
- Sonst nichts an `main.gd` ändern.

## Tests
In `tests/test_main_wiring.gd` neue Methode `test_musik_und_countdown`:
- `main.get_node("Music") is AudioStreamPlayer` ist wahr; `main.music.stream is AudioStreamWAV` ist wahr
- `main.get_node("RaceSounds") != null` ist wahr
- `main.race_sounds.update(main.race)` → `main.race_sounds.beeps` ist 1
- `main.restart()` → `main.race_sounds.last_text` ist `""`

Review (16.10.2026): gemergt.
