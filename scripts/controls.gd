class_name Controls
extends RefCounted
## Tastatur- und Mausbelegung. Wird beim Start einmal angelegt (statt in project.godot),
## damit sie im Code lesbar bleibt. Tasten zählen nach ihrer Lage, passen also auch auf QWERTZ.

const ACTIONS := ["hoch", "runter", "links", "rechts", "schwimmen", "pause", "rufen", "auftauchen", "abtauchen"]


static func setup() -> void:
	_add("hoch", [KEY_W, KEY_UP], [])
	_add("runter", [KEY_S, KEY_DOWN], [])
	_add("links", [KEY_A, KEY_LEFT], [])
	_add("rechts", [KEY_D, KEY_RIGHT], [])
	_add("schwimmen", [], [MOUSE_BUTTON_LEFT])
	_add("pause", [KEY_ESCAPE], [])
	_add("rufen", [KEY_C], [MOUSE_BUTTON_RIGHT])
	_add("auftauchen", [KEY_SPACE], [])
	_add("abtauchen", [KEY_SHIFT, KEY_CTRL], [])


## Hängt für eine Taste zwei Ereignisse an: nach Lage (physical_keycode, passt auf QWERTZ)
## und nach logischem Tastencode (keycode), wie ihn Fernsteuerungen schicken.
static func _add_key(action: String, key: int) -> void:
	var physical := InputEventKey.new()
	physical.physical_keycode = key
	InputMap.action_add_event(action, physical)
	var logical := InputEventKey.new()
	logical.keycode = key
	InputMap.action_add_event(action, logical)


static func _add(action: String, keys: Array, mouse_buttons: Array) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action, 0.2)
	for key in keys:
		_add_key(action, key)
	for button in mouse_buttons:
		var mouse_event := InputEventMouseButton.new()
		mouse_event.button_index = button
		InputMap.action_add_event(action, mouse_event)


## Tastenrichtung aus WASD/Pfeiltasten, Länge höchstens 1.
static func key_vector() -> Vector2:
	return Input.get_vector("links", "rechts", "hoch", "runter")
