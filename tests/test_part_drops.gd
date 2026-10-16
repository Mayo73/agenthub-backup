extends "res://tests/base_test.gd"

func test_jede_art_hat_ein_teil() -> void:
	for species_id in SpeciesCatalog.ids():
		check(PartDrops.DROPS.has(species_id), "Art '%s' hat keinen Eintrag in PartDrops.DROPS" % species_id)
		var part: String = PartDrops.DROPS[species_id]
		check(PartCatalog.exists(part), "Teil '%s' für Art '%s' ist nicht in PartCatalog" % [part, species_id])


func test_gesperrtes_teil() -> void:
	var result: String = PartDrops.drop_for("zitterzelle", PartUnlocks.new())
	check_eq(result, "elektro", "ungesperrtes Teil 'elektro' sollte zurückgegeben werden")


func test_schon_frei() -> void:
	var u: PartUnlocks = PartUnlocks.new()
	u.unlock("stachel")
	var result: String = PartDrops.drop_for("stachelkugel", u)
	check_eq(result, "", "bereits freigeschaltetes Teil sollte leeren String zurückgeben")


func test_unbekannt() -> void:
	var result: String = PartDrops.drop_for("gibtsnicht", PartUnlocks.new())
	check_eq(result, "", "unbekannte Art sollte leeren String zurückgeben")
