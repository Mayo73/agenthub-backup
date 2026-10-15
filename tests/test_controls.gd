extends "res://tests/base_test.gd"


func test_alle_aktionen_angelegt() -> void:
	Controls.setup()
	for action in Controls.ACTIONS:
		check(InputMap.has_action(action), "Aktion fehlt: %s" % action)


func test_doppeltes_setup_verdoppelt_nichts() -> void:
	Controls.setup()
	var before := InputMap.action_get_events("gas").size()
	Controls.setup()
	check_eq(InputMap.action_get_events("gas").size(), before)


func test_pause_taste() -> void:
	Controls.setup()
	check(InputMap.has_action("pause"), "InputMap hat keine Aktion 'pause'")
	check("pause" in Controls.ACTIONS, "'pause' fehlt in Controls.ACTIONS")
