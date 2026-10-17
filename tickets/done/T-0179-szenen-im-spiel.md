---
id: T-0179
title: Vorführszene mit -- --szene=<name> starten
project: zellenphase
priority: 2
after: T-0177, T-0178
---
## Ziel
Startet man das Spiel mit `-- --szene=jagd` (oder einer anderen Szene aus `DemoScenes`), beginnt ohne Menü und ohne Speichern genau diese Situation: nur die Zellen und Nahrung der Szene, kein Nachschub. Ein Hinweis im HUD erklärt, was zu sehen ist (Abnahmekriterien 5 und 6).

## Dateien
- `scripts/main.gd`
- `tests/test_main_szenen.gd`: neu

## Akzeptanzkriterien
- Neue Variable direkt unter `var benchmark: Benchmark`: `var auto_spawn := true` mit dem Kommentar `## false in Vorführszenen: keine neuen KI-Zellen und keine neue Nahrung.` in der Zeile darüber
- In `_physics_process(delta)` die Zeile `refill_food()` ersetzen durch zwei Zeilen `if auto_spawn:` und eingerückt `refill_food()`; ebenso die Zeile `spawn_ai()` durch `if auto_spawn:` und eingerückt `spawn_ai()`.
- Am Ende von `_ready()`:
```gdscript
	var scene_name := DemoScenes.requested(OS.get_cmdline_user_args())
	if scene_name != "":
		start_scene(scene_name)
```
- Neue Funktion am Ende:
```gdscript
## Vorführszene: Partie ohne Speichern, nur die Zellen und die Nahrung der Szene.
func start_scene(scene_name: String) -> void:
	var d := DemoScenes.data(scene_name)
	start_new(str(d["diet"]))
	autosave = false
	auto_spawn = false
	show_menu(false)
	for cell in ai_cells.duplicate():
		remove_ai(cell)
	food.items.clear()
	player.motion.position = Vector2.ZERO
	player.motion.velocity = Vector2.ZERO
	player.motion.heading = 0.0
	player.position = Vector2.ZERO
	progress.stage = int(d["stage"])
	player.set_stage(progress.stage)
	player.set_build(DemoScenes.build_for(scene_name))
	for entry: Array in d["ai"]:
		var cell := AiCell.new()
		cell.setup(entry[0], entry[1])
		cell.motion.heading = entry[2]
		world.add_child(cell)
		ai_cells.append(cell)
	for entry: Array in d["food"]:
		food.add_item(entry[0], entry[1])
	hud.show_progress(progress)
	hud.show_message(str(d["text"]), 8.0)
```
- Sonst nichts an `main.gd` ändern.

## Tests
`tests/test_main_szenen.gd` mit `extends "res://tests/base_test.gd"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()`.
- `test_jagd`: `main.start_scene("jagd")` → `main.ai_cells.size()` ist 1; `main.ai_cells[0].species_id` ist `"schnapper"`; `main.autosave` falsch; `main.in_menu` falsch; `main.hud.message_label.text` ist `"Ein Schnapper jagt die kleine Spielerzelle."`
- `test_kein_nachschub`: `main.start_scene("jagd")`, `main._physics_process(0.016)` → `main.ai_cells.size()` ist 1
- `test_nahrung`: `main.start_scene("nahrung")` → `main.food.items.size()` ist 1; `main.player.diet` ist `Diet.PFLANZENFRESSER`
- `test_tempo`: `main.start_scene("tempo")` → `main.player.build.parts.size()` ist 4; `main.player.motion.max_speed > CellStats.max_speed(CellBuild.starter(Diet.PFLANZENFRESSER), 1)` wahr
- `test_groesse`: `main.start_scene("flucht")` → `main.progress.stage` ist 3; `main.player.radius` ist 40.0

Review (17.10.2026): gemergt.
