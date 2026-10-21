extends "res://tests/base_test.gd"

var clip: AnimationClip


func setup() -> void:
	clip = AnimationClip.new()
	clip.key("x", 0, 0)
	clip.key("x", 1, 10)
	clip.key("alpha", 0, 1)
	clip.key("alpha", 2, 0)


func test_mehrere() -> void:
	check_eq(clip.length(), 2.0, "length() sollte 2.0 sein")
	var samples = clip.sample_all(1.0)
	check_eq(samples["x"], 10.0, "sample_all(1.0).x sollte 10.0 sein")
	check_eq(samples["alpha"], 0.5, "sample_all(1.0).alpha sollte 0.5 sein")


func test_schleife() -> void:
	clip.loop = true
	var samples = clip.sample_all(3.0)
	check_eq(samples["alpha"], 0.5, "sample_all(3.0).alpha bei loop sollte 0.5 sein")
	check_eq(samples["x"], 10.0, "sample_all(3.0).x bei loop sollte 10.0 sein")


func test_speichern() -> void:
	var d: Dictionary = JSON.parse_string(JSON.stringify(clip.to_dict()))
	var loaded: AnimationClip = AnimationClip.from_dict(d)
	var samples = loaded.sample_all(0.5)
	check_eq(samples["x"], 5.0, "sample_all(0.5) nach from_dict sollte x=5.0 sein")
