class_name Playtest
extends Node
## Grundlage für Spieltests mit simulierter Eingabe. Ein Spieltest liegt als playtests/<name>.gd
## im Projekt, erweitert diese Klasse und überschreibt run(). Dateien, die mit "_" beginnen, sind
## gemeinsame Hilfen und keine Tests. Ausgeführt wird vom Hub (hub\tools\spieltest.ps1), nicht von
## verify.cmd. Die Vorlage liegt in hub\tools\vorlagen; diese Datei ist geschützt.

## Szene, die vor run() geladen wird (leer: keine).
var scene_path := ""
## Die geladene Szene (oder null).
var scene: Node = null
## Gefundene Fehler; bestanden ist der Test, wenn die Liste am Ende leer ist.
var errors: Array[String] = []
var _start_frame := 0


## Kurze Beschreibung für die Liste der Spieltests.
func describe() -> String:
	return ""


## Ablauf des Tests. Mit await auf die Hilfsfunktionen warten.
func run() -> void:
	pass


## Spielzeit in Sekunden seit Testbeginn. Gerechnet wird schneller als Echtzeit, aber gleichmäßig.
func now() -> float:
	return float(Engine.get_physics_frames() - _start_frame) / Engine.physics_ticks_per_second


func wait(seconds: float) -> void:
	var end := now() + seconds
	while now() < end:
		await get_tree().physics_frame


## Hält eine Aktion gedrückt; strength 0..1, z. B. halbe Lenkung.
func press(action: String, strength: float = 1.0) -> void:
	_send(action, true, strength)


func release(action: String) -> void:
	_send(action, false, 0.0)


## Kurz drücken und loslassen, wie ein Tastendruck.
func tap(action: String) -> void:
	press(action)
	await wait(0.1)
	release(action)
	await wait(0.1)


func hold(action: String, seconds: float, strength: float = 1.0) -> void:
	press(action, strength)
	await wait(seconds)
	release(action)


## Lässt alle gedrückten Aktionen los.
func release_all() -> void:
	for action in InputMap.get_actions():
		if Input.is_action_pressed(action):
			release(action)


## Simuliert eine echte Taste. physical = false schickt nur den logischen Tastencode, so wie es
## manche Fernsteuerungen tun (z. B. Computer Use); damit lässt sich die Tastenbelegung prüfen.
func key(keycode: Key, pressed: bool, physical: bool = true) -> void:
	var ev := InputEventKey.new()
	ev.keycode = keycode
	if physical:
		ev.physical_keycode = keycode
	ev.pressed = pressed
	Input.parse_input_event(ev)


## Taste kurz drücken (siehe key()).
func tap_key(keycode: Key, physical: bool = true) -> void:
	key(keycode, true, physical)
	await wait(0.1)
	key(keycode, false, physical)
	await wait(0.1)


## Wartet, bis condition.call() true liefert. Nach timeout Sekunden: Fehler what, Ergebnis false.
func until(condition: Callable, timeout: float, what: String) -> bool:
	var end := now() + timeout
	while now() < end:
		if condition.call():
			return true
		await get_tree().physics_frame
	fail("%s (nach %.0f s nicht erreicht)" % [what, timeout])
	return false


func check(condition: bool, what: String) -> void:
	if not condition:
		fail(what)


func fail(what: String) -> void:
	errors.append(what)
	print("SPIELTEST-FEHLER: %s" % what)


## Merkt einen Moment für ein Standbild (im Filmlauf als <test>-<name>.png gespeichert).
func shot(shot_name: String) -> void:
	print("SPIELTEST-BILD: %s %d" % [shot_name, Engine.get_frames_drawn()])


## Merkt einen Zeitraum für einen Bildstreifen (mehrere Bilder nacheinander) und wartet so lange.
func film(film_name: String, seconds: float) -> void:
	var start := Engine.get_frames_drawn()
	await wait(seconds)
	print("SPIELTEST-FILM: %s %d %d" % [film_name, start, Engine.get_frames_drawn()])


## Gibt einen Messwert aus. Er erscheint im Bericht; "tempo" usw. nutzt die Tonanalyse.
func measure(measure_name: String, v: Variant) -> void:
	print("SPIELTEST-WERT: %s %s %d" % [measure_name, str(v), Engine.get_frames_drawn()])


## Lädt die Szene neu (z. B. nach dem Ändern von Einstellungen).
func reload_scene() -> void:
	release_all()
	get_tree().paused = false
	if scene != null and is_instance_valid(scene):
		scene.queue_free()
		await get_tree().process_frame
	scene = (load(scene_path) as PackedScene).instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	await get_tree().process_frame


func _send(action: String, pressed: bool, strength: float) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = pressed
	ev.strength = strength
	Input.parse_input_event(ev)
