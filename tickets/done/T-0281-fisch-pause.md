---
id: T-0281
title: Pausemenü in der Fischphase
project: zellenphase
priority: 4
after: T-0277
---
## Ziel
Meilenstein „Fischphase – Optik, Klang, Speichern und Abnahme“: Esc öffnet auch in der Fischphase das Pausemenü (dasselbe `PauseMenu` wie in der Zellenphase). Solange es offen ist, steht die Welt still. „Weiter“ setzt fort, „Hauptmenü“ wechselt zurück zur Hauptszene, „Beenden“ schließt das Spiel.

## Dateien
- `scripts/fish_main.gd`
- `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- `scripts/fish_main.gd`: Konstante `const MAIN_SCENE := "res://scenes/main.tscn"`; Variablen `var pause_menu: PauseMenu` und `var paused := false` (unter `var deaths := 0`).
- In `_ready()` direkt vor `intro = FishIntro.new()`:
```gdscript
	pause_menu = PauseMenu.new()
	pause_menu.name = "PauseMenu"
	add_child(pause_menu)
	pause_menu.resume.connect(toggle_pause)
	pause_menu.to_main_menu.connect(back_to_menu)
	pause_menu.quit_game.connect(func() -> void: get_tree().quit())
```
- Neue Funktionen am Ende:
```gdscript
## Esc: Pause an oder aus. Während das Entwicklungsmenü offen ist, wirkungslos.
func toggle_pause() -> void:
	if evolve.visible:
		return
	paused = not paused
	if paused:
		pause_menu.open()
	else:
		pause_menu.close()
	set_physics_process(not paused)
	set_process(not paused)
	world.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT


func back_to_menu() -> void:
	get_tree().change_scene_to_file(MAIN_SCENE)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
```
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_main.gd` anhängen:
- `test_pausemenue_angelegt`: `fish.get_node("PauseMenu") is PauseMenu` wahr; `fish.paused` falsch
- `test_pause`: `fish.toggle_pause()` → `fish.paused` wahr; `fish.pause_menu.visible` wahr; `fish.is_physics_processing()` falsch; `fish.world.process_mode == Node.PROCESS_MODE_DISABLED` wahr; noch einmal `fish.toggle_pause()` → `fish.paused` falsch; `fish.is_physics_processing()` wahr
- `test_weiter_knopf`: `fish.toggle_pause()`; `fish.pause_menu.resume.emit()` → `fish.paused` falsch
- `test_nicht_im_entwicklungsmenue`: `fish.toggle_evolve()`; `fish.toggle_pause()` → `fish.paused` falsch
- `test_hauptszene_vorhanden`: `ResourceLoader.exists(fish.MAIN_SCENE)` wahr

Review (18.10.2026): gemergt.
