---
id: T-0152
title: Einführungshinweise im Spiel zeigen
project: zellenphase
priority: 3
after: T-0150, T-0151
---
## Ziel
Die Hinweise aus `TutorialHints` erscheinen an der passenden Stelle im HUD: beim Start einer Partie, nach dem ersten Fressen, beim ersten Wachstum, beim ersten Editorbesuch und beim ersten Biss. Welche schon kamen, wird mit dem Spielstand gespeichert.

## Dateien
- `scripts/main.gd`
- `tests/test_main_hinweise.gd`: neu

## Akzeptanzkriterien
- Neue Variable direkt unter `var finished := false`: `var hints := TutorialHints.new()`
- Neue Funktion am Ende:
```gdscript
## Zeigt einen Einführungshinweis einmal pro Partie (6 Sekunden lang).
func hint(id: String) -> void:
	var text := hints.trigger(id)
	if text != "":
		hud.show_message(text, 6.0)
```
- In `start_new(diet)` am Ende:
```gdscript
	hints = TutorialHints.new()
	hint("bewegen")
```
- In `feed_player()` im Schleifenrumpf direkt vor `if progress.eat(item.value):` die Zeile `hint("fressen")`; im Block `if progress.eat(item.value):` direkt nach `stats.record_stage(player.diet)` die Zeile `hint("partner")`.
- In `open_editor()` direkt nach `editor.finished.connect(close_editor)` die Zeile `hint("editor")`.
- In `resolve_combat()` direkt nach der Zeile `player.motion.knockback(player.motion.position - cell.motion.position, 160.0)` die Zeile `hint("gefahr")` (gleiche Einrückung).
- In `save_now()` direkt vor `return SaveGame.write_file(save_path, data)`: `data["hints"] = hints.to_array()`
- In `load_saved()` direkt vor `hud.show_progress(progress)`:
```gdscript
	var hint_data: Variant = data.get("hints")
	hints = TutorialHints.from_array(hint_data if hint_data is Array else [])
```
- Sonst nichts an `main.gd` ändern.

## Tests
`tests/test_main_hinweise.gd` mit `extends "res://tests/base_test.gd"`, `const PATH := "user://test_hinweise_spielstand.json"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`, `main.save_path = PATH`; `teardown()`: `main.free()` und `if FileAccess.file_exists(PATH): DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))`.
- `test_start`: `main.start_new(Diet.PFLANZENFRESSER)` → `main.hud.message_label.text` ist `TutorialHints.TEXTS["bewegen"]`
- `test_fressen`: `main.start_new(Diet.PFLANZENFRESSER)`, `main.food.items.clear()`, `main.food.add_item(Diet.PFLANZE, main.player.mouth_point())`, `main.feed_player()` → `main.hud.message_label.text` ist `TutorialHints.TEXTS["fressen"]`; `main.hints.shown.has("fressen")` wahr
- `test_nur_einmal`: `main.hint("gefahr")`, `main.hud.show_message("x")`, `main.hint("gefahr")` → `main.hud.message_label.text` ist `"x"`
- `test_gespeichert`: `main.start_new(Diet.PFLANZENFRESSER)`, `main.hint("editor")`, `main.save_now()` wahr, `main.hints = TutorialHints.new()`, `main.load_saved()` wahr → `main.hints.shown.has("editor")` wahr; `main.hints.shown.has("bewegen")` wahr

Review (16.10.2026): gemergt, nachgebessert: hints gleich angelegt statt Null-Prüfung (save_now vor start_new).
