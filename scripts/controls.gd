class_name Controls
extends RefCounted
## Tastatur- und Gamepad-Belegung. Wird beim Start einmal angelegt (statt in project.godot),
## damit sie im Code lesbar bleibt. Tasten zählen nach ihrer Lage, passen also auch auf QWERTZ.

const ACTIONS := ["gas", "bremse", "links", "rechts", "handbremse", "zuruecksetzen", "neustart", "pause"]


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
