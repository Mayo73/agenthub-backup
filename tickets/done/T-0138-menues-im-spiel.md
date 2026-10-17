---
id: T-0138
title: Hauptmenü und Pausemenü im Spiel
project: zellenphase
priority: 3
after: T-0137, T-0127, T-0128
---
## Ziel
Das Spiel startet im Hauptmenü. „Neue Partie“ beginnt als Pflanzen- oder Fleischfresser, „Fortsetzen“ lädt den Spielstand, „Beenden“ schließt das Spiel. Esc öffnet im Spiel das Pausemenü; von dort geht es weiter, ins Hauptmenü (mit Speichern) oder hinaus. Im Menü und in der Pause steht die Spielwelt still. Die Einstellungs-Knöpfe werden in einem späteren Ticket verbunden.

## Dateien
- `scripts/main.gd`
- `tests/test_main_menus.gd`: neu

## Akzeptanzkriterien
- Neue Variablen direkt unter `var autosave := false`:
```gdscript
var main_menu: MainMenu
var pause_menu: PauseMenu
var in_menu := false
var paused := false
```
- Am Ende von `_ready()`:
```gdscript
	main_menu = MainMenu.new()
	main_menu.name = "MainMenu"
	add_child(main_menu)
	main_menu.set_can_continue(FileAccess.file_exists(save_path))
	main_menu.new_game.connect(_on_new_game)
	main_menu.continue_game.connect(_on_continue)
	main_menu.quit_game.connect(quit)
	pause_menu = PauseMenu.new()
	pause_menu.name = "PauseMenu"
	add_child(pause_menu)
	pause_menu.resume.connect(toggle_pause)
	pause_menu.to_main_menu.connect(back_to_menu)
	pause_menu.quit_game.connect(quit)
	show_menu(true)
```
- Neue Funktionen am Ende:
```gdscript
## Zeigt oder verbirgt das Hauptmenü; im Menü steht die Spielwelt still.
func show_menu(value: bool) -> void:
	in_menu = value
	main_menu.visible = value
	hud.visible = not value
	world.visible = not value
	set_physics_process(not value)
	world.process_mode = Node.PROCESS_MODE_DISABLED if value else Node.PROCESS_MODE_INHERIT


func _on_new_game(diet: String) -> void:
	start_new(diet)
	show_menu(false)


func _on_continue() -> void:
	if load_saved():
		show_menu(false)


## Esc im Spiel: Pause an oder aus. Im Hauptmenü und im Editor wirkungslos.
func toggle_pause() -> void:
	if in_menu or editor_open:
		return
	paused = not paused
	if paused:
		pause_menu.open()
	else:
		pause_menu.close()
	set_physics_process(not paused)
	world.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT


func back_to_menu() -> void:
	autosave_now()
	paused = false
	pause_menu.close()
	main_menu.set_can_continue(FileAccess.file_exists(save_path))
	show_menu(true)


func quit() -> void:
	autosave_now()
	get_tree().quit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
```
- Sonst nichts an `main.gd` ändern.

## Tests
`tests/test_main_menus.gd` mit `extends "res://tests/base_test.gd"`, `const PATH := "user://test_menue_spielstand.json"`, `var main: Node2D`;
`setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`, `main.save_path = PATH`;
`teardown()`: `main.free()` und `if FileAccess.file_exists(PATH): DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))`.
- `test_start_im_menue`: `main.in_menu` wahr; `main.main_menu.visible` wahr; `main.world.visible` falsch; `main.world.process_mode == Node.PROCESS_MODE_DISABLED` wahr
- `test_neue_partie`: `main.main_menu.carnivore_button.pressed.emit()` → `main.in_menu` falsch; `main.world.visible` wahr; `main.player.diet` ist `Diet.FLEISCHFRESSER`
- `test_pause`: `main.main_menu.herbivore_button.pressed.emit()`, `main.toggle_pause()` → `main.paused` wahr; `main.pause_menu.visible` wahr; `main.world.process_mode == Node.PROCESS_MODE_DISABLED` wahr; `main.pause_menu.resume_button.pressed.emit()` → `main.paused` falsch; `main.pause_menu.visible` falsch
- `test_keine_pause_im_menue`: `main.toggle_pause()` → `main.paused` falsch
- `test_zurueck_ins_menue`: `main.main_menu.herbivore_button.pressed.emit()`, `main.toggle_pause()`, `main.pause_menu.main_menu_button.pressed.emit()` → `main.in_menu` wahr; `main.paused` falsch; `FileAccess.file_exists(PATH)` wahr; `main.main_menu.continue_button.disabled` falsch
- `test_fortsetzen`: `main.main_menu.herbivore_button.pressed.emit()`, `main.progress.dna = 9`, `main.save_now()`, `main.back_to_menu()`, `main.progress.dna = 0`, `main.main_menu.continue_button.pressed.emit()` → `main.in_menu` falsch; `main.progress.dna` ist 9

Review (16.10.2026): gemergt.
