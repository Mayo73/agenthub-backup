extends "res://tests/base_test.gd"

var all: Array[SparProfile]


func setup() -> void:
	all = DemoData.profiles()


func test_ohne_filter() -> void:
	var filter := SparFilter.new()

	# apply gibt alle Profile zurück, gleiche Reihenfolge
	var result := filter.apply(all)
	check_eq(result.size(), 8, "apply ohne Filter ergibt 8 Profile")
	check(not filter.is_active(), "is_active() ist false bei leerem Filter")
	check_eq(filter.describe(), "Alle Testprofile", "describe() gibt 'Alle Testprofile' zurück")


func test_sportart() -> void:
	var filter := SparFilter.new()
	filter.art = "Boxen"

	var result := filter.apply(all)
	var ids: Array[String] = []
	for p in result:
		ids.append(p.id)

	check_eq(ids.size(), 2, "Boxen: 2 Profile")
	check(ids.has("p03"), "enthält p03 (Mira)")
	check(ids.has("p08"), "enthält p08 (Tarek)")
	check_eq(filter.describe(), "Boxen", "describe() gibt 'Boxen' zurück")


func test_erfahrung() -> void:
	var filter := SparFilter.new()
	filter.level = 2

	var result := filter.apply(all)
	var ids: Array[String] = []
	for p in result:
		ids.append(p.id)

	check_eq(ids.size(), 3, "Level 2: 3 Profile")
	check(ids.has("p02"), "enthält p02 (Sam)")
	check(ids.has("p05"), "enthält p05 (Lea)")
	check(ids.has("p08"), "enthält p08 (Tarek)")


func test_beides() -> void:
	var filter := SparFilter.new()
	filter.art = "Jiu-Jitsu"
	filter.level = 2

	var result := filter.apply(all)
	var ids: Array[String] = []
	for p in result:
		ids.append(p.id)

	check_eq(ids.size(), 1, "Jiu-Jitsu + Erfahren: 1 Profil")
	check(ids.has("p05"), "enthält p05 (Lea)")
	check_eq(filter.describe(), "Jiu-Jitsu · Erfahren", "describe() gibt 'Jiu-Jitsu · Erfahren' zurück")


func test_zuruecksetzen() -> void:
	var filter := SparFilter.new()
	filter.art = "MMA"
	filter.level = 1

	check(filter.is_active(), "Filter ist aktiv vor clear()")

	filter.clear()

	check(not filter.is_active(), "is_active() ist false nach clear()")
	check_eq(filter.describe(), "Alle Testprofile", "describe() gibt 'Alle Testprofile' nach clear()")


func test_speichern_laden() -> void:
	var filter := SparFilter.new()
	filter.art = "MMA"
	filter.level = 1

	var d := filter.to_dict()
	check(d.has("art"), "to_dict() enthält 'art'")
	check(d.has("level"), "to_dict() enthält 'level'")
	check(d.get("art", "") == "MMA", "art ist MMA")
	check(typeof(d.get("level", -1)) == TYPE_INT, "typeof(level) ist TYPE_INT")

	var loaded := SparFilter.from_dict(d)
	check(loaded.art == filter.art, "art wurde gespeichert")
	check_eq(loaded.level, filter.level, "level wurde gespeichert")
	check(loaded.is_active(), "geladener Filter ist aktiv")
