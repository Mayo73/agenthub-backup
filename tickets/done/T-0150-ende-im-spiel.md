---
id: T-0150
title: Ende der Zellenphase im Spiel
project: zellenphase
priority: 3
after: T-0149, T-0147, T-0148
---
## Ziel
Hat die Zelle im letzten Abschnitt genug gesammelt, erscheint „An Land gehen“. Ein Klick beendet die Zellenphase, speichert und zeigt den Abschlussbildschirm mit dem Rückblick. Von dort geht es ins Hauptmenü oder hinaus (Lastenheft „Vollständiger Durchlauf“, Abnahme 11).

## Dateien
- `scripts/main.gd`
- `tests/test_main_ende.gd`: neu

## Akzeptanzkriterien
- Neue Variablen direkt unter `var stats := RunStats.new()`:
```gdscript
var end_screen: EndScreen
var finished := false
```
- Am Ende von `_ready()`:
```gdscript
	end_screen = EndScreen.new()
	end_screen.name = "EndScreen"
	add_child(end_screen)
	end_screen.to_main_menu.connect(_on_end_to_menu)
	end_screen.quit_game.connect(quit)
	hud.finish_pressed.connect(finish_phase)
	add_click_sounds(end_screen)
```
- Am Ende von `_process(delta)`: `hud.show_can_finish(PhaseEnd.can_finish(progress) and not finished)`
- In `start_new(diet)` als erste Zeile `finished = false`.
- Neue Funktionen am Ende:
```gdscript
## Beendet die Zellenphase und zeigt den Rückblick. Der Spielstand wird vorher gespeichert.
func finish_phase() -> void:
	if finished or not PhaseEnd.can_finish(progress):
		return
	finished = true
	autosave_now()
	set_physics_process(false)
	world.process_mode = Node.PROCESS_MODE_DISABLED
	hud.show_can_finish(false)
	end_screen.show_stats(stats)


func _on_end_to_menu() -> void:
	end_screen.visible = false
	finished = false
	back_to_menu()
```
- Sonst nichts an `main.gd` ändern.

## Tests
`tests/test_main_ende.gd` mit `extends "res://tests/base_test.gd"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()`.
- `test_noch_nicht`: `main.finish_phase()` → `main.finished` falsch; `main.end_screen.visible` falsch
- `test_ende`: `main.progress.eat(100)`, `main.finish_phase()` → `main.finished` wahr; `main.end_screen.visible` wahr; `main.world.process_mode == Node.PROCESS_MODE_DISABLED` wahr
- `test_knopf`: `main.progress.eat(100)`, `main._process(0.016)` → `main.hud.finish_button.visible` wahr
- `test_knopf_loest_aus`: `main.progress.eat(100)`, `main.hud.finish_button.pressed.emit()` → `main.finished` wahr
- `test_zurueck_ins_menue`: `main.progress.eat(100)`, `main.finish_phase()`, `main.end_screen.menu_button.pressed.emit()` → `main.end_screen.visible` falsch; `main.in_menu` wahr; `main.finished` falsch

Review (16.10.2026): gemergt.
