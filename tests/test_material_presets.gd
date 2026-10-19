extends "res://tests/base_test.gd"

var presets: MaterialPresets


func setup() -> void:
	presets = MaterialPresets.new()


func test_namen() -> void:
	var names: Array[String] = presets.names()
	check_eq(names.size(), 4, "names hat vier Einträge")
	check(names[0] == "holz", "names[0] ist 'holz'")
	check(names[1] == "leuchte", "names[1] ist 'leuchte'")
	check(names[2] == "metall", "names[2] ist 'metall'")
	check(names[3] == "stein", "names[3] ist 'stein'")


func test_vorlage() -> void:
	var metall: Dictionary = presets.get_preset("metall")
	check_eq(metall["metallic"], 1.0, "get_preset('metall')['metallic'] ist 1.0")

	var glas: Dictionary = presets.get_preset("glas")
	check(glas.is_empty(), "get_preset('glas') leer")


func test_kopie() -> void:
	var m: Dictionary = presets.get_preset("holz")
	m["roughness"] = 0.1
	var neu: Dictionary = presets.get_preset("holz")
	check_eq(neu["roughness"], 0.8, "get_preset('holz')['roughness'] bleibt 0.8")


func test_pruefen() -> void:
	# Stein ohne Fehler
	var stein_errors: Array[String] = presets.validate(presets.get_preset("stein"))
	check(stein_errors.is_empty(), "validate(get_preset('stein')) leer")

	# Ungültiges Material prüfen
	var ungultig: Dictionary = {"albedo": [1, 2, 0], "roughness": 0.5, "metallic": 2.0}
	var fehler: Array[String] = presets.validate(ungultig)
	check(fehler.size() >= 2, "validate ungültiges Material mindestens zwei Fehler")
	check("albedo braucht drei Werte zwischen 0 und 1" in fehler, "Fehler enthält 'albedo ...'")
	check("metallic muss zwischen 0 und 1 liegen" in fehler, "Fehler enthält 'metallic ...'")


func test_mischen() -> void:
	var holz: Dictionary = presets.get_preset("holz")
	var metall: Dictionary = presets.get_preset("metall")

	# metallic bei t=0.5 sollte 0.5 sein (lerp(0.0, 1.0, 0.5))
	var gemischt: Dictionary = presets.blend(holz, metall, 0.5)
	check_eq(gemischt["metallic"], 0.5, "blend(..., 0.5)['metallic'] ist 0.5")

	# t=2.0 auf 1 begrenzt: roughness sollte Metall-Wert sein (0.3)
	var gemischt_clamped: Dictionary = presets.blend(holz, metall, 2.0)
	check_eq(gemischt_clamped["roughness"], 0.3, "blend(..., 2.0)['roughness'] ist 0.3")


func test_farbe() -> void:
	var stein: Dictionary = presets.get_preset("stein")
	var farbe: Color = presets.to_color(stein)
	check(farbe == Color(0.5, 0.5, 0.5), "to_color(get_preset('stein')) ist Color(0.5, 0.5, 0.5)")
