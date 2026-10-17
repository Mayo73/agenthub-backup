---
id: T-0144
title: Musik, Wasserrauschen und Klänge abspielen (GameAudio)
project: zellenphase
priority: 3
after: T-0141, T-0142, T-0143
---
## Ziel
Ein Node, der Musik und Wasserrauschen in Schleife abspielt und Spielklänge über ihren Namen auslöst. Musik läuft über den Bus „Musik“, alles andere über „Effekte“.

## Dateien
- `scripts/game_audio.gd`: neu
- `tests/test_game_audio.gd`: neu

## Akzeptanzkriterien
`scripts/game_audio.gd` genau so:
```gdscript
class_name GameAudio
extends Node
## Spielt Musik, Wasserrauschen und Klänge. Klänge werden über ihren Namen aus CellSounds.all() abgespielt.

const VOICES := 6

var streams: Dictionary = {}
var music: AudioStreamPlayer
var ambience: AudioStreamPlayer
var voices: Array[AudioStreamPlayer] = []
var next_voice := 0
var last_played := ""
var play_count := 0


func _init() -> void:
	AudioBuses.ensure()
	streams = CellSounds.all()
	music = AudioStreamPlayer.new()
	music.name = "Music"
	music.bus = AudioBuses.MUSIC
	music.stream = CellMusic.theme()
	add_child(music)
	ambience = AudioStreamPlayer.new()
	ambience.name = "Ambience"
	ambience.bus = AudioBuses.SFX
	ambience.stream = CellSounds.water_loop()
	ambience.volume_db = -12.0
	add_child(ambience)
	for i in VOICES:
		var p := AudioStreamPlayer.new()
		p.name = "Voice%d" % i
		p.bus = AudioBuses.SFX
		add_child(p)
		voices.append(p)


func _ready() -> void:
	music.play()
	ambience.play()


## Spielt den Klang sound_name auf der nächsten Stimme (reihum). false bei unbekanntem Namen.
func play(sound_name: String) -> bool:
	if not streams.has(sound_name):
		return false
	var p := voices[next_voice]
	next_voice = (next_voice + 1) % VOICES
	p.stream = streams[sound_name]
	if p.is_inside_tree():
		p.play()
	last_played = sound_name
	play_count += 1
	return true
```

## Tests
`tests/test_game_audio.gd` mit `extends "res://tests/base_test.gd"`, `var audio: GameAudio`; `setup()`: `audio = GameAudio.new()`; `teardown()`: `audio.free()`.
- `test_aufbau`: `audio.streams.size()` ist 8; `audio.voices.size()` ist 6; `str(audio.music.bus)` ist `"Musik"`; `str(audio.voices[0].bus)` ist `"Effekte"`; `(audio.music.stream as AudioStreamWAV).loop_mode == AudioStreamWAV.LOOP_FORWARD` wahr
- `test_abspielen`: `audio.play("treffer")` wahr → `audio.last_played` ist `"treffer"`; `audio.play_count` ist 1; `audio.voices[0].stream == audio.streams["treffer"]` wahr; `audio.next_voice` ist 1
- `test_unbekannt`: `audio.play("gibtsnicht")` falsch; `audio.play_count` ist 0; `audio.last_played` ist `""`
- `test_reihum`: 7-mal `audio.play("klick")` → `audio.next_voice` ist 1; `audio.play_count` ist 7

Review (16.10.2026): gemergt.
