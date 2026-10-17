---
id: T-0059
title: Countdown-Töne (race_sounds.gd)
project: drift
priority: 3
after: T-0054
---
## Ziel
Ein kleiner Node spielt beim Start einen Ton für „3“, „2“, „1“ und einen höheren für „Los!“. Eingebaut in die Rennszene wird er in einem späteren Ticket.

## Dateien
- `scripts/race_sounds.gd`: neu
- `tests/test_race_sounds.gd`: neu

## Akzeptanzkriterien
Genau dieser Code in `scripts/race_sounds.gd`:
```gdscript
extends Node
## Spielt die Countdown-Töne. update() einmal pro Physik-Schritt mit dem RaceState aufrufen.

var beep_player: AudioStreamPlayer
var go_player: AudioStreamPlayer
var last_text := ""
var beeps := 0
var gos := 0


func _init() -> void:
	beep_player = AudioStreamPlayer.new()
	beep_player.name = "Beep"
	beep_player.stream = SoundBank.beep()
	add_child(beep_player)
	go_player = AudioStreamPlayer.new()
	go_player.name = "Go"
	go_player.stream = SoundBank.go_beep()
	add_child(go_player)


## Spielt einen Ton, sobald sich der Countdown-Text ändert.
func update(race: RaceState) -> void:
	var text := race.countdown_text()
	if text == last_text:
		return
	last_text = text
	if text == "Los!":
		gos += 1
		if go_player.is_inside_tree():
			go_player.play()
	elif text != "":
		beeps += 1
		if beep_player.is_inside_tree():
			beep_player.play()


## Für einen Neustart: Der nächste Countdown piept wieder von vorn.
func reset() -> void:
	last_text = ""
```

## Tests
Neue Datei `tests/test_race_sounds.gd` mit `extends "res://tests/base_test.gd"`, Variablen `var sounds: Node` und `var race: RaceState`:
```gdscript
func setup() -> void:
	sounds = preload("res://scripts/race_sounds.gd").new()
	(Engine.get_main_loop() as SceneTree).root.add_child(sounds)
	race = RaceState.new()


func teardown() -> void:
	sounds.free()
	sounds = null
```
- `test_countdown`: `sounds.update(race)` → `sounds.beeps` ist 1; noch einmal `sounds.update(race)` → weiterhin 1. Dann sechsmal hintereinander `race.update(0.5)` und danach jeweils `sounds.update(race)` → `sounds.beeps` ist 3, `sounds.gos` ist 1
- `test_neustart`: `sounds.update(race)`, `sounds.reset()` → `sounds.last_text` ist `""`; `sounds.update(race)` → `sounds.beeps` ist 2
- `test_knoten`: `sounds.get_node("Beep") is AudioStreamPlayer` ist wahr, `sounds.get_node("Go") is AudioStreamPlayer` ist wahr

Review (16.10.2026): gemergt.
