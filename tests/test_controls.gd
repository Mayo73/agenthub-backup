extends "res://tests/base_test.gd"


func test_aktionen_angelegt() -> void:
	Controls.setup()
	for action in Controls.ACTIONS:
		check(InputMap.has_action(action), "Aktion '%s' fehlt" % action)


func test_schwimmen_mit_maus() -> void:
	Controls.setup()
	var found := false
	for event in InputMap.action_get_events("schwimmen"):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			found = true
	check(found, "schwimmen liegt auf der linken Maustaste")


func test_logischer_tastencode() -> void:
	Controls.setup()
	var events := InputMap.action_get_events("pause")
	var keycount := 0
	var escapecount := 0
	for event in events:
		if event is InputEventKey:
			keycount += 1
			if event.keycode == KEY_ESCAPE and event.physical_keycode == 0:
				escapecount += 1
	check(escapecount == 1, "genau ein Event mit keycode == KEY_ESCAPE und physical_keycode == 0")
	check(keycount - escapecount == 1, "genau ein Event mit physical_keycode == KEY_ESCAPE")


func test_logische_taste_loest_aus() -> void:
	Controls.setup()
	var e := InputEventKey.new()
	e.keycode = KEY_D
	e.pressed = true
	check(e.is_action("rechts"), "KEY_D löst rechts aus")
	e = InputEventKey.new()
	e.keycode = KEY_ESCAPE
	e.pressed = true
	check(e.is_action("pause"), "KEY_ESCAPE löst pause aus")


func test_maus_unveraendert() -> void:
	Controls.setup()
	var events := InputMap.action_get_events("schwimmen")
	check(events.size() == 1, "schwimmen hat genau ein Ereignis")
	check(events[0] is InputEventMouseButton, "dieses ist ein InputEventMouseButton")
