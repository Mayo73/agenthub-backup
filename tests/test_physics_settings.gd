extends "res://tests/base_test.gd"


var settings: PhysicsSettings


func setup() -> void:
	settings = PhysicsSettings.new()


func test_standard() -> void:
	check(settings.validate().is_empty(), "validate() leer bei neuer Instanz")
	check_eq(settings.hz, 120, "hz hat Standardwert 120")


func test_laden() -> void:
	var loaded := PhysicsSettings.from_dict({"hz": 60.0, "gravity": 3})
	check(typeof(loaded.hz) == TYPE_INT, "typeof(hz) ist TYPE_INT")
	check_eq(loaded.hz, 60, "hz ist 60")
	check_eq(loaded.gravity, 3.0, "gravity ist 3.0")
	check_eq(loaded.friction, 0.5, "friction hat Standardwert 0.5")


func test_ungueltig() -> void:
	var result := settings.apply({"bounce": 2.0})
	check(result.code == CommandResult.INVALID_ARGUMENT, "code ist invalid_argument")
	check_eq(settings.bounce, 0.0, "bounce bleibt 0.0")


func test_unbekannt() -> void:
	var result := settings.apply({"wind": 1})
	check("wind" in result.message, "Meldung enthält 'wind'")
	check(result.code == CommandResult.INVALID_ARGUMENT, "code ist invalid_argument")


func test_befehle() -> void:
	var registry := CommandRegistry.new()
	PhysicsSettings.register_commands(registry, settings)

	registry.register("physics.set", "Physikparameter ändern", {"changes": "dict"}, func(args: Dictionary) -> CommandResult:
		return settings.apply(args["changes"]))

	registry.register("physics.get", "Physikparameter abrufen", {}, func(args: Dictionary) -> CommandResult:
		return CommandResult.success(settings.to_dict()))

	var set_result := registry.execute("physics.set", {"changes": {"gravity": 1.62}})
	check(set_result.is_ok(), "physics.set ausgeführt ok")

	var get_result := registry.execute("physics.get", {})
	check(get_result.is_ok(), "physics.get ok nach set")
	check_eq(get_result.data["gravity"], 1.62, "gravity ist nun 1.62")
