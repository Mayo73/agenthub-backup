extends "res://tests/base_test.gd"
## Tests für CapabilityDoc.

func setup() -> void:
	pass


func test_parameter() -> void:
	# params_text mit zwei Parametern, sortiert: parent vor type
	var result1 := CapabilityDoc.params_text({"type": "string", "parent": "string"})
	check_eq(result1, "parent: string, type: string", "params mit zwei Schlüsseln")

	# params_text mit leerem Dictionary → "–"
	var result2 := CapabilityDoc.params_text({})
	check_eq(result2, "–", "leeres Dictionary gibt – zurück")


func test_gruppe() -> void:
	# group_of mit Punkt
	var result1 := CapabilityDoc.group_of("scene.add")
	check_eq(result1, "scene", "grupp von scene.add ist scene")

	# group_of ohne Punkt → ganze Name
	var result2 := CapabilityDoc.group_of("hilfe")
	check_eq(result2, "hilfe", "grupp von hilfe ist hilfe")


func test_tabelle() -> void:
	# Registry mit zwei Befehlen erstellen
	var registry: CommandRegistry = CommandRegistry.new()

	registry.register(
		"scene.add",
		"Szeneobjekt hinzufügen",
		{"type": "string", "parent": "string"},
		func(args: Dictionary) -> CommandResult: return CommandResult.success()
	)

	registry.register(
		"sim.start",
		"Simulation starten",
		{},
		func(args: Dictionary) -> CommandResult: return CommandResult.success()
	)

	var lines := CapabilityDoc.markdown(registry).split("\n")
	check_eq(lines.size(), 6, "markdown hat 6 Zeilen")
	check(lines[4].begins_with("| scene.add | scene |"), "Zeile 4 beginnt mit | scene.add | scene |")


func test_gruppen() -> void:
	# Registry mit zwei Befehlen erstellen
	var registry: CommandRegistry = CommandRegistry.new()

	registry.register(
		"scene.add",
		"Szeneobjekt hinzufügen",
		{"type": "string", "parent": "string"},
		func(args: Dictionary) -> CommandResult: return CommandResult.success()
	)

	registry.register(
		"sim.start",
		"Simulation starten",
		{},
		func(args: Dictionary) -> CommandResult: return CommandResult.success()
	)

	var groups := CapabilityDoc.groups(registry)
	check_eq(groups, ["scene", "sim"], "gruppen enthält scene und sim, sortiert")
