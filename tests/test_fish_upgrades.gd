extends "res://tests/base_test.gd"

var build: FishBuild
var progress: FishProgress


func setup() -> void:
	build = FishBuild.new()
	progress = FishProgress.new()


func test_preise() -> void:
	check_eq(FishUpgrades.cost(build, "schwanz"), 10, "Preis für Stufe 0 des Schwanzes")
	build.upgrade("schwanz")
	check_eq(FishUpgrades.cost(build, "schwanz"), 20, "Preis für Stufe 1 des Schwanzes")
	build.upgrade("schwanz")
	check_eq(FishUpgrades.cost(build, "schwanz"), 35, "Preis für Stufe 2 des Schwanzes")
	build.upgrade("schwanz")
	check_eq(FishUpgrades.cost(build, "schwanz"), -1, "Nach höchster Stufe: -1")
	check_eq(FishUpgrades.cost(build, "fluegel"), -1, "Unbekanntes Bauteil: -1")


func test_zu_wenig_dna() -> void:
	progress.dna = 9
	check(not FishUpgrades.can_upgrade(build, progress, "augen"), "Nicht genug DNA für Upgrade")
	check(not FishUpgrades.upgrade(build, progress, "augen"), "Upgrade sollte scheitern")
	check_eq(progress.dna, 9, "DNA sollte unverändert bleiben")
	check_eq(build.level("augen"), 0, "Stufe sollte unverändert bleiben")


func test_verbessern() -> void:
	progress.dna = 35
	check(FishUpgrades.upgrade(build, progress, "kiefer"), "Upgrade sollte gelingen")
	check_eq(progress.dna, 25, "DNA nach erstem Upgrade")
	check_eq(build.level("kiefer"), 1, "Stufe nach erstem Upgrade")
	check(FishUpgrades.upgrade(build, progress, "kiefer"), "Upgrade sollte gelingen")
	check_eq(progress.dna, 5, "DNA nach zweitem Upgrade")
	check_eq(build.level("kiefer"), 2, "Stufe nach zweitem Upgrade")
	check(not FishUpgrades.upgrade(build, progress, "kiefer"), "Drittes Upgrade sollte scheitern (35 > 5)")


func test_hoechste_stufe() -> void:
	build.upgrade("flossen")
	build.upgrade("flossen")
	build.upgrade("flossen")
	progress.dna = 100
	check(not FishUpgrades.upgrade(build, progress, "flossen"), "Upgrade bei höchster Stufe sollte scheitern")
	check_eq(progress.dna, 100, "DNA sollte unverändert bleiben")
