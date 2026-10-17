---
id: T-0158
title: Leistungstest aus dem Spiel starten
project: zellenphase
priority: 3
after: T-0155, T-0157
---
## Ziel
Startet man das Spiel mit `-- --benchmark`, beginnt ohne Menü eine Partie ohne Speichern, der Leistungstest misst 60 Sekunden und das Spiel beendet sich danach. Das Ergebnis steht in `user://leistungstest.txt` (Abnahmekriterium 12). Claude führt den Test später auf dem PC des Nutzers aus.

## Dateien
- `scripts/main.gd`
- `tests/test_main_leistung.gd`: neu

## Akzeptanzkriterien
- Neue Variable direkt unter `var pending_diet := ""`: `var benchmark: Benchmark`
- Am Ende von `_ready()`:
```gdscript
	if Benchmark.requested(OS.get_cmdline_user_args()):
		start_benchmark()
```
- Neue Funktionen am Ende:
```gdscript
## Leistungstest: neue Partie ohne Speichern; nach Benchmark.DURATION Sekunden Ergebnis ausgeben und beenden.
func start_benchmark() -> void:
	start_new(Diet.PFLANZENFRESSER)
	autosave = false
	show_menu(false)
	benchmark = Benchmark.new()
	benchmark.name = "Benchmark"
	benchmark.ai_counter = func() -> int: return ai_cells.size()
	benchmark.finished.connect(_on_benchmark_finished)
	add_child(benchmark)


func _on_benchmark_finished(text: String) -> void:
	print(text)
	get_tree().quit()
```
- Sonst nichts an `main.gd` ändern.

## Tests
`tests/test_main_leistung.gd` mit `extends "res://tests/base_test.gd"`, `var main: Node2D`; `setup()`: `main = load("res://scenes/main.tscn").instantiate()`, `(Engine.get_main_loop() as SceneTree).root.add_child(main)`; `teardown()`: `main.free()`. `_on_benchmark_finished` im Test **nicht** aufrufen (beendet Godot).
- `test_ohne_schalter`: `main.benchmark == null` wahr (der Testlauf hat kein `--benchmark`)
- `test_start`: `main.start_benchmark()` → `main.benchmark != null` wahr; `main.autosave` falsch; `main.in_menu` falsch; `main.benchmark.ai_counter.call()` ist `main.ai_cells.size()`
- `test_ki_zellen`: `main.start_benchmark()`, `main.spawn_ai()` → `main.benchmark.ai_counter.call() >= 30` wahr

Review (17.10.2026): gemergt.
