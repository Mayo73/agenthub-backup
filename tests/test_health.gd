extends "res://tests/base_test.gd"

func test_schaden() -> void:
	var h: Health = Health.new(50.0)
	var dmg: float = h.damage(20.0)
	check_eq(dmg, 20.0, "damage gibt 20.0 zurück")
	check_eq(h.hp, 30.0, "hp nach Schaden 30.0")
	check_eq(h.ratio(), 0.6, "ratio() ist 0.6")


func test_nicht_unter_null() -> void:
	var h: Health = Health.new(10.0)
	var dmg: float = h.damage(25.0)
	check_eq(dmg, 10.0, "damage gibt maximal hp zurück")
	check(h.is_dead(), "is_dead() ist true")
	var healed: float = h.heal(5.0)
	check_eq(healed, 0.0, "healing von totem Charakter gibt 0.0 zurück")


func test_heilen_begrenzt() -> void:
	var h: Health = Health.new(100.0)
	h.damage(30.0)
	var healed: float = h.heal(50.0)
	check_eq(healed, 30.0, "heal gibt 30.0 zurück")
	check_eq(h.hp, 100.0, "hp nach Heilen 100.0 (Begrenzung)")


func test_schutzzeit() -> void:
	var h: Health = Health.new(100.0)
	h.invulnerable_time = 0.5
	var dmg1: float = h.damage(10.0)
	check_eq(dmg1, 10.0, "erster Treffer wirkt")
	var dmg2: float = h.damage(10.0)
	check_eq(dmg2, 0.0, "zweiter Treffer während Schutzzeit ergibt 0")
	h.step(0.6)
	var dmg3: float = h.damage(10.0)
	check_eq(dmg3, 10.0, "nach Ablauf der Schutzzeit wirkt Treffer wieder")


func test_speichern() -> void:
	var h: Health = Health.new()
	h.max_hp = 80.0
	h.hp = 35.0
	h.invulnerable_time = 0.25
	var d: Dictionary = h.to_dict()
	var h2: Health = Health.from_dict(d)
	check_eq(h2.max_hp, 80.0, "max_hp aus Dict")
	check_eq(h2.hp, 35.0, "hp aus Dict")
	check_eq(h2.invulnerable_time, 0.25, "invulnerable_time aus Dict")
