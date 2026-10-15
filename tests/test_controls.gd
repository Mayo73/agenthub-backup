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


func teardown() -> void:
	Controls.reset_defaults()


func test_taste_lesen() -> void:
	Controls.setup()
	check_eq(Controls.key_for("gas"), KEY_W, "erste Taste von 'gas' sollte KEY_W sein")
	check_eq(Controls.key_for("gibtsnicht"), 0, "unbekannte Aktion sollte 0 zurückgeben")


func test_taste_aendern() -> void:
	Controls.setup()
	Controls.rebind_key("gas", KEY_I)
	check_eq(Controls.key_for("gas"), KEY_I, "erste Taste von 'gas' sollte jetzt KEY_I sein")
	var events := InputMap.action_get_events("gas")
	var key_count := 0
	for event in events:
		if event is InputEventKey:
			key_count += 1
	check_eq(key_count, 1, "es gibt genau einen InputEventKey bei 'gas'")
	check(events.size() == 2, "es gibt zwei Ereignisse insgesamt bei 'gas'")
	var non_key_events := 0
	for event in events:
		if not (event is InputEventKey):
			non_key_events += 1
	check_eq(non_key_events, 1, "es gibt genau ein Ereignis, das kein InputEventKey ist (Gamepad)")


func test_belegung_anwenden() -> void:
	Controls.setup()
	Controls.apply_bindings({"bremse": 75.0, "quatsch": 5})
	check_eq(Controls.key_for("bremse"), 75, "Taste für 'bremse' sollte 75 sein")
	check(not InputMap.has_action("quatsch"), "unbekannte Aktion 'quatsch' sollte nicht existieren")


func test_zuruecksetzen() -> void:
	Controls.setup()
	Controls.rebind_key("gas", KEY_I)
	Controls.reset_defaults()
	check_eq(Controls.key_for("gas"), KEY_W, "nach Reset sollte 'gas' wieder KEY_W haben")


func test_namen() -> void:
	check_eq(Controls.LABELS.size(), Controls.ACTIONS.size(), "LABELS sollte genauso viele Einträge wie ACTIONS haben")
	check_eq(Controls.key_name(KEY_W), "W", "key_name(KEY_W) sollte 'W' sein")
	check_eq(Controls.key_name(0), "–", "key_name(0) sollte '–' sein")
