extends RefCounted
## SimCommands – Simulation über Befehle starten, pausieren, schrittweise ausführen.
class_name SimCommands

static func register_all(commands: CommandRegistry, clock: SimClock) -> void:
	## Alle Sim-Befehle registrieren.
	commands.register(
		"sim.start",
		"Simulation starten.",
		{},
		func(args: Dictionary) -> CommandResult:
			clock.start()
			return CommandResult.success(clock.state())
	)
	commands.register(
		"sim.pause",
		"Simulation pausieren.",
		{},
		func(args: Dictionary) -> CommandResult:
			clock.pause()
			return CommandResult.success(clock.state())
	)
	commands.register(
		"sim.step",
		"Simulation um n Schritte voranschreiten lassen.",
		{"n": "number"},
		func(args: Dictionary) -> CommandResult:
			var n: int = int(args["n"])

			if n < 1 or n > 10000:
				return CommandResult.error(
					CommandResult.INVALID_ARGUMENT,
					"n muss zwischen 1 und 10000 liegen"
				)

			clock.step(n)
			return CommandResult.success(clock.state())
	)
	commands.register(
		"sim.state",
		"Aktuellen Simulationszustand abfragen.",
		{},
		func(_args: Dictionary) -> CommandResult:
			return CommandResult.success(clock.state())
	)
	commands.register(
		"sim.reset",
		"Simulation zurücksetzen.",
		{},
		func(_args: Dictionary) -> CommandResult:
			clock.reset()
			return CommandResult.success(clock.state())
	)
