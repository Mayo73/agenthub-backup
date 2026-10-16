extends "res://tests/base_test.gd"

const PATH := "user://test_leistungstest.txt"

var b: Benchmark


func setup() -> void:
	b = Benchmark.new()
	b.result_path = PATH
	b.duration = 1.0


func teardown() -> void:
	b.free()
	if FileAccess.file_exists(PATH):
		var file := FileAccess.open(PATH, FileAccess.WRITE)
		if file != null:
			file.close()


func test_angefragt() -> void:
	check(Benchmark.requested(PackedStringArray(["--benchmark"])), "Benchmark wird mit --benchmark_requested")
	check(not Benchmark.requested(PackedStringArray([])), "Benchmark wird ohne --benchmark nicht_requested")


func test_laeuft() -> void:
	for _i in range(30):
		b.step(1.0 / 60.0)
	check(not b.done, "Nach 30 Schritten ist Benchmark noch nicht done")
	check(not FileAccess.file_exists(PATH), "Nach 30 Schritten existiert die Ergebnisdatei noch nicht")


func test_ende() -> void:
	var got: Array = []
	b.finished.connect(func(t: String) -> void: got.append(t))
	for _i in range(61):
		b.step(1.0 / 60.0)
	check(b.done, "Nach 61 Schritten ist Benchmark done")
	check_eq(got.size(), 1, "finished wurde genau einmal gemeldet")
	check(FileAccess.file_exists(PATH), "Die Ergebnisdatei existiert nach Done")
	check((got[0] as String).contains("60.0 FPS"), "Ergebnis enthält '60.0 FPS'")


var _counts := [32, 30, 31]
var _k := 0


func _count() -> int:
	_k += 1
	return _counts[_k - 1]


func test_ki_zaehlen() -> void:
	_counts = [32, 30, 31]
	_k = 0
	b.ai_counter = Callable(self, "_count")
	for _i in range(3):
		b.step(0.1)
	check_eq(b.min_ai, 30, "Minimum ist 30")
	check(b.result_text().contains("mindestens 30 KI-Zellen"), "Ergebnis enthält 'mindestens 30 KI-Zellen'")


func test_nur_einmal() -> void:
	var got: Array = []
	b.finished.connect(func(t: String) -> void: got.append(t))
	for _i in range(100):
		b.step(1.0 / 60.0)
	check_eq(got.size(), 1, "finished wurde genau einmal gemeldet")

