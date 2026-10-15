extends SceneTree
## Headless-Testlauf:  godot --headless --path . --script res://tests/run_tests.gd
##  1. lädt jedes Skript im Projekt (findet Parse-Fehler)
##  2. startet jede Szene unter res://scenes kurz (findet Fehler in _ready)
##  3. führt alle test_*-Methoden aus res://tests/test_*.gd aus
## Exit-Code 0 = alles grün, 1 = mindestens ein Fehler.

const SKIP_DIRS := [".godot", ".git", "addons"]

var _passed := 0
var _failed := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	print("== Skripte laden ==")
	var script_count := 0
	for path in _find_files("res://", ".gd"):
		var script := load(path) as Script
		if script == null or not script.can_instantiate():
			_fail(path, "Skript lässt sich nicht laden (Parse-Fehler?)")
		else:
			script_count += 1
	print("  %d Skripte geladen" % script_count)

	print("== Szenen starten ==")
	for path in _find_files("res://scenes", ".tscn"):
		var packed := load(path) as PackedScene
		if packed == null:
			_fail(path, "Szene lässt sich nicht laden")
			continue
		var instance := packed.instantiate()
		if instance == null:
			_fail(path, "Szene lässt sich nicht instanziieren")
			continue
		root.add_child(instance)
		for i in 5:
			await process_frame
		instance.queue_free()
		await process_frame
		_ok(path)

	print("== Tests ==")
	for path in _find_files("res://tests", ".gd"):
		if not path.get_file().begins_with("test_"):
			continue
		var script := load(path) as Script
		if script == null:
			continue  # oben schon als Fehler gezählt
		var suite: Object = script.new()
		for method in script.get_script_method_list():
			var method_name: String = method["name"]
			if not method_name.begins_with("test_"):
				continue
			suite.failures.clear()
			suite.call(method_name)
			var label := "%s::%s" % [path.get_file(), method_name]
			if suite.failures.is_empty():
				_ok(label)
			else:
				_fail(label, "; ".join(suite.failures))

	print("ERGEBNIS: %d ok, %d fehlgeschlagen" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


func _ok(what: String) -> void:
	_passed += 1
	print("  OK      ", what)


func _fail(what: String, why: String) -> void:
	_failed += 1
	print("  FEHLER  %s: %s" % [what, why])


func _find_files(dir: String, ext: String) -> Array[String]:
	var result: Array[String] = []
	for file in DirAccess.get_files_at(dir):
		if file.ends_with(ext):
			result.append(dir.path_join(file))
	for sub in DirAccess.get_directories_at(dir):
		if sub in SKIP_DIRS:
			continue
		result.append_array(_find_files(dir.path_join(sub), ext))
	result.sort()
	return result
