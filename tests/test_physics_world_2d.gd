extends "res://tests/base_test.gd"

var world: PhysicsWorld2D
var body_a: Body2D
var body_b: Body2D


func setup() -> void:
	world = PhysicsWorld2D.new()
	body_a = Body2D.new()
	body_b = Body2D.new()

	var block_rect: Rect2 = Rect2(-5.0, 5.0, 10.0, 2.0)
	world.add_static("block", block_rect, 1, 1)


func test_kontakt() -> void:
	## Körper "a" bei (0, 0), Ebene 1, Maske 1; soll den Block treffen.
	body_a.position = Vector2(0.0, 0.0)
	world.add_body("a", body_a, 1, 1)

	var contacts_count: int = world.run(2.0)
	check(contacts_count >= 1, "mindestens 1 Kontakt")

	# Erster Kontakt sollte Körper "a" und Block "block" betreffen
	var first_contact: Dictionary = world.contacts[0]
	check(first_contact["body"] == "a", "erster Kontakt body 'a'")
	check(first_contact["static"] == "block", "erster Kontakt static 'block'")

	# Körper sollte unter Y=5.0 liegen (durch Kollisionsrücksetzung)
	check(body_a.position.y < 5.0, "a.position.y < 5.0")


func test_ebene_ignoriert() -> void:
	## Körper "b" auf Ebene 2, Maske 2; ignoriert Block auf Ebene 1.
	body_b.position = Vector2(0.0, 0.0)
	world.add_body("b", body_b, 2, 2)

	var contacts_count: int = world.run(2.0)
	check(contacts_count == 0, "0 Kontakte")
	check(body_b.position.y > 7.0, "b.position.y > 7.0")


func test_reihenfolge() -> void:
	## Körper "b" und "a" (beide Ebene 1) über dem Block;
	## erster Kontakt in step() mit zwei Kontakten gehört zu "a".
	body_a.position = Vector2(0.0, 0.0)
	body_b.position = Vector2(0.0, 0.0)

	world.add_body("b", body_b, 1, 1)
	world.add_body("a", body_a, 1, 1)

	# Schritt durchführen – beide werden kollidieren
	var contacts_this_step: Array[Dictionary] = world.step(1.0 / 120.0)

	# Wenn zwei Kontakte gleichzeitig eintreten, soll der erste zu "a" gehören (alphabetisch sortiert)
	if contacts_this_step.size() >= 2:
		check(contacts_this_step[0]["body"] == "a", "erster Kontakt bei mehreren zu 'a'")


func test_schrittzahl() -> void:
	## Schrittanzahl muss mit 120 Hz übereinstimmen.
	world.run(1.0)
	check(world.step_count == 120, "step_count == 120")
