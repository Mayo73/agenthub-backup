extends SceneTree
## Führt die Spieltests eines Godot-Projekts aus: res://playtests/<name>.gd (ohne playtest.gd und
## ohne Hilfsdateien, die mit "_" beginnen). Aufruf über hub\tools\spieltest.ps1:
##   godot --path <projekt> [--headless] --fixed-fps 60 --script <dieser Pfad> -- [--test=a,b] [--liste]
## Ausgabe: Zeilen SPIELTEST-START/-ENDE/-OK/-FEHLGESCHLAGEN/-FEHLER/-BILD/-FILM/-WERT,
## am Ende genau eine Zeile "SPIELTESTS: <n> ok, <m> fehlgeschlagen".

const DIR := "res://playtests"
## Höchstdauer eines Tests in Spielsekunden.
const LIMIT := 900.0

## Knoten unter root vor dem ersten Test (z. B. Autoloads); sie bleiben beim Aufräumen stehen.
var _baseline: Array[Node] = []


func _initialize() -> void:
	_main.call_deferred()


func _main() -> void:
	var wanted := PackedStringArray()
	var list_only := false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--test="):
			wanted = arg.trim_prefix("--test=").split(",", false)
		elif arg == "--liste":
			list_only = true

	var names := _names()
	for w in wanted:
		if not names.has(w):
			print("SPIELTEST-FEHLER: Spieltest %s gibt es nicht (vorhanden: %s)" % [w, ", ".join(names)])
			print("SPIELTESTS: 0 ok, 1 fehlgeschlagen")
			quit(1)
			return
	if not wanted.is_empty():
		names = wanted
	if list_only:
		for test_name in names:
			var test: Node = load("%s/%s.gd" % [DIR, test_name]).new()
			print("SPIELTEST-NAME: %s – %s" % [test_name, test.describe()])
			test.free()
		quit(0)
		return

	_baseline = root.get_children()
	var ok := 0
	var failed := 0
	for test_name in names:
		if await _run_one(test_name):
			ok += 1
		else:
			failed += 1
	print("SPIELTESTS: %d ok, %d fehlgeschlagen" % [ok, failed])
	# Für den Filmlauf: Bildnummer am Schluss, damit spieltest.ps1 die Bilddateien zuordnen kann.
	print("SPIELTEST-SCHLUSS: %d" % Engine.get_frames_drawn())
	quit(0 if failed == 0 else 1)


func _names() -> PackedStringArray:
	var result := PackedStringArray()
	var dir := DirAccess.open(DIR)
	if dir == null:
		return result
	for file in dir.get_files():
		if file.ends_with(".gd") and not file.begins_with("_") and file != "playtest.gd":
			result.append(file.get_basename())
	result.sort()
	return result


func _run_one(test_name: String) -> bool:
	var script: Script = load("%s/%s.gd" % [DIR, test_name])
	if script == null:
		print("SPIELTEST-FEHLGESCHLAGEN: %s: Skript lässt sich nicht laden" % test_name)
		return false
	var test: Node = script.new()
	test.name = "Playtest"
	test.process_mode = Node.PROCESS_MODE_ALWAYS
	test.set("_start_frame", Engine.get_physics_frames())
	var scene_path: String = test.get("scene_path")
	if scene_path != "":
		var scene: Node = (load(scene_path) as PackedScene).instantiate()
		test.set("scene", scene)
		root.add_child(scene)
		current_scene = scene
	root.add_child(test)
	print("SPIELTEST-START: %s %d" % [test_name, Engine.get_frames_drawn()])

	var state := {"done": false}
	var body := func() -> void:
		await test.run()
		state["done"] = true
	body.call()
	var limit_frame := Engine.get_physics_frames() + int(LIMIT * Engine.physics_ticks_per_second)
	while not state["done"] and Engine.get_physics_frames() < limit_frame:
		await physics_frame
	if not state["done"]:
		test.fail("Zeitlimit des Spieltests überschritten")

	test.release_all()
	paused = false
	var errors: Array = test.get("errors")
	print("SPIELTEST-ENDE: %s %d" % [test_name, Engine.get_frames_drawn()])
	# Kurz nachlaufen lassen, damit das letzte Standbild im Filmlauf noch die Szene zeigt.
	var after := Engine.get_physics_frames() + Engine.physics_ticks_per_second / 2
	while Engine.get_physics_frames() < after:
		await physics_frame
	if errors.is_empty():
		print("SPIELTEST-OK: %s" % test_name)
	else:
		print("SPIELTEST-FEHLGESCHLAGEN: %s: %s" % [test_name, "; ".join(PackedStringArray(errors))])

	# Aufräumen; die Szene kann inzwischen gewechselt haben.
	for node in root.get_children():
		if not _baseline.has(node):
			node.queue_free()
	await process_frame
	await process_frame
	return errors.is_empty()
