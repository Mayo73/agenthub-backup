extends SceneTree

func _initialize():
	create_timer(0.1).timeout.connect(_run_tests)
	create_timer(120.0).timeout.connect(_on_watchdog)

func _on_watchdog():
	print("TIMEOUT - aborted after 120s")
	quit(2)

func _run_tests():
	var pass_count := 0
	var fail_count := 0

	# Test segment_rect basic hit
	var result = SweepHit.segment_rect(Vector2(0, 0), Vector2(10, 0), Rect2(5, -5, 0.02, 10))
	if not result.is_empty() and result["t"] == 0.5 and result["normal"] == Vector2(-1, 0):
		print("OK: test_duenne_wand")
		pass_count += 1
	else:
		print("FAIL: test_duenne_wand - ", result)
		fail_count += 1

	# Test miss
	result = SweepHit.segment_rect(Vector2(0, 10), Vector2(10, 10), Rect2(5, -5, 0.02, 10))
	if result.is_empty():
		print("OK: test_vorbei")
		pass_count += 1
	else:
		print("FAIL: test_vorbei - ", result)
		fail_count += 1

	# Test vertical ray hitting top face
	result = SweepHit.segment_rect(Vector2(5, -10), Vector2(5, 0), Rect2(0, -2, 10, 1))
	if not result.is_empty() and result["normal"] == Vector2(0, -1) and abs(result["t"] - 0.8) < 0.001:
		print("OK: test_oben")
		pass_count += 1
	else:
		print("FAIL: test_oben - ", result)
		fail_count += 1

	# Test first_hit with multiple walls
	var walls: Array[Rect2] = [Rect2(6, -1, 0.1, 2), Rect2(3, -1, 0.1, 2)]
	result = SweepHit.first_hit(Vector2(0, 0), Vector2(10, 0), walls)
	if not result.is_empty() and result["index"] == 1:
		print("OK: test_erste_wand")
		pass_count += 1
	else:
		print("FAIL: test_erste_wand - ", result)
		fail_count += 1

	# Test reflection
	result = SweepHit.reflect(Vector2(10, 0), Vector2(-1, 0), 0.5)
	if result == Vector2(-5, 0):
		print("OK: test_rueckprall")
		pass_count += 1
	else:
		print("FAIL: test_rueckprall - ", result)
		fail_count += 1

	print("ERGEBNIS: %d ok, %d fehlgeschlagen" % [pass_count, fail_count])
	quit(1 if fail_count > 0 else 0)
