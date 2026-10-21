extends "res://tests/base_test.gd"

var a: AudioEmitter

func setup() -> void:
	a = AudioEmitter.new()
	a.length = 2.0

func test_abspielen() -> void:
	a.play()
	a.step(0.5)
	check_eq(a.position, 0.5, "position sollte 0.5 sein")
	check_eq(a.state, "playing", "state sollte playing sein")

func test_ende() -> void:
	a.play()
	a.step(2.5)
	check_eq(a.state, "stopped", "state sollte stopped sein")
	check_eq(a.position, 0.0, "position sollte 0.0 sein")

func test_schleife() -> void:
	a.loop = true
	a.play()
	a.step(2.5)
	check_eq(a.state, "playing", "state sollte playing sein")
	check_eq(a.position, 0.5, "position sollte 0.5 sein")

func test_pause() -> void:
	a.play()
	a.step(0.5)
	a.pause()
	a.step(1.0)
	check_eq(a.position, 0.5, "position sollte 0.5 nach Pause sein")
	a.play()
	a.step(0.5)
	check_eq(a.position, 1.0, "position sollte 1.0 nach weiter sein")

func test_tonhoehe() -> void:
	a.pitch = 2.0
	a.play()
	a.step(0.5)
	check_eq(a.position, 1.0, "position sollte 1.0 bei pitch 2.0 sein")

func test_entfernung() -> void:
	check_eq(a.gain_at(0.5), 1.0, "gain_at(0.5) sollte 1.0 sein")
	check_eq(a.gain_at(10.5), 0.5, "gain_at(10.5) sollte 0.5 sein")
	check_eq(a.gain_at(25.0), 0.0, "gain_at(25.0) sollte 0.0 sein")

func test_speichern() -> void:
	a.stream = "res://klang.ogg"
	a.pitch = 1.5
	var b: AudioEmitter = AudioEmitter.from_dict(a.to_dict())
	check_eq(b.stream, a.stream, "stream sollte übereinstimmen")
	check_eq(b.pitch, a.pitch, "pitch sollte übereinstimmen")
	check_eq(b.length, a.length, "length sollte übereinstimmen")
