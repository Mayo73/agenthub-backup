---
id: T-0149
title: Durchlauf-Statistik im Spiel mitzählen und speichern
project: zellenphase
priority: 3
after: T-0146, T-0126
---
## Ziel
Das Spiel zählt für den Entwicklungsrückblick mit: Spielzeit, gefressene Nahrung, besiegte Zellen, Tode, Editorbesuche und die Ernährung bei jedem Wachstum. Die Zahlen werden mit dem Spielstand gespeichert und geladen.

## Dateien
- `scripts/main.gd`
- `tests/test_main_stats.gd`: neu

## Akzeptanzkriterien
- Neue Variable direkt unter `var audio: GameAudio`: `var stats := RunStats.new()`
- In `_physics_process(delta)` direkt vor der Zeile `player_health.tick(delta)`: `stats.tick(delta)`
- In `feed_player()` in der Schleife `for item in food.take_at(...)` direkt vor `if progress.eat(item.value):` die Zeile `stats.food_eaten += 1`; im Block `if progress.eat(item.value):` direkt nach `audio.play("wachsen")` die Zeile `stats.record_stage(player.diet)`.
- In `resolve_combat()` im Block `if cell.health.is_dead():` als erste Zeile `stats.cells_defeated += 1`.
- In `check_death()` direkt nach `deaths += 1` die Zeile `stats.deaths += 1`.
- In `close_editor(build)` als erste Zeile `stats.editor_visits += 1`.
- In `start_new(diet)` als erste Zeile `stats = RunStats.new()`.
- In `save_now()` direkt vor `return SaveGame.write_file(save_path, data)` die Zeile `data["stats"] = stats.to_dict()`.
- In `load_saved()` direkt vor `hud.show_progress(progress)`:
```gdscript
	var stats_data: Variant = data.get("stats")
	stats = RunStats.from_dict(stats_data) if stats_data is Dictionary else RunStats.new()
```
- Sonst nichts an `main.gd` ändern.

## Tests
`tests/test_main_stats.gd` mit `extends "res://tests/base_test.gd"`, `const PATH := "user://test_stats_spielstand.json"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`, `main.save_path = PATH`; `teardown()`: `main.free()` und `if FileAccess.file_exists(PATH): DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))`.
- `test_fressen_zaehlt`: `main.food.items.clear()`, `main.food.add_item(Diet.PFLANZE, main.player.mouth_point())`, `main.feed_player()` → `main.stats.food_eaten` ist 1
- `test_wachsen_merkt_ernaehrung`: `main.food.items.clear()`, `main.progress.eat(9)`, `main.food.add_item(Diet.PFLANZE, main.player.mouth_point())`, `main.feed_player()` → `main.stats.diet_history.size()` ist 1
- `test_tod_zaehlt`: `main.player_health.damage(1000.0)`, `main.check_death()` → `main.stats.deaths` ist 1
- `test_neue_partie`: `main.stats.deaths = 3`, `main.start_new(Diet.PFLANZENFRESSER)` → `main.stats.deaths` ist 0
- `test_gespeichert`: `main.start_new(Diet.PFLANZENFRESSER)`, `main.stats.food_eaten = 7`, `main.save_now()` wahr, `main.stats = RunStats.new()`, `main.load_saved()` wahr → `main.stats.food_eaten` ist 7

Review (16.10.2026): fehlgeschlagen (Agent baute eigene Assertions-Klasse statt der vorgegebenen Tests), von Claude nach Ticketvorgabe selbst umgesetzt.
