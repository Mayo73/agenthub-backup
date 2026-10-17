---
id: T-0239
title: Fischphase – Knopf „Weiter zur Fischphase“ und Szenenwechsel
project: zellenphase
priority: 3
after: T-0238, T-0236
---
## Ziel
Am Ende der Zellenphase führt ein neuer Knopf im Abschlussbildschirm in die Fischphase. Vorher wird der erste Fisch aus der Zelle berechnet (`FishStart`). Zum Ausprobieren startet `-- --fisch` das Spiel direkt in der Fischphase.

## Dateien
- `scripts/end_screen.gd`
- `scripts/main.gd`
- `tests/test_main_fisch.gd` – neu

## Akzeptanzkriterien
- `scripts/end_screen.gd`:
  - unter `signal quit_game` die Zeile `signal to_fish_phase` einfügen;
  - unter `var box: VBoxContainer` die Zeile `var fish_button: Button` einfügen;
  - in `_init()` direkt **vor** `menu_button = Button.new()` einfügen:
```gdscript
	fish_button = Button.new()
	fish_button.name = "Fish"
	fish_button.text = "Weiter zur Fischphase"
	fish_button.custom_minimum_size = Vector2(400, 56)
	box.add_child(fish_button)
	fish_button.pressed.connect(func() -> void: to_fish_phase.emit())
```
- `scripts/main.gd`:
  - unter `const RESPAWN_INVULNERABLE := 2.0` die Zeile `const FISH_SCENE := "res://scenes/fish.tscn"` einfügen;
  - in `_ready()` direkt nach `end_screen.quit_game.connect(quit)` die Zeile `end_screen.to_fish_phase.connect(go_to_fish)` einfügen;
  - in `_ready()` direkt nach dem Block `if scene_name != "": start_scene(scene_name)` einfügen:
```gdscript

	if FishStart.requested(OS.get_cmdline_user_args()):
		go_to_fish.call_deferred()
```
  - am Ende der Datei anfügen:
```gdscript


## Übergang in die Fischphase: den ersten Fisch aus der Zelle berechnen und für FishMain hinterlegen.
func prepare_fish() -> void:
	FishStart.pending_build = FishStart.from_cell(player.build, player.look, player.diet)
	FishStart.pending_dna = progress.dna


func go_to_fish() -> void:
	prepare_fish()
	get_tree().change_scene_to_file(FISH_SCENE)
```
- Sonst nichts ändern.

## Tests
`tests/test_main_fisch.gd` mit `extends "res://tests/base_test.gd"`, `const P := "user://test_main_fisch.json"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `main.save_path = P`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()`, `FishStart.clear()`, dann `if FileAccess.file_exists(P): DirAccess.remove_absolute(ProjectSettings.globalize_path(P))`. **`go_to_fish()` in keinem Test aufrufen** (der Szenenwechsel würde den Testlauf stören).
- `test_knopf`: `main.end_screen.fish_button is Button` wahr; `main.end_screen.fish_button.text` ist `"Weiter zur Fischphase"`; `main.end_screen.to_fish_phase.is_connected(main.go_to_fish)` wahr
- `test_knopf_signal`: `var e := EndScreen.new()`; `var got := [false]`; `e.to_fish_phase.connect(func() -> void: got[0] = true)`; `e.fish_button.pressed.emit()` → `got[0]` wahr; am Ende `e.free()`
- `test_vorbereiten`: `main.start_new(Diet.FLEISCHFRESSER)`; `main.progress.dna = 55`; `main.prepare_fish()` → `FishStart.pending_build != null` wahr; `FishStart.pending_build.diet` ist `Diet.FLEISCHFRESSER`; `FishStart.pending_build.level("kiefer")` ist 1; `FishStart.pending_build.level("augen")` ist 1; `FishStart.pending_dna` ist 55
- `test_szene_vorhanden`: `ResourceLoader.exists(main.FISH_SCENE)` wahr
