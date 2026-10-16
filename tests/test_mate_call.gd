extends "res://tests/base_test.gd"
## Tests für MateCall (Partnerruf)

var m: MateCall


func setup() -> void:
	m = MateCall.new()


func test_ohne_ruf() -> void:
	check_eq(m.can_call(), false, "can_call sollte false sein ohne Ladung")
	check_eq(m.call_partner(Vector2.ZERO, 0.0), false, "call_partner sollte false sein ohne Ladung")
	check_eq(m.partner_pos == null, true, "partner_pos sollte null sein")


func test_rufen() -> void:
	m.add_charge()
	check_eq(m.can_call(), true, "can_call sollte wahr sein nach add_charge")
	check_eq(m.call_partner(Vector2(10, 0), 0.0), true, "call_partner sollte wahr sein")
	check_eq(m.partner_pos, Vector2(260, 0), "partner_pos sollte (260, 0) sein")
	check_eq(m.charges, 0, "charges sollte 0 sein nach call_partner")


func test_nur_ein_partner() -> void:
	m.add_charge()
	m.add_charge()
	check_eq(m.call_partner(Vector2.ZERO, 0.0), true, "erster Ruf sollte gelingen")
	check_eq(m.can_call(), false, "can_call sollte falsch sein (Partner noch da)")
	check_eq(m.call_partner(Vector2.ZERO, 0.0), false, "zweiter Ruf sollte scheitern")
	check_eq(m.charges, 1, "charges sollte 1 sein (eine Ladung übrig)")
	m.finish()
	check_eq(m.can_call(), true, "can_call sollte wahr sein nach finish")


func test_erreichen() -> void:
	m.add_charge()
	m.call_partner(Vector2(10, 0), 0.0)

	check_eq(m.reached(Vector2(240, 0), 12.0), true, "erreicht bei Distanz <= Radius")
	check_eq(m.reached(Vector2(200, 0), 12.0), false, "nicht erreicht bei großer Distanz")

	m.finish()
	check_eq(m.reached(Vector2(260, 0), 12.0), false, "nach finish nicht mehr erreichbar")
