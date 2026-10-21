extends "res://tests/base_test.gd"

var layers: SpriteLayers
var z_idx: int


func setup() -> void:
	layers = SpriteLayers.new()


func test_standard() -> void:
	layers = SpriteLayers.new()
	check_eq(layers.layers.size(), 4, "Anzahl der Ebenen")
	check(layers.layers[0] == "hintergrund", "erste Ebene ist hintergrund")
	check(layers.layers[1] == "welt", "zweite Ebene ist welt")
	check(layers.layers[2] == "figuren", "dritte Ebene ist figuren")
	check(layers.layers[3] == "vordergrund", "vierte Ebene ist vordergrund")

	z_idx = layers.z_index_of("o1")
	check_eq(z_idx, 100, "z_index_of('o1') ist 100 (Ebene welt)")


func test_zuordnen() -> void:
	layers = SpriteLayers.new()
	var result := layers.assign("o1", "vordergrund")
	check(result.is_ok(), "Zuordnung zu vordergrund erfolgreich")

	z_idx = layers.z_index_of("o1")
	check_eq(z_idx, 300, "z_index_of('o1') nach Zuordnung zu vordergrund ist 300")

	result = layers.assign("o1", "gibtsnicht")
	check(not result.is_ok(), "Zuordnung zu nicht existierender Ebene fehlgeschlagen")
	check(result.code == "not_found", "Fehlercode ist not_found")


func test_neue_ebene() -> void:
	layers = SpriteLayers.new()
	var result := layers.add_layer("himmel", 0)
	check(result.is_ok(), "neue Ebene bei Index 0 erfolgreich")
	check(layers.layers[0] == "himmel", "layers[0] ist himmel")

	result = layers.add_layer("himmel", 0)
	check(not result.is_ok(), "Duplizieren derselben Ebene fehlgeschlagen")
	check(result.code == "conflict", "Fehlercode ist conflict")


func test_verschieben() -> void:
	layers = SpriteLayers.new()
	var result := layers.move_layer("hintergrund", 99)
	check(result.is_ok(), "Verschieben nach hinten erfolgreich")

	var last_idx: int = layers.layers.size() - 1
	check(layers.layers[last_idx] == "hintergrund", "letzte Ebene ist hintergrund")


func test_entfernen() -> void:
	layers = SpriteLayers.new()
	layers.assign("o2", "figuren")

	var result := layers.remove_layer("figuren")
	check(result.is_ok(), "Ebene figuren erfolgreich entfernt")

	var layer_o2: String = layers.layer_of("o2")
	check(layer_o2 == "hintergrund", "layer_of('o2') nach Entfernen ist hintergrund")


func test_speichern() -> void:
	layers = SpriteLayers.new()
	layers.assign("obj_a", "vordergrund")
	layers.assign("obj_b", "figuren")

	var dict: Dictionary = layers.to_dict()
	var restored: SpriteLayers = SpriteLayers.from_dict(dict)

	check_eq(restored.layers.size(), layers.layers.size(), "Ebenen-Anzahl stimmt nach Wiederherstellung")
	for i in range(layers.layers.size()):
		check_eq(restored.layers[i], layers.layers[i], "Ebene %d stimmt" % i)

	check_eq(restored.assignment.size(), layers.assignment.size(), "Zuordnungen-Stimmenach Wiederherstellung")
	check_eq(restored.assignment["obj_a"], layers.assignment["obj_a"], "obj_a-Zuordnung stimmt")
	check_eq(restored.assignment["obj_b"], layers.assignment["obj_b"], "obj_b-Zuordnung stimmt")
