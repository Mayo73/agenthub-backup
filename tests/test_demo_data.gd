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


func test_merkmale_vollstaendig() -> void:
	var profiles: Array[SparProfile] = DemoData.profiles()

	for p in profiles:
		check(p.weight_class >= 0 and p.weight_class <= 2,
			"%s hat gültige weight_class %d" % [p.name, p.weight_class])
		check(p.days.size() > 0,
			"%s hat mindestens einen Trainingstag, days=%s" % [p.name, p.days])


func test_merkmale_alex() -> void:
	var profiles: Array[SparProfile] = DemoData.profiles()
	var alex = profiles[0]

	check_eq(alex.weight_class, 1, "Alex weight_class ist 1")
	check_eq(alex.days, ["Di", "Do", "Sa"], "Alex days sind korrekt")
	check_eq(alex.equipment, ["Mundschutz", "Matte"], "Alex equipment ist korrekt")


func test_merkmale_sam() -> void:
	var profiles: Array[SparProfile] = DemoData.profiles()
	var sam = profiles[1]

	check_eq(sam.weight_class, 2, "Sam weight_class ist 2")
	check_eq(sam.weight_name(), "Schwer (über 84 kg)", "Sam weight_name stimmt")
	check_eq(sam.days, ["Mo", "Mi", "Fr"], "Sam days sind korrekt")


func test_ohne_ausruestung() -> void:
	var profiles: Array[SparProfile] = DemoData.profiles()
	var jonas = profiles[3]

	check(jonas.equipment.is_empty(), "Jonas hat leere equipment-Liste")
