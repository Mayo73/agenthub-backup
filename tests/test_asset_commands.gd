extends "res://tests/base_test.gd"

var library: AssetLibrary
var registry: CommandRegistry


func setup() -> void:
	library = AssetLibrary.new()
	registry = CommandRegistry.new()
	AssetCommands.register_all(registry, library)


func test_aufnehmen() -> void:
	var args := {"path": "held.png", "name": "Held"}
	var result := registry.execute("asset.add", args)
	check(result.is_ok(), "asset.add sollte erfolgreich sein")

	var data: Dictionary = result.data
	check_eq(data["kind"], "bild", "data[\"kind\"] sollte \"bild\" sein")


func test_liste() -> void:
	library.add("held.png", "Held")
	library.add("musik.ogg", "Musik")

	var args_list_all := {"kind": ""}
	var result_all := registry.execute("asset.list", args_list_all)
	check(result_all.is_ok(), "asset.list sollte erfolgreich sein")
	var data_all: Dictionary = result_all.data
	check_eq(data_all["assets"].size(), 2, "sollte 2 Assets haben")

	var args_list_bild := {"kind": "bild"}
	var result_bild := registry.execute("asset.list", args_list_bild)
	check(result_bild.is_ok(), "asset.list mit kind=bild sollte erfolgreich sein")
	var data_bild: Dictionary = result_bild.data
	check_eq(data_bild["assets"].size(), 1, "sollte 1 Bild-Asset haben")


func test_entfernen() -> void:
	library.add("held.png", "Held")

	var args := {"id": "a9"}
	var result := registry.execute("asset.remove", args)
	check(not result.is_ok(), "remove für nicht existierendes Asset sollte fehlschlagen")
	check_eq(result.code, "not_found", "Fehlercode sollte \"not_found\" sein")


func test_formate() -> void:
	var args := {}
	var result := registry.execute("asset.formats", args)
	check(result.is_ok(), "asset.formats sollte erfolgreich sein")
	var data: Dictionary = result.data
	check(data["text"].begins_with("Bilder:"), "data[\"text\"] sollte mit \"Bilder:\" beginnen")
