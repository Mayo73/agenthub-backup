extends "res://tests/base_test.gd"

const SAVE := "user://test_abnahme_fisch.json"


## Lädt die Fischszene und hängt sie an die Wurzel (wie in tests/test_fish_main.gd).
func load_fish() -> FishMain:
	var f: FishMain = load("res://scenes/fish.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(f)
	return f


func teardown() -> void:
	FishStart.clear()
	if FileAccess.file_exists(SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))


func test_uebergang_traegt_teile() -> void:
	var cell := CellBuild.new()
	cell.add_part("geissel", Vector2(-1, 0))
	cell.add_part("kiefer", Vector2(1, 0))
	cell.add_part("stachel", Vector2(0, 1))
	FishStart.pending_build = FishStart.from_cell(cell, CellLook.new(), Diet.FLEISCHFRESSER)
	var f := load_fish()

	check(f.player.build.level("schwanz") == 1, "schwanz level ist 1")
	check(f.player.build.level("kiefer") == 1, "kiefer level ist 1")
	check(f.player.build.level("stacheln") == 1, "stacheln level ist 1")
	check(f.player.build.diet == Diet.FLEISCHFRESSER, "diet ist FLEISCHFRESSER")
	check(f.player.model.jaw != null, "jaw != null")
	check(f.player.model.spikes.size() == 2, "spikes.size() ist 2")

	f.free()


func test_jede_verbesserung_sichtbar() -> void:
	var f := load_fish()
	f.progress.dna = 200

	for slot in FishBuild.SLOTS:
		var vorher := FishModel.shape(f.player.build)
		f.evolve.open(f.player.build, f.progress)
		f.evolve.try_upgrade(slot)
		var nachher := FishModel.shape(f.player.build)
		check(nachher != vorher, "%s sichtbar" % slot)

	f.free()


func test_verbesserungen_spuerbar() -> void:
	var f := load_fish()
	f.progress.dna = 200
	var tempo: float = f.player.motion.max_speed
	var wende: float = f.player.motion.turn_rate
	var nebel: float = f.water.environment.fog_density

	f.evolve.open(f.player.build, f.progress)
	f.evolve.try_upgrade("schwanz")
	f.evolve.try_upgrade("flossen")
	f.evolve.try_upgrade("augen")

	check(f.player.motion.max_speed > tempo, "max_speed erhöht nach Schwanz-Upgrade")
	check(f.player.motion.turn_rate > wende, "turn_rate erhöht nach Flossen-Upgrade")
	check(f.water.environment.fog_density < nebel, "fog_density verringert nach Augen-Upgrade")

	f.free()


func test_wachsen() -> void:
	var f := load_fish()
	f.eat_value(FishProgress.GROWTH_NEEDED[0])

	check(f.progress.stage == 1, "progress.stage ist 1 nach Wachsen")
	check(f.player.size == FishProgress.SIZES[1], "player.size ist SIZES[1]")

	f.free()


func test_spielstand_und_fortsetzen() -> void:
	SaveGame.write_file(SAVE, {"version": 1})
	var f := load_fish()
	f.save_path = SAVE
	f.progress.dna = 33
	f.save_now()
	f.free()

	var d := SaveGame.read_file(SAVE)
	FishStart.pending_fish = d["fish"]
	var g := load_fish()

	check(g.progress.dna == 33, "progress.dna ist 33 nach Fortsetzen")

	g.free()
