extends "res://tests/base_test.gd"

var templates: ProjectTemplates


func setup() -> void:
	templates = ProjectTemplates.new()


func teardown() -> void:
	pass


func test_namen() -> void:
	var n: Array[String] = templates.names()
	check(n.size() == 2, "names() hat %d Einträge, erwartet 2" % n.size())
	check(n[0] == "leer_2d", "names()[0] ist '%s', erwartet 'leer_2d'" % n[0])
	check(n[1] == "leer_3d", "names()[1] ist '%s', erwartet 'leer_3d'" % n[1])

	var t2d: String = templates.title("leer_2d")
	check(t2d == "Leeres 2D-Projekt", "title('leer_2d') = '%s', erwartet 'Leeres 2D-Projekt'" % t2d)

	var t3d: String = templates.title("leer_3d")
	check(t3d == "Leeres 3D-Projekt", "title('leer_3d') = '%s', erwartet 'Leeres 3D-Projekt'" % t3d)

	var tx: String = templates.title("x")
	check(tx == "", "title('x') = '%s', erwartet ''" % tx)


func test_2d() -> void:
	var model: SceneModel = templates.create("leer_2d")
	check(model != null, "create('leer_2d') ist null")
	check(model.order.size() == 3, "order.size() = %d, erwartet 3" % model.order.size())

	var o1_type: String = model.get_object("o1").get("type", "")
	check(o1_type == "Node2D", "get_object('o1')['type'] = '%s', erwartet 'Node2D'" % o1_type)

	var c: Array[String] = model.children("o1")
	var c_str: String = str(c)
	check(c.size() == 2, "children('o1') hat %d Einträge, erwartet 2: %s" % [c.size(), c_str])
	check(c[0] == "o2", "children('o1')[0] = '%s', erwartet 'o2'" % c[0])
	check(c[1] == "o3", "children('o1')[1] = '%s', erwartet 'o3'" % c[1])

	var name_o2: String = model.get_property("o2", "name", "")
	check(name_o2 == "Kamera", "get_property('o2', 'name') = '%s', erwartet 'Kamera'" % name_o2)

	var pos_o3: Variant = model.get_property("o3", "position")
	check(pos_o3 is Vector2, "get_property('o3', 'position') ist %s, erwartet Vector2" % typeof(pos_o3))
	check(pos_o3.x == 0 and pos_o3.y == 300, "get_property('o3', 'position') = %s, erwartet Vector2(0, 300)" % pos_o3)


func test_3d() -> void:
	var model: SceneModel = templates.create("leer_3d")
	check(model != null, "create('leer_3d') ist null")
	check(model.order.size() == 4, "order.size() = %d, erwartet 4" % model.order.size())

	var t2: String = model.get_object("o2").get("type", "")
	check(t2 == "Camera3D", "get_object('o2')['type'] = '%s', erwartet 'Camera3D'" % t2)

	var t3: String = model.get_object("o3").get("type", "")
	check(t3 == "DirectionalLight3D", "get_object('o3')['type'] = '%s', erwartet 'DirectionalLight3D'" % t3)

	var t4: String = model.get_object("o4").get("type", "")
	check(t4 == "StaticBody3D", "get_object('o4')['type'] = '%s', erwartet 'StaticBody3D'" % t4)

	var children_o1: Array[String] = model.children("o1")
	check(children_o1.size() == 3, "children('o1').size() = %d, erwartet 3" % children_o1.size())


func test_unbekannt() -> void:
	var res_null: SceneModel = templates.create("gibts_nicht")
	check(res_null == null, "create('gibts_nicht') ist %s, erwartet null" % res_null)

	var desc: Dictionary = templates.describe("gibts_nicht")
	check(desc.is_empty(), "describe('gibts_nicht') = %s, erwartet {}" % str(desc))


func test_beschreibung() -> void:
	var d: Dictionary = templates.describe("leer_2d")
	check(d.get("name", "") == "leer_2d", "describe('leer_2d')['name'] = '%s', erwartet 'leer_2d'" % d.get("name", ""))
	check(d.get("title", "") == "Leeres 2D-Projekt", "describe('leer_2d')['title'] = '%s', erwartet 'Leeres 2D-Projekt'" % d.get("title", ""))
	var objects: int = d.get("objects", -1)
	check(objects == 3, "describe('leer_2d')['objects'] = %d, erwartet 3" % objects)


func test_echte_klassen() -> void:
	for tmpl in ["leer_2d", "leer_3d"]:
		var model: SceneModel = templates.create(tmpl)
		check(model != null, "create('%s') ist null" % tmpl)

		for oid in model.order:
			var obj: Dictionary = model.get_object(oid)
			var type_s: String = obj.get("type", "")
			check(ClassDB.class_exists(type_s), "%s: ClassDB.class_exists('%s') ist falsch" % [tmpl, type_s])

			var plist: Array = ClassDB.class_get_property_list(type_s)
			for key in obj.get("props", {}):
				var found: bool = false
				for pl: Dictionary in plist:
					var pname: String = pl.get("name", "")
					if key == pname:
						found = true
						break
				check(found, "%s/%s: Schlüssel '%s' nicht in ClassDB.property-list für '%s' gefunden" % [tmpl, oid, key, type_s])


func test_unabhaengig() -> void:
	var m1: SceneModel = templates.create("leer_2d")
	var m2: SceneModel = templates.create("leer_2d")

	check(m1.get_property("o1", "name", "") == "Welt", "m1 o1 name ist '%s', erwartet 'Welt' (bereits geändert)" % m1.get_property("o1", "name", ""))
	check(m2.get_property("o1", "name", "") == "Welt", "m2 o1 name ist '%s', erwartet 'Welt'" % m2.get_property("o1", "name", ""))

	m1.set_property("o1", "name", "X")

	check(m1.get_property("o1", "name", "") == "X", "m1 o1 name nach set_property = '%s', erwartet 'X'" % m1.get_property("o1", "name", ""))
	check(m2.get_property("o1", "name", "") == "Welt", "m2 o1 name ist '%s', sollte unverändert 'Welt' sein" % m2.get_property("o1", "name", ""))
