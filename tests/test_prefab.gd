extends "res://tests/base_test.gd"

var prefab: Prefab

func setup() -> void:
	prefab = Prefab.new("kiste", "RigidBody2D", {"mass": 2.0, "color": "braun"})


func test_instanz() -> void:
	var result := prefab.instantiate("k1")
	check_eq(result.get("id"), "k1", "id ist k1")
	check_eq(result.get("type"), "RigidBody2D", "type ist RigidBody2D")
	check_eq(result.get("prefab"), "kiste", "prefab ist kiste")
	var props: Dictionary = result.get("props", {})
	check_eq(props.get("mass"), 2.0, "props.mass ist 2.0")


func test_ueberschreiben() -> void:
	var result := prefab.instantiate("k2", {"mass": 5.0})
	var props: Dictionary = result.get("props", {})
	check_eq(props.get("mass"), 5.0, "props.mass ist 5.0 in Instanz")
	check_eq(props.get("color"), "braun", "props.color ist braun in Instanz")
	check_eq(prefab.props.get("mass"), 2.0, "Vorlage props.mass ist weiter 2.0")


func test_abweichungen() -> void:
	var instance_k3 := prefab.instantiate("k3", {"mass": 5.0})
	var overrides_k3 := prefab.overrides_of(instance_k3)
	check_eq(overrides_k3.get("mass"), 5.0, "overrides_of(k3) hat mass=5.0")

	var instance_k4 := prefab.instantiate("k4")
	var overrides_k4 := prefab.overrides_of(instance_k4)
	check(overrides_k4.is_empty(), "overrides_of(k4) ist leer")


func test_speichern() -> void:
	var saved := prefab.to_dict()
	var loaded := Prefab.from_dict(saved)
	check_eq(loaded.id, "kiste", "loaded id ist kiste")
	check_eq(loaded.type, "RigidBody2D", "loaded type ist RigidBody2D")
	check_eq(loaded.props.get("mass"), 2.0, "loaded props.mass ist 2.0")
