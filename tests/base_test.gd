extends RefCounted
## Basisklasse für Tests. Eine Testdatei heißt res://tests/test_<thema>.gd,
## beginnt mit
##     extends "res://tests/base_test.gd"
## und enthält Methoden, deren Name mit test_ beginnt. Jeder Test bekommt eine
## frische Instanz; optionale Methoden setup() und teardown() laufen davor/danach.

var failures: Array[String] = []


## Optional überschreiben: läuft vor jedem Test.
func setup() -> void:
	pass


## Optional überschreiben: läuft nach jedem Test.
func teardown() -> void:
	pass


func check(condition: bool, message: String = "Bedingung nicht erfüllt") -> void:
	if not condition:
		failures.append(message)


func check_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if _equal(actual, expected):
		return
	var text := "erwartet %s, bekommen %s" % [str(expected), str(actual)]
	failures.append(text if message.is_empty() else "%s: %s" % [message, text])


func _equal(a: Variant, b: Variant) -> bool:
	var numeric := [TYPE_INT, TYPE_FLOAT]
	if typeof(a) in numeric and typeof(b) in numeric:
		return is_equal_approx(float(a), float(b))
	return typeof(a) == typeof(b) and a == b
