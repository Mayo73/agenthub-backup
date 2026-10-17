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
	check_eq(key_count, 2, "zwei InputEventKey bei 'gas' (Lage und logisch)")
	check(events.size() == 3, "drei Ereignisse insgesamt bei 'gas'")
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


func test_logischer_tastencode() -> void:
	Controls.setup()
	var events := InputMap.action_get_events("pause")
	var logical_esc := 0
	var physical_esc := 0
	for event in events:
		if event is InputEventKey:
			if event.keycode == KEY_ESCAPE and event.physical_keycode == 0:
				logical_esc += 1
			if event.physical_keycode == KEY_ESCAPE:
				physical_esc += 1
	check_eq(logical_esc, 1, "ein logischer ESC mit keycode == KEY_ESCAPE und physical_keycode == 0")
	check_eq(physical_esc, 1, "ein physischer ESC mit physical_keycode == KEY_ESCAPE")


func test_logisch_nach_aendern() -> void:
	Controls.setup()
	Controls.rebind_key("gas", KEY_I)
	var events := InputMap.action_get_events("gas")
	var has_i := false
	var has_w_logical := false
	var has_w_physical := false
	for event in events:
		if event is InputEventKey:
			if event.keycode == KEY_I:
				has_i = true
			if event.keycode == KEY_W:
				has_w_logical = true
			if event.physical_keycode == KEY_W:
				has_w_physical = true
	check(has_i, "es gibt ein InputEventKey mit keycode == KEY_I")
	check(not has_w_logical, "kein InputEventKey mit keycode == KEY_W")
	check(not has_w_physical, "kein InputEventKey mit physical_keycode == KEY_W")
	check_eq(Controls.key_for("gas"), KEY_I, "key_for('gas') ist KEY_I")


func test_logische_taste_loest_aus() -> void:
	Controls.setup()
	var e := InputEventKey.new()
	e.keycode = KEY_ESCAPE
	e.pressed = true
	check(e.is_action("pause"), "tastenschlag mit keycode == KEY_ESCAPE löst 'pause' aus")
