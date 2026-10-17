---
id: T-0157
title: Leistungstest-Node (Benchmark)
project: zellenphase
priority: 3
after: T-0156
---
## Ziel
Ein Node misst 60 Sekunden lang die Bildrate, merkt sich die kleinste Zahl aktiver KI-Zellen und schreibt das Ergebnis in eine Datei (Abnahmekriterium 12). Gestartet wird er später von `main.gd`, wenn Godot mit `-- --benchmark` läuft.

## Dateien
- `scripts/benchmark.gd`: neu
- `tests/test_benchmark.gd`: neu

## Akzeptanzkriterien
`scripts/benchmark.gd` genau so:
```gdscript
class_name Benchmark
extends Node
## Leistungstest: misst DURATION Sekunden lang die Bildrate und schreibt das Ergebnis in eine Datei.
## Start: Godot mit "-- --benchmark"; main.gd hängt diesen Node dann an.

signal finished(text: String)

const DURATION := 60.0
const RESULT_PATH := "user://leistungstest.txt"

var meter := FpsMeter.new()
var duration := DURATION
var result_path := RESULT_PATH
## Liefert die Zahl der aktiven KI-Zellen (wird von main.gd gesetzt).
var ai_counter: Callable
var min_ai := -1
var done := false


static func requested(args: PackedStringArray) -> bool:
	return args.has("--benchmark")


func _process(delta: float) -> void:
	step(delta)


## Ein Messschritt; nach duration Sekunden wird das Ergebnis einmal geschrieben und finished gemeldet.
func step(delta: float) -> void:
	if done:
		return
	meter.add_frame(delta)
	if ai_counter.is_valid():
		var n := int(ai_counter.call())
		min_ai = n if min_ai < 0 else mini(min_ai, n)
	if meter.elapsed >= duration:
		done = true
		var text := result_text()
		var file := FileAccess.open(result_path, FileAccess.WRITE)
		if file != null:
			file.store_string(text)
			file.close()
		finished.emit(text)


func result_text() -> String:
	return "Leistungstest: %.1f s, Durchschnitt %.1f FPS, Minimum %.1f FPS, mindestens %d KI-Zellen" % [meter.elapsed, meter.average_fps(), meter.min_fps(), maxi(min_ai, 0)]
```

## Tests
`tests/test_benchmark.gd` mit `extends "res://tests/base_test.gd"`, `const PATH := "user://test_leistungstest.txt"`, `var b: Benchmark`; `setup()`: `b = Benchmark.new()`, `b.result_path = PATH`, `b.duration = 1.0`; `teardown()`: `b.free()` und `PATH` löschen, falls vorhanden.
- `test_angefragt`: `Benchmark.requested(PackedStringArray(["--benchmark"]))` wahr; `Benchmark.requested(PackedStringArray([]))` falsch
- `test_laeuft`: 30-mal `b.step(1.0 / 60.0)` → `b.done` falsch; `FileAccess.file_exists(PATH)` falsch
- `test_ende`: `var got: Array = []`, `b.finished.connect(func(t: String) -> void: got.append(t))`, 61-mal `b.step(1.0 / 60.0)` → `b.done` wahr; `got.size()` ist 1; `FileAccess.file_exists(PATH)` wahr; `(got[0] as String).contains("60.0 FPS")` wahr
- `test_ki_zaehlen`: In der Testdatei Membervariablen `var counts := [32, 30, 31]` und `var k := 0` sowie eine Hilfsfunktion (nicht `test_` benennen) `func _count() -> int:` mit `k += 1` und `return counts[k - 1]`; im Test `b.ai_counter = _count`, dann 3-mal `b.step(0.1)` → `b.min_ai` ist 30; `b.result_text().contains("mindestens 30 KI-Zellen")` wahr
- `test_nur_einmal`: `var got: Array = []`, `b.finished.connect(func(t: String) -> void: got.append(t))`, 100-mal `b.step(1.0 / 60.0)` → `got.size()` ist 1

Review (16.10.2026): gemergt, nachgebessert: Teardown im Test löscht die Ergebnisdatei, statt sie nur zu leeren (zweiter Prüflauf war rot).
