extends "res://tests/base_test.gd"

var registry: CommandRegistry
var clock: SimClock


func setup() -> void:
	registry = CommandRegistry.new()
	clock = SimClock.new()
	SimCommands.register_all(registry, clock)


func teardown() -> void:
	pass


func test_start_pause() -> void:
	var result := registry.execute("sim.start", {})
	check(result.is_ok(), "sim.start sollte erfolgreich sein")
	var data := result.data as Dictionary
	check(data["running"], "nach sim.start sollte running wahr sein")

	result = registry.execute("sim.pause", {})
	check(result.is_ok(), "sim.pause sollte erfolgreich sein")
	data = result.data as Dictionary
	check(not data["running"], "nach sim.pause sollte running falsch sein")


func test_schritte() -> void:
	var result := registry.execute("sim.step", {"n": 120})
	check(result.is_ok(), "sim.step mit n=120 sollte erfolgreich sein")
	var data := result.data as Dictionary
	check_eq(data["step"], 120, "nach 120 Schritten sollte step 120 sein")
	check_eq(data["time"], 1.0, "nach 120 Schritten sollte time 1.0 sein (120/120)")


func test_schritte_als_float() -> void:
	var result := registry.execute("sim.step", {"n": 3.0})
	check(result.is_ok(), "sim.step mit n=3.0 sollte erfolgreich sein")
	var data := result.data as Dictionary
	check_eq(data["step"], 3, "nach 3 Schritten sollte step 3 sein")


func test_ungueltig() -> void:
	registry.execute("sim.start", {})

	var result := registry.execute("sim.step", {"n": 0})
	check(not result.is_ok(), "sim.step mit n=0 sollte fehlschlagen")
	check(result.code == CommandResult.INVALID_ARGUMENT, "Fehlercode sollte invalid_argument sein")

	registry.execute("sim.reset", {})

	result = registry.execute("sim.step", {"n": 20000})
	check(not result.is_ok(), "sim.step mit n=20000 sollte fehlschlagen")
	check(result.code == CommandResult.INVALID_ARGUMENT, "Fehlercode sollte invalid_argument sein")

	var data := clock.state() as Dictionary
	check_eq(data["step"], 0, "step_count sollte nach ungültigen Aufrufen 0 bleiben")


func test_reset() -> void:
	clock.start()
	for i in range(10):
		clock.step(1)

	check_eq(clock.step_count, 10, "nach 10 Schritten sollte step_count 10 sein")

	var result := registry.execute("sim.reset", {})
	check(result.is_ok(), "sim.reset sollte erfolgreich sein")
	var data := result.data as Dictionary
	check_eq(data["step"], 0, "nach reset sollte step 0 sein")
	check(not data["running"], "nach reset sollte running falsch sein")
