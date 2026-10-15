extends SceneTree
## Headless-Testlauf:  godot --headless --path . --script res://tests/run_tests.gd
##  1. lädt jedes Skript im Projekt (findet Parse-Fehler)
##  2. startet jede Szene unter res://scenes kurz (findet Fehler in _ready)
##  3. führt alle test_*-Methoden aus res://tests/test_*.gd aus
## Exit-Code 0 = alles grün, 1 = mindestens ein Fehler.

const SKIP_DIRS := [".godot", ".git", "addons"]
## Bricht ein Fehler den Ablauf ab, beendet der Watchdog Godot trotzdem.
const WATCHDOG_SECONDS := 120.0

var _passed := 0
var _failed := 0
var _errors := ErrorCatcher.new()


## Sammelt Godot-Fehlermeldungen (z. B. Aufruf auf null), damit ein Test,
## der mit einem Laufzeitfehler abbricht, als FEHLER zählt statt als OK.
class ErrorCatcher extends Logger:
	var _mutex := Mutex.new()
	var _messages: Array[String] = []

	func _log_error(_function: String, file: String, line: int, code: String, rationale: String,
			_editor_notify: bool, _error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		var text := rationale if not rationale.is_empty() else code
		_mutex.lock()
		_messages.append("%s (%s:%d)" % [text, file, line])
		_mutex.unlock()

	func _log_message(_message: String, _error: bool) -> void:
		pass

	func count() -> int:
		_mutex.lock()
		var n := _messages.size()
		_mutex.unlock()
		return n

	func since(start: int) -> Array[String]:
		_mutex.lock()
		var result := _messages.slice(start)
		_mutex.unlock()
		return result


func _initialize() -> void:
	OS.add_logger(_errors)
	create_timer(WATCHDOG_SECONDS).timeout.connect(_on_watchdog)
	_run.call_deferred()


func _on_watchdog() -> void:
	print("  FEHLER  Testlauf nach %d s abgebrochen (Absturz oder Endlosschleife)" % WATCHDOG_SECONDS)
	print("ERGEBNIS: %d ok, %d fehlgeschlagen" % [_passed, _failed + 1])
	quit(2)


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
		var errors_before := _errors.count()
		var instance := packed.instantiate()
		if instance == null:
			_fail(path, "Szene lässt sich nicht instanziieren")
			continue
		root.add_child(instance)
		for i in 5:
			await process_frame
		instance.queue_free()
		await process_frame
		var scene_errors := _errors.since(errors_before)
		if scene_errors.is_empty():
			_ok(path)
		else:
			_fail(path, "Laufzeitfehler: " + "; ".join(scene_errors))

	print("== Tests ==")
	for path in _find_files("res://tests", ".gd"):
		if not path.get_file().begins_with("test_"):
			continue
		var script := load(path) as Script
		if script == null or not script.can_instantiate():
			continue  # oben schon als Fehler gezählt
		for method in script.get_script_method_list():
			var method_name: String = method["name"]
			if method_name.begins_with("test_"):
				_run_test(script, path.get_file(), method_name)

	print("ERGEBNIS: %d ok, %d fehlgeschlagen" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


## Jeder Test bekommt eine frische Instanz. setup()/teardown() (oder
## before_each()/after_each()) laufen davor und danach, falls vorhanden.
func _run_test(script: Script, file: String, method_name: String) -> void:
	var label := "%s::%s" % [file, method_name]
	var errors_before := _errors.count()
	var suite: Object = script.new()
	if suite == null:
		_fail(label, "Testklasse lässt sich nicht erzeugen")
		return
	for hook in ["setup", "before_each"]:
		if suite.has_method(hook):
			suite.call(hook)
	suite.call(method_name)
	for hook in ["teardown", "after_each"]:
		if suite.has_method(hook):
			suite.call(hook)
	var problems: Array[String] = []
	problems.append_array(suite.failures)
	for error in _errors.since(errors_before):
		problems.append("Laufzeitfehler: " + error)
	if problems.is_empty():
		_ok(label)
	else:
		_fail(label, "; ".join(problems))


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
