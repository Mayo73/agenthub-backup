extends "res://tests/base_test.gd"

var anim: SpriteAnimation

func setup() -> void:
	# Animation „laufen" mit 4 Bildern, 8 fps
	var frames_array: Array[String] = ["a.png", "b.png", "c.png", "d.png"]
	anim = SpriteAnimation.new("laufen", frames_array, 8.0, true)

func test_dauer() -> void:
	check_eq(anim.duration(), 0.5, "Dauer ist 0.5 Sekunden")

func test_schleife() -> void:
	check_eq(anim.frame_index(0.0), 0, "frame_index(0.0) ist 0")
	check_eq(anim.frame_index(0.13), 1, "frame_index(0.13) ist 1")
	check_eq(anim.frame_index(0.5), 0, "frame_index(0.5) ist 0 (loop)")
	check_eq(anim.frame_at(0.4), "d.png", "frame_at(0.4) ist d.png")

func test_ohne_schleife() -> void:
	var no_loop_anim := SpriteAnimation.new("laufen_no", ["a.png", "b.png", "c.png", "d.png"], 8.0, false)
	check_eq(no_loop_anim.frame_index(2.0), 3, "frame_index(2.0) ohne loop ist 3")
	check(no_loop_anim.finished(0.6), "finished(0.6) ohne loop ist true")
	check(not no_loop_anim.finished(0.2), "finished(0.2) ohne loop ist false")

func test_leer() -> void:
	var empty := SpriteAnimation.new()
	check_eq(empty.frame_index(1.0), -1, "frame_index bei leerer Animation ist -1")
	check_eq(empty.frame_at(1.0), "", "frame_at bei leerer Animation ist ''")

func test_speichern() -> void:
	var a := SpriteAnimation.new("laufen", ["a.png", "b.png", "c.png", "d.png"], 8.0, true)
	var json_str: String = JSON.stringify(a.to_dict())
	var d: Dictionary = JSON.parse_string(json_str)
	check_eq(d.get("frames", []).size(), 4, "gespeichert: 4 Bilder")
	check_eq(float(d.get("fps", 0.0)), 8.0, "gespeichert: fps 8.0")
	var restored := SpriteAnimation.from_dict(d)
	check_eq(restored.frames.size(), 4, "from_dict: 4 Bilder")
	check_eq(restored.fps, 8.0, "from_dict: fps 8.0")
