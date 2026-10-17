extends "res://tests/base_test.gd"


func test_nichts() -> void:
	var result := FishInput.combine(false, false, false, false, false, false)
	check_eq(result.x, 0.0, "thrust bei nichts")
	check_eq(result.y, 0.0, "turn bei nichts")
	check_eq(result.z, 0.0, "climb bei nichts")


func test_vorwaerts() -> void:
	var result := FishInput.combine(true, false, false, false, false, false)
	check_eq(result.x, 1.0, "thrust vorwärts")
	check_eq(result.y, 0.0, "turn vorwärts")
	check_eq(result.z, 0.0, "climb vorwärts")


func test_rueckwaerts() -> void:
	var result := FishInput.combine(false, true, false, false, false, false)
	check_eq(result.x, -0.5, "thrust rückwärts")
	check_eq(result.y, 0.0, "turn rückwärts")
	check_eq(result.z, 0.0, "climb rückwärts")


func test_drehen() -> void:
	var left := FishInput.combine(false, false, true, false, false, false)
	check_eq(left.x, 0.0, "thrust links")
	check_eq(left.y, 1.0, "turn links")
	check_eq(left.z, 0.0, "climb links")
	var right := FishInput.combine(false, false, false, true, false, false)
	check_eq(right.x, 0.0, "thrust rechts")
	check_eq(right.y, -1.0, "turn rechts")
	check_eq(right.z, 0.0, "climb rechts")
	var both := FishInput.combine(false, false, true, true, false, false)
	check_eq(both.x, 0.0, "thrust beide")
	check_eq(both.y, 0.0, "turn beide (neutralisiert)")
	check_eq(both.z, 0.0, "climb beide")


func test_tauchen() -> void:
	var up := FishInput.combine(false, false, false, false, true, false)
	check_eq(up.x, 0.0, "thrust auf")
	check_eq(up.y, 0.0, "turn auf")
	check_eq(up.z, 1.0, "climb auf")
	var combined := FishInput.combine(true, false, false, false, false, true)
	check_eq(combined.x, 1.0, "thrust vorwärts+abtauchen")
	check_eq(combined.y, 0.0, "turn vorwärts+abtauchen")
	check_eq(combined.z, -1.0, "climb vorwärts+abtauchen")


func test_aktionen() -> void:
	Controls.setup()
	check(InputMap.has_action("auftauchen"), "InputMap hat Aktion 'auftauchen'")
	check(InputMap.has_action("abtauchen"), "InputMap hat Aktion 'abtauchen'")
	check(Controls.ACTIONS.has("auftauchen"), "ACTIONS enthält 'auftauchen'")


func test_ohne_tasten() -> void:
	Controls.setup()
	var result := FishInput.read()
	check_eq(result.x, 0.0, "thrust ohne Tasten")
	check_eq(result.y, 0.0, "turn ohne Tasten")
	check_eq(result.z, 0.0, "climb ohne Tasten")
