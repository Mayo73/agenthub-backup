extends "res://tests/base_test.gd"

func test_acht_profile() -> void:
	var list: Array[SparProfile] = DemoData.profiles()
	check_eq(list.size(), 8, "genau 8 Profile")

	var ids: Array[String] = DemoData.profile_ids()
	check_eq(ids.size(), 8, "8 IDs in Reihenfolge")

	for i in range(8):
		check_eq(list[i].id, ids[i], "ID %s ist %s" % [i, ids[i]])

	var seen_ids: Dictionary = {}
	for p in list:
		check(not seen_ids.has(p.id), "IDs sind eindeutig: %s" % p.id)
		seen_ids[p.id] = true


func test_pflicht_sportarten() -> void:
	var arts: Array[String] = []
	for p in DemoData.profiles():
		arts.append(p.art)

	check("Jiu-Jitsu" in arts, "Jiu-Jitsu ist vertreten")
	check("MMA" in arts, "MMA ist vertreten")
	check("Boxen" in arts, "Boxen ist vertreten")


func test_erwachsen_und_vollstaendig() -> void:
	for p in DemoData.profiles():
		check(p.age >= 18, "%s ist mindestens 18 Jahre alt" % p.name)
		check(not p.name.is_empty(), "%s hat einen Namen" % p.id)
		check(not p.bio.is_empty(), "%s hat eine Bio" % p.id)
		check(p.bio.length() <= 120, "%s Bio ist ≤ 120 Zeichen" % p.id)
		check(DemoData.ARTS.has(p.art), "%s Sportart in ARTS: %s" % [p.id, p.art])
		check(p.level >= 0 and p.level <= 2, "%s level ist 0–2" % p.id)


func test_frische_kopien() -> void:
	var list1: Array[SparProfile] = DemoData.profiles()
	var name_first: String = list1[0].name

	list1[0].name = "GEÄNDERT"

	var list2: Array[SparProfile] = DemoData.profiles()
	check_eq(list2[0].name, name_first, "zweiter Aufruf unverändert")
