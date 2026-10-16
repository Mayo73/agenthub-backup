extends "res://tests/base_test.gd"

var h: CellHealth

func setup() -> void:
	h = CellHealth.new()


func test_treffer() -> void:
	check(h.damage(30.0), "erster Treffer zählt")
	check_eq(h.hp, 70.0, "hp nach erstem Treffer")
	check(not h.damage(30.0), "Treffer während Unverwundbarkeit zählt nicht")
	check_eq(h.hp, 70.0, "hp bleibt unverändert während Unverwundbarkeit")
	h.tick(0.7)
	check(h.damage(30.0), "Treffer nach Ende der Unverwundbarkeit zählt")
	check_eq(h.hp, 40.0, "hp nach zweitem Treffer")


func test_tod() -> void:
	check(not h.is_dead(), "nicht tot am Anfang")
	h.damage(150.0)
	check_eq(h.hp, 0.0, "hp nach tödlichem Treffer")
	check(h.is_dead(), "Zelle ist tot")
	h.heal(10.0)
	check_eq(h.hp, 0.0, "Heilung bei Toten wirkt nicht")


func test_heilung() -> void:
	h.damage(50.0)
	check_eq(h.hp, 50.0, "hp nach Treffer")
	h.tick(1.0)
	check_eq(h.hp, 50.0, "hp nach tick ohne Heilung (REGEN_DELAY noch nicht erreicht)")
	h.tick(3.0)
	check_eq(h.hp, 59.0, "hp nach Heilung")
	check_eq(h.ratio(), 0.59, "ratio nach Heilung")


func test_zuruecksetzen() -> void:
	h.damage(50.0)
	check_eq(h.hp, 50.0, "hp nach Treffer vor reset")
	h.reset(2.0)
	check_eq(h.hp, 100.0, "hp nach reset voll")
	check_eq(h.invulnerable, 2.0, "invulnerable nach reset")
	check(not h.damage(10.0), "kein Treffer während Unverwundbarkeit nach reset")


func test_eigene_lebenspunkte() -> void:
	check_eq(CellHealth.new(40.0).hp, 40.0, "eigene max_hp werden gesetzt")


func test_gift_entzug() -> void:
	h.damage(10.0)
	h.drain(5.0)
	check_eq(h.hp, 85.0, "Schaden durch drain nach Treffer")
	h.drain(-3.0)
	check_eq(h.hp, 85.0, "negative drain wirkt nicht")
	h.drain(200.0)
	check_eq(h.hp, 0.0, "drain tötet Zelle")
	check(h.is_dead(), "Zelle ist tot nach drain")
