extends "res://tests/base_test.gd"

var model: SceneModel
var registry: CommandRegistry


func setup() -> void:
	model = SceneModel.new()
	registry = CommandRegistry.new()
	TemplateCommands.register_all(registry, model)


func test_liste() -> void:
	var result := registry.execute("template.list", {})
	check(result.is_ok(), "Befehl template.list erfolgreich")

	var data := result.data
	check(data.has("templates"), "Daten enthalten templates-Array")

	var templates = data["templates"]
	check_eq(templates.size(), 2, "Es gibt 2 Vorlagen")

	var first_entry: Dictionary = templates[0]
	check_eq(first_entry.get("name", ""), "leer_2d", "Erster Eintrag ist leer_2d")


func test_anwenden_2d() -> void:
	var result := registry.execute("template.apply", {"name": "leer_2d"})
	check(result.is_ok(), "Befehl template.apply für leer_2d erfolgreich")

	check_eq(result.data.get("objects", -1), 3, "Daten enthalten objects=3")
	check_eq(model.order.size(), 3, "Modell enthält 3 Objekte")


func test_anwenden_3d() -> void:
	var result := registry.execute("template.apply", {"name": "leer_3d"})
	check(result.is_ok(), "Befehl template.apply für leer_3d erfolgreich")

	check_eq(result.data.get("objects", -1), 4, "Daten enthalten objects=4")


func test_unbekannt() -> void:
	var size_vorher := model.order.size()
	var result := registry.execute("template.apply", {"name": "gibts"})

	check(not result.is_ok(), "Befehl bei unbekannter Vorlage fehlschlägt")
	check_eq(result.code, "not_found", "Fehlercode ist not_found")
	check_eq(model.order.size(), size_vorher, "Modell unverändert nach fehlgeschlagenem Befehl")
