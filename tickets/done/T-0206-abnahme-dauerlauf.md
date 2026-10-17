---
id: T-0206
title: Abnahmetest – Dauerlauf mit Tod, Wiedereinstieg und Pause
project: zellenphase
priority: 3
---
## Ziel
Abnahmekriterium 11 verlangt einen langen Spieltest ohne Absturz oder festhängende Zustände. Ein automatischer Dauerlauf simuliert eine Minute Spielzeit mit schwimmender Spielerzelle und allen KI-Zellen; dazu Tod mit Wiedereinstieg und Pause. Den 30-minütigen Spieltest macht später der Nutzer. Nur ein neuer Test, keine Änderungen an Skripten.

## Dateien
- `tests/test_abnahme_dauerlauf.gd`: neu

## Akzeptanzkriterien
- Nur `tests/test_abnahme_dauerlauf.gd` anlegen. Keine Datei unter `scripts/` ändern.
- Kopf: `extends "res://tests/base_test.gd"`, `const P := "user://test_abnahme_dauerlauf.json"`, `const DT := 0.05`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `main.save_path = P`, danach `(Engine.get_main_loop() as SceneTree).root.add_child(main)`, dann `main.start_new(Diet.PFLANZENFRESSER)`; `teardown()`: `main.free()` und die Datei `P` löschen, falls vorhanden.
- Hilfsfunktion (nicht `test_` benennen), ein Spielschritt wie im echten Spiel (die Spielerzelle schwimmt im Bogen):
```gdscript
func _step(i: int) -> void:
	main.player.drive(DT, Vector2.from_angle(i * 0.02))
	main._physics_process(DT)
	for cell in main.ai_cells:
		cell.drive(DT)
```

## Tests
- `test_eine_minute`: `for i in 1200: _step(i)` → `main.ai_cells.size() > 0` wahr; `main.ai_cells.size() <= EcoSpawner.TARGET_COUNT` wahr; `main.food.items.size() > 0` wahr; `main.player_health.is_dead()` falsch; `main.in_menu` falsch; `main.editor_open` falsch; `main.player.motion.position.length() > 100.0` wahr (die Zelle ist geschwommen)
- `test_tod_und_weiter`: `main.player_health.drain(1000.0)`, `main._physics_process(DT)` → `main.deaths` ist 1; `main.player_health.is_dead()` falsch; danach `for i in 200: _step(i)` → `main.in_menu` falsch; `main.player_health.is_dead()` falsch
- `test_pause_mitten`: `for i in 100: _step(i)`, `main.toggle_pause()` → `main.paused` wahr; `main.pause_menu.visible` wahr; `main.toggle_pause()` → `main.paused` falsch; `main.pause_menu.visible` falsch
- `test_menue_und_zurueck`: `for i in 100: _step(i)`, `main.back_to_menu()` → `main.in_menu` wahr; `main.start_new(Diet.FLEISCHFRESSER)` → `main.in_menu` falsch; `for i in 100: _step(i)` → `main.player.diet` ist `Diet.FLEISCHFRESSER`

Review (17.10.2026): gemergt.
