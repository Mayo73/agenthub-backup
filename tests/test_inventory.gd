extends "res://tests/base_test.gd"

var inv: Inventory

func setup() -> void:
	inv = Inventory.new()


func test_hinzufuegen() -> void:
	var added := inv.add("muenze", 5)
	check_eq(added, 5, "add(\"muenze\", 5) gibt 5 zurück")
	check_eq(inv.count("muenze"), 5, "count(\"muenze\") ist 5")

	added = inv.add("muenze", 0)
	check_eq(added, 0, "add mit amount=0 gibt 0 zurück")


func test_grenze() -> void:
	inv.set_limit("trank", 3)
	var added := inv.add("trank", 2)
	check_eq(added, 2, "add(\"trank\", 2) gibt 2 zurück")

	added = inv.add("trank", 5)
	check_eq(added, 1, "bei voller Grenze gibt add nur 1 zurück")

	check_eq(inv.count("trank"), 3, "count(\"trank\") ist 3")


func test_entfernen() -> void:
	inv.add("muenze", 5)
	var removed := inv.remove("muenze", 3)
	check(removed, "remove(\"muenze\", 3) gibt true zurück")
	check_eq(inv.count("muenze"), 2, "count nach entfernen ist 2")

	removed = inv.remove("muenze", 5)
	check(not removed, "remove mit zu wenig gibt false zurück")

	removed = inv.remove("muenze", 2)
	check(removed, "remove den Rest gibt true zurück")
	check(inv.is_empty(), "nach vollständigem Entfernen ist is_empty() wahr")


func test_platz() -> void:
	inv.capacity = 2

	var added_a := inv.add("a")
	check_eq(added_a, 1, "add(\"a\") gibt 1 zurück")

	var added_b := inv.add("b")
	check_eq(added_b, 1, "add(\"b\") gibt 1 zurück")

	var added_c := inv.add("c")
	check_eq(added_c, 0, "add(\"c\") bei voller Kapazität gibt 0 zurück")

	added_a = inv.add("a")
	check_eq(added_a, 1, "add(\"a\") erneut gibt 1 zurück")

	var list := inv.items()
	check_eq(list.size(), 2, "items() hat 2 Elemente")
	check(list[0] == "a" and list[1] == "b", "items() ist [\"a\", \"b\"]")


func test_speichern() -> void:
	inv.add("muenze", 7)
	inv.set_limit("trank", 3)

	var d: Dictionary = JSON.parse_string(JSON.stringify(inv.to_dict()))
	check_eq(int(d["capacity"]), 0, "capacity ist 0")
	check_eq(int(d["slots"]["muenze"]), 7, "slots[\"muenze\"] ist 7")
	check_eq(int(d["limits"]["trank"]), 3, "limits[\"trank\"] ist 3")

	var restored := Inventory.from_dict(d)
	check_eq(restored.count("muenze"), 7, "restauriert: count(\"muenze\") ist 7")

	var added := restored.add("trank", 5)
	check_eq(added, 3, "restauriert: add mit Grenze gibt 3 zurück")
