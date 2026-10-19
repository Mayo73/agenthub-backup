extends "res://tests/base_test.gd"

var model: SceneModel

func setup() -> void:
	model = SceneModel.new()

func test_kennungen() -> void:
	var id1: String = model.add_object("Node2D")
	var id2: String = model.add_object("Sprite2D")
	check_eq(id1, "o1", "erstes Objekt bekommt Kennung o1")
	check_eq(id2, "o2", "zweites Objekt bekommt Kennung o2")

	model.remove_object(id1)
	var id3: String = model.add_object("RigidBody2D")
	check_eq(id3, "o3", "neues Objekt bekommt o3 nach Entfernen von o1")

func test_eltern() -> void:
	var a: String = model.add_object("Node2D")
	var b: String = model.add_object("Sprite2D", a)
	var c: String = model.add_object("Sprite2D", a)

	check_eq(model.children(a).size(), 2, "a hat zwei Kinder")
	check_eq(model.children(""), ["o1"], "oberste Ebene hat nur o1")

	var bad_id: String = model.add_object("Sprite2D", "o99")
	check_eq(bad_id, "", "ungültiges Elternobjekt liefert leere Kennung")

func test_eigenschaften() -> void:
	var id: String = model.add_object("RigidBody2D", "", {"mass": 2.0})

	check_eq(model.get_property(id, "mass"), 2.0, "Eigenschaft mass ist 2.0")

	check(model.set_property(id, "mass", 5.0), "set_property gibt true zurück")
	check_eq(model.get_property(id, "mass"), 5.0, "mass wurde auf 5.0 geandert")

	check_eq(model.get_property(id, "fehlt", 7), 7, "fehlende Eigenschaft gibt default zuruck")

	check(not model.set_property("o99", "mass", 1.0), "set_property fur nicht existierendes Objekt gibt false")

func test_entfernen_mit_kindern() -> void:
	var parent: String = model.add_object("Node2D")
	model.add_object("Sprite2D", parent)
	model.add_object("CollisionShape2D", parent)

	check_eq(model.objects.size(), 3, "anfangs drei Objekte")
	check(model.remove_object(parent), "Entfernen liefert true")

	check_eq(model.objects.size(), 0, "nach Entfernen: objects.size() 0")
	check_eq(model.order.size(), 0, "nach Entfernen: order.size() 0")

func test_kopie_unabhangig() -> void:
	var id: String = model.add_object("RigidBody2D", "", {"mass": 2.0})

	var obj_dict: Dictionary = model.get_object(id)
	obj_dict["props"]["mass"] = 9.0

	check_eq(model.get_property(id, "mass"), 2.0, "Andern der Kopie andert Modell nicht")

func test_duplizieren() -> void:
	var parent: String = model.add_object("Node2D", "", {"name": "parent"})
	var original: String = model.add_object("RigidBody2D", parent, {"mass": 2.0})

	var duplicated: String = model.duplicate_object(original)
	check(not duplicated.is_empty(), "dupliziertes Objekt bekommt neue Kennung")
	check(duplicated != original, "neue Kennung ist verschieden von alter")

	var dup_obj: Dictionary = model.get_object(duplicated)
	var orig_obj: Dictionary = model.get_object(original)

	check_eq(dup_obj["type"], orig_obj["type"], "gleicher Typ")
	check_eq(dup_obj["parent"], orig_obj["parent"], "gleicher Elternteil")
	check_eq(model.get_property(duplicated, "mass"), 2.0, "mass 2.0 im duplizierten Objekt")

func test_speichern_laden() -> void:
	model.add_object("Node2D")
	model.add_object("Sprite2D", "o1")
	model.add_object("RigidBody2D", "", {"mass": 2.0})

	var d: Dictionary = model.to_dict()
	var loaded: SceneModel = SceneModel.from_dict(JSON.parse_string(JSON.stringify(d)))

	check_eq(loaded.order, model.order, "gleiche Reihenfolge")
	check_eq(loaded.next_id, 4, "next_id ist 4")
	check(typeof(loaded.next_id) == TYPE_INT, "typeof(next_id) ist TYPE_INT")

	check_eq(model.get_property("o3", "mass"), 2.0, "Eigenschaften gleich nach Laden")
