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
