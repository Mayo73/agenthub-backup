extends Node


func _ready() -> void:
	run_tests()


func run_tests() -> void:
	var test_runner := _TestRunner.new()
	test_runner.run_all_tests()
	get_tree().quit()


class _TestRunner:
	var total_tests := 0
	var passed_tests := 0
	var failed_tests := 0
	var all_failures := ""


	func run_all_tests() -> void:
		print("\n=== Run Test Suite ===\n")

		var test_files := DirAccess.open("res://tests")
		if test_files == null:
			push_error("Konnte tests/ Verzeichnis nicht öffnen")
			return

		var files := test_files.get_files()
		for file in files:
			if file.begins_with("test_") and file.ends_with(".gd"):
				var test_path := "res://tests/%s" % file
				run_test_file(test_path)

		print("\n=== Test Results ===")
		print("Total:    %d" % total_tests)
		print("Passed:   %d" % passed_tests)
		print("Failed:   %d" % failed_tests)

		if not all_failures.is_empty():
			print("\nFailures:")
			print(all_failures)


	func run_test_file(path: String) -> void:
		var loaded := load(path)
		if loaded == null:
			push_error("Konnte %s nicht laden" % path)
			return

		var instance := loaded.new() as RefCounted

		if instance.has_method("setup"):
			instance.setup()

		var methods := instance.get_method_list()
		for method in methods:
			var method_name: String = method["name"]
			if method_name.begins_with("test_"):
				total_tests += 1
				print("Running %s.%s..." % [path, method_name])

				var failures_before: int = instance.failures.size()
				instance.call_func(method_name)
				var failures_after: int = instance.failures.size()

				if failures_after > failures_before:
					failed_tests += 1
					for i in range(failures_before, failures_after):
						print("  FAIL: %s" % instance.failures[i])
						all_failures += "  %s.%s: %s\n" % [path, method_name, instance.failures[i]]
				else:
					passed_tests += 1
					print("  PASS")

		if instance.has_method("teardown"):
			instance.teardown()

		instance.free()

