class_name Controls
extends RefCounted
## Tastatur- und Gamepad-Belegung. Wird beim Start einmal angelegt (statt in project.godot),
## damit sie im Code lesbar bleibt. Tasten zählen nach ihrer Lage, passen also auch auf QWERTZ.

const ACTIONS := ["gas", "bremse", "links", "rechts", "handbremse", "zuruecksetzen", "neustart", "pause"]

const LABELS := {
	"gas": "Gas", "bremse": "Bremse", "links": "Links", "rechts": "Rechts",
	"handbremse": "Handbremse", "zuruecksetzen": "Zurücksetzen", "neustart": "Neustart", "pause": "Pause",
}


static func setup() -> void:
	_add("gas", [KEY_W, KEY_UP], [], [[JOY_AXIS_TRIGGER_RIGHT, 1.0]])
	_add("bremse", [KEY_S, KEY_DOWN], [], [[JOY_AXIS_TRIGGER_LEFT, 1.0]])
	_add("links", [KEY_A, KEY_LEFT], [JOY_BUTTON_DPAD_LEFT], [[JOY_AXIS_LEFT_X, -1.0]])
	_add("rechts", [KEY_D, KEY_RIGHT], [JOY_BUTTON_DPAD_RIGHT], [[JOY_AXIS_LEFT_X, 1.0]])
	_add("handbremse", [KEY_SPACE], [JOY_BUTTON_A, JOY_BUTTON_RIGHT_SHOULDER], [])
	_add("zuruecksetzen", [KEY_R], [JOY_BUTTON_Y], [])
	_add("neustart", [KEY_ENTER, KEY_KP_ENTER], [JOY_BUTTON_START], [])
	_add("pause", [KEY_ESCAPE], [JOY_BUTTON_BACK], [])


static func _add(action: String, keys: Array, buttons: Array, axes: Array) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action, 0.2)
	for key in keys:
		var key_event := InputEventKey.new()
		key_event.physical_keycode = key
		InputMap.action_add_event(action, key_event)
	for button in buttons:
		var button_event := InputEventJoypadButton.new()
		button_event.button_index = button
		InputMap.action_add_event(action, button_event)
	for axis in axes:
		var axis_event := InputEventJoypadMotion.new()
		axis_event.axis = axis[0]
		axis_event.axis_value = axis[1]
		InputMap.action_add_event(action, axis_event)


## Erste Taste (physical_keycode) einer Aktion, 0 wenn es keine gibt.
static func key_for(action: String) -> int:
	if not InputMap.has_action(action):
		return 0
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return event.physical_keycode
	return 0


## Ersetzt alle Tasten einer Aktion durch genau eine. Gamepad-Belegungen bleiben.
static func rebind_key(action: String, keycode: int) -> void:
	if not InputMap.has_action(action):
		return
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			InputMap.action_erase_event(action, event)
	var key_event := InputEventKey.new()
	key_event.physical_keycode = keycode
	InputMap.action_add_event(action, key_event)


## Übernimmt geänderte Tasten (Aktion → Tastencode). Unbekannte Aktionen und Codes <= 0 werden ignoriert.
static func apply_bindings(keys: Dictionary) -> void:
	for action in keys:
		if action in ACTIONS and int(keys[action]) > 0:
			rebind_key(action, int(keys[action]))


## Stellt die Standardbelegung wieder her.
static func reset_defaults() -> void:
	for action in ACTIONS:
		if InputMap.has_action(action):
			InputMap.erase_action(action)
	setup()


## Lesbarer Name einer Taste, "–" für keine.
static func key_name(keycode: int) -> String:
	return OS.get_keycode_string(keycode) if keycode > 0 else "–"
