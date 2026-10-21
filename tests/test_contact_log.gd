extends "res://tests/base_test.gd"

var log: ContactLog

func setup() -> void:
	log = ContactLog.new()

func test_reihenfolge() -> void:
	# Test: add(1, "z", "a", Vector2(1, 2), Vector2(0, -1))
	log.add(1, "z", "a", Vector2(1, 2), Vector2(0, -1))

	# contacts[0]["a"] muss "a" sein (sortiert a < b)
	var contact: Dictionary = log.contacts[0]
	check_eq(contact["a"], "a", "a ist sortiert kleiner als b")
	check_eq(contact["b"], "z", "b ist sortiert größer als a")
	# normal wird umgedreht von (0,-1) zu (0,1)
	var normal: Array = contact["normal"]
	check_eq(normal[1], 1.0, "normal ist umgedreht auf (0,1)")
	var point: Array = contact["point"]
	check_eq(point[0], 1.0, "point x ist 1.0")
	check_eq(point[1], 2.0, "point y ist 2.0")

func test_zwischen() -> void:
	# Drei Kontakte hinzufügen
	log.add(1, "a", "b", Vector2.ZERO, Vector2.UP)
	log.add(2, "b", "a", Vector2.ZERO, Vector2.UP)
	log.add(2, "a", "c", Vector2.ZERO, Vector2.UP)

	# between("b", "a").size() muss 2 sein
	var ba_contacts: Array[Dictionary] = log.between("b", "a")
	check_eq(ba_contacts.size(), 2, "between('b', 'a') findet 2 Kontakte")

	# of("a").size() muss 3 sein
	var a_contacts: Array[Dictionary] = log.of("a")
	check_eq(a_contacts.size(), 3, "of('a') findet 3 Kontakte")

	# at_step(2).size() muss 2 sein
	var step2_contacts: Array[Dictionary] = log.at_step(2)
	check_eq(step2_contacts.size(), 2, "at_step(2) findet 2 Kontakte")

func test_staerkster() -> void:
	# Drei Kontakte mit Impuls 1.0, 5.0, 2.0
	log.add(1, "a", "b", Vector2.ZERO, Vector2.UP, 1.0)
	log.add(2, "a", "c", Vector2.ZERO, Vector2.UP, 5.0)
	log.add(3, "b", "c", Vector2.ZERO, Vector2.UP, 2.0)

	# strongest()["impulse"] muss 5.0 sein
	var strongest: Dictionary = log.strongest()
	check_eq(strongest["impulse"], 5.0, "stärkster Kontakt hat impulse 5.0")

	# Neues Protokoll -> strongest().is_empty()
	log = ContactLog.new()
	var empty_result: Dictionary = log.strongest()
	check(empty_result.is_empty(), "leeres Protokoll gibt leeres Dict zurück")

func test_aufraeumen() -> void:
	# Kontakte in den Schritten 1, 2, 3
	log.add(1, "a", "b", Vector2.ZERO, Vector2.UP)
	log.add(2, "a", "c", Vector2.ZERO, Vector2.UP)
	log.add(3, "b", "c", Vector2.ZERO, Vector2.UP)

	# clear_before(3) muss 2 zurückgeben
	var removed: int = log.clear_before(3)
	check_eq(removed, 2, "clear_before(3) entfernt 2 Kontakte")

	# contacts.size() muss 1 sein
	check_eq(log.contacts.size(), 1, "nach clear_before bleibt 1 Kontakt übrig")
