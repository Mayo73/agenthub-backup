extends "res://tests/base_test.gd"

var fish: Node3D


func setup() -> void:
	fish = load("res://scenes/fish.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(fish)


func teardown() -> void:
	FishStart.clear()
	fish.free()


## Vor jedem Test alle KI-Fische entfernen.
func _clear_ai_fishes() -> void:
	for f in fish.fishes.duplicate():
		fish.remove_fish(f)


func test_knoten() -> void:
	check(fish is FishMain, "Wurzel ist FishMain")
	check(fish.get_node("World") is Node3D, "Knoten World")
	check(fish.get_node("Camera") is Camera3D, "Knoten Camera")
	check(fish.get_node("Sun") is DirectionalLight3D, "Knoten Sun")
	check(fish.get_node("Water") is WorldEnvironment, "Knoten Water")


func test_wasser() -> void:
	check(fish.water.environment.fog_enabled, "Nebel unter Wasser")
	check_eq(fish.floor_mesh.position.y, -FishWorld.DEPTH, "Boden in der Tiefe")
	check_eq(fish.surface_mesh.position.y, 0.0, "Oberfläche bei y = 0")
	check(fish.floor_mesh.get_parent() == fish.world, "Boden liegt in World")


func test_spieler() -> void:
	check(fish.player is FishPlayer, "fish.player ist FishPlayer")
	check(fish.player.get_parent() == fish.world, "fish.player liegt in world")
	check(fish.reef.get_parent() == fish.world, "fish.reef liegt in world")
	check(fish.get_node("Hud") is FishHud, "fish.Hud ist FishHud")
	check(fish.get_node("Snow") is MarineSnow, "fish.Snow ist MarineSnow")
	check(fish.intro.visible, "intro.visible ist wahr")


func test_uebergabe() -> void:
	var b := FishBuild.new()
	b.upgrade("schwanz")
	FishStart.pending_build = b
	FishStart.pending_dna = 33
	var f2: Node3D = load("res://scenes/fish.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(f2)
	check_eq(f2.player.build.level("schwanz"), 1, "build level ist 1")
	check_eq(f2.progress.dna, 33, "dna ist 33")
	check_eq(f2.hud.dna_label.text, "DNA: 33", "dna_label.text ist DNA: 33")
	check(FishStart.pending_build == null, "pending_build ist null")
	f2.free()


func test_ohne_uebergabe() -> void:
	check_eq(fish.player.build.total_levels(), 0, "build hat keine Levels")
	check_eq(fish.progress.dna, 0, "dna ist 0")


func test_schwimmen() -> void:
	fish._physics_process(0.1)
	check_eq(fish.player.motion.position, FishWorld.START, "position bleibt START")
	check_eq(fish.hud.depth_label.text, "Tiefe: 20 m", "depth_label ist Tiefe: 20 m")
	fish.player.drive(Vector3(1, 0, 0), 0.1)
	check(fish.player.position.z < 0.0, "position.z < 0.0")


func test_kamera() -> void:
	fish._process(10.0)
	check(fish.camera.position.is_equal_approx(ChaseCamera.target_position(fish.player.motion.position, fish.player.motion.yaw, fish.player.size)), "camera.position ist target_position")
	check_eq(fish.snow.position, fish.camera.position, "snow.position ist camera.position")


func test_nahrung_da() -> void:
	check_eq(fish.food.items.size(), 60, "food.items.size() ist 60")
	check(fish.get_node("World/Food") is FishFoodView, "fish.get_node('World/Food') is FishFoodView")


func test_fressen() -> void:
	fish.food.items.clear()
	fish.food.add_item(Diet.PFLANZE, FishWorld.START + Vector3(0, 0, -1))
	fish.feed_player()
	check_eq(fish.progress.dna, 2, "fish.progress.dna ist 2")
	check_eq(fish.food.items.size(), 0, "fish.food.items.size() ist 0")
	check_eq(fish.hud.dna_label.text, "DNA: 2", "fish.hud.dna_label.text ist 'DNA: 2'")


func test_falsche_nahrung() -> void:
	fish.food.items.clear()
	fish.food.add_item(Diet.FLEISCH, FishWorld.START + Vector3(0, 0, -1))
	fish.feed_player()
	check_eq(fish.progress.dna, 0, "fish.progress.dna ist 0")
	check_eq(fish.food.items.size(), 1, "fish.food.items.size() ist 1")


func test_wachsen() -> void:
	fish.food.items.clear()
	fish.progress.growth = 19
	fish.food.add_item(Diet.PFLANZE, FishWorld.START + Vector3(0, 0, -1))
	fish.feed_player()
	check_eq(fish.progress.stage, 1, "fish.progress.stage ist 1")
	check_eq(fish.player.size, 1.4, "fish.player.size ist 1.4")
	check_eq(fish.player.model.scale, Vector3(1.4, 1.4, 1.4), "fish.player.model.scale ist Vector3(1.4, 1.4, 1.4)")
	check(fish.hud.message_label.visible, "fish.hud.message_label.visible wahr")


func test_nachstreuen() -> void:
	fish.food.items.clear()
	fish.refill_food()
	check_eq(fish.food.items.size(), 20, "fish.food.items.size() ist 20")


func test_entwicklung_knoten() -> void:
	check(fish.get_node("Evolve") is EvolveMenu, "fish.get_node('Evolve') is EvolveMenu")
	check(not fish.evolve.visible, "fish.evolve.visible ist falsch")
	check(InputMap.has_action("entwickeln"), "InputMap hat Aktion 'entwickeln'")


func test_umschalten() -> void:
	fish.toggle_evolve()
	check(fish.evolve.visible, "fish.evolve.visible ist wahr nach erstem Aufruf")
	fish.toggle_evolve()
	check(not fish.evolve.visible, "fish.evolve.visible ist falsch nach zweitem Aufruf")


func test_verbessern_wirkt() -> void:
	fish.progress.dna = 20
	fish.toggle_evolve()
	fish.evolve.try_upgrade("schwanz")
	check_eq(fish.player.build.level("schwanz"), 1, "build level('schwanz') ist 1")
	check_eq(fish.player.motion.max_speed, 10.0, "player.motion.max_speed ist 10.0")
	check_eq(fish.progress.dna, 10, "progress.dna ist 10 nach Upgrade")
	check_eq(fish.hud.dna_label.text, "DNA: 10", "hud.dna_label.text ist 'DNA: 10'")


func test_kein_schwimmen_im_menue() -> void:
	fish.toggle_evolve()
	var vorher: Vector3 = fish.player.motion.position
	fish.player.motion.velocity = Vector3(0, 0, -5)
	fish._physics_process(0.5)
	check_eq(fish.player.motion.position, vorher, "position bleibt unverändert während Menü offen")


func test_nebel_formel() -> void:
	check_eq(FishMain.fog_density_for(25.0), 0.025, "fog_density_for(25.0) ist 0.025")
	check_eq(FishMain.fog_density_for(50.0), 0.0125, "fog_density_for(50.0) ist 0.0125")
	check_eq(FishMain.fog_density_for(0.0), 0.625, "fog_density_for(0.0) ist 0.625")


func test_nebel_anfang() -> void:
	check_eq(fish.water.environment.fog_density, 0.03125, "fog_density am Anfang ist 0.03125")


func test_augen_lichten_nebel() -> void:
	fish.progress.dna = 50
	fish.toggle_evolve()
	fish.evolve.try_upgrade("augen")
	check(fish.water.environment.fog_density < 0.025, "Nebel dünner nach Augen-Upgrade")


func test_fische_verteilt() -> void:
	check_eq(fish.fishes.size(), 22, "fishes.size() ist 22")
	for f in fish.fishes:
		check(f is AiFish, "jeder Eintrag ist AiFish")
		check(f.get_parent() == fish.world, "AiFish hat world als Elternknoten")


func test_fische_schwimmen() -> void:
	var f: AiFish = fish.fishes[0]
	var vorher: Vector3 = f.motion.position
	for i in 10:
		fish.think_fish(0.1)
	check(f.motion.position != vorher, "f.motion.position hat sich geändert")


func test_fisch_hinzufuegen_entfernen() -> void:
	var vorher: int = fish.fishes.size()
	var f: AiFish = fish.add_fish("grasfisch", Vector3(3, -20, 0))
	check_eq(fish.fishes.size(), vorher + 1, "fishes.size() ist 23")
	fish.remove_fish(f)
	check_eq(fish.fishes.size(), vorher, "fishes.size() ist 22 nach Entfernen")
	check(not fish.fishes.has(f), "fish.fishes.has(f) falsch")


func test_pflanzenfresser_beisst_nicht() -> void:
	for f in fish.fishes.duplicate():
		fish.remove_fish(f)
	fish.player.build.diet = Diet.PFLANZENFRESSER
	var f: AiFish = fish.add_fish("silberling", fish.player.mouth_point())
	var hp_vorher: float = f.health.hp
	fish.player_bites()
	check_eq(f.health.hp, hp_vorher, "f.health.hp unverändert bei Pflanzenfresser")


func test_biss_verletzt() -> void:
	for f in fish.fishes.duplicate():
		fish.remove_fish(f)
	fish.player.build.diet = Diet.FLEISCHFRESSER
	var f: AiFish = fish.add_fish("zackenbarsch", fish.player.mouth_point())
	fish.player_bites()
	check_eq(f.health.hp, 90.0 - 10.0, "f.health.hp ist 80.0 nach Biss")
	check(fish.fishes.has(f), "fish.fishes.has(f) wahr")


func test_besiegt_und_gefressen() -> void:
	for f in fish.fishes.duplicate():
		fish.remove_fish(f)
	fish.player.build.diet = Diet.FLEISCHFRESSER
	var dna: int = fish.progress.dna
	var f: AiFish = fish.add_fish("silberling", fish.player.mouth_point())
	f.health.hp = 5.0
	fish.player_bites()
	check(not fish.fishes.has(f), "fish.fishes.has(f) falsch")
	check_eq(fish.progress.dna, dna + 4, "fish.progress.dna ist dna + 4")


func test_zu_weit() -> void:
	for f in fish.fishes.duplicate():
		fish.remove_fish(f)
	fish.player.build.diet = Diet.FLEISCHFRESSER
	var f: AiFish = fish.add_fish("silberling", fish.player.mouth_point() + Vector3(5, 0, 0))
	fish.player_bites()
	check_eq(f.health.hp, f.health.max_hp, "f.health.hp unverändert wenn zu weit entfernt")


func test_raubfisch_beisst() -> void:
	_clear_ai_fishes()
	var f: AiFish = fish.add_fish("zackenbarsch", fish.player.motion.position + Vector3(0, 0, 1.5))
	fish.predators_bite()
	check_eq(fish.player_health.hp, 85.0, "player_health.hp ist 85.0 nach Biss")


func test_stacheln_wehren_ab() -> void:
	_clear_ai_fishes()
	fish.player.build.levels["stacheln"] = 2
	var f: AiFish = fish.add_fish("zackenbarsch", fish.player.motion.position + Vector3(0, 0, 1.5))
	fish.predators_bite()
	check(is_equal_approx(fish.player_health.hp, 100.0 - 15.0 * 0.7), "player_health.hp durch Stacheln reduziert")
	check_eq(f.health.hp, 90.0 - 12.0, "f.health.hp durch Stacheln reflektiert")


func test_beute_beisst_nicht() -> void:
	_clear_ai_fishes()
	fish.add_fish("grasfisch", fish.player.motion.position + Vector3(0, 0, 1.0))
	fish.predators_bite()
	check_eq(fish.player_health.hp, 100.0, "player_health.hp unverändert bei Beute")


func test_anzeige() -> void:
	_clear_ai_fishes()
	fish.player_health.hp = 50.0
	fish._physics_process(0.016)
	check_eq(fish.hud.health_label.text, "Gesundheit: 50 %", "health_label.text nach update")


## Test: check_death() wird aufgerufen und deaths bleibt 0, wenn Fisch lebt.
func test_lebt() -> void:
	_clear_ai_fishes()
	fish.check_death()
	check_eq(fish.deaths, 0, "deaths ist 0 nach check_death() bei lebendem Fisch")


## Test: Nach Tod taucht Fisch neu auf; nahe Raubfische verschwinden, Beute bleibt.
func test_tod() -> void:
	_clear_ai_fishes()
	fish.progress.dna = 30
	fish.player.motion.position = FishWorld.START + Vector3(40, 0, 0)
	var nah: AiFish = fish.add_fish("zackenbarsch", FishWorld.START + Vector3(5, 0, 0))
	var fern: AiFish = fish.add_fish("zackenbarsch", FishWorld.START + Vector3(60, 0, 0))
	var beute: AiFish = fish.add_fish("silberling", FishWorld.START + Vector3(3, 0, 0))
	fish.player_health.hp = 0.0
	fish.check_death()
	check_eq(fish.deaths, 1, "deaths ist 1 nach Tod")
	check(fish.player.motion.position == FishWorld.START, "position ist START nach Tod")
	check(not fish.fishes.has(nah), "nahe Raubfische verschwunden")
	check(fish.fishes.has(fern), "ferne Raubfische bleiben")
	check(fish.fishes.has(beute), "Beute bleibt")
	check_eq(fish.progress.dna, 30, "dna bleibt 30")
	check_eq(fish.player_health.hp, 100.0, "player_health.hp ist 100.0 nach reset")
	check(fish.player_health.invulnerable > 0.0, "invulnerable > 0.0")


## Test: PauseMenu wird angelegt und paused ist falsch.
func test_pausemenue_angelegt() -> void:
	check(fish.get_node("PauseMenu") is PauseMenu, "fish.get_node('PauseMenu') ist PauseMenu")
	check(not fish.paused, "fish.paused ist falsch")


## Test: toggle_pause() setzt paused wahr und macht Welt still.
func test_pause() -> void:
	fish.toggle_pause()
	check(fish.paused, "fish.paused ist wahr nach erstem Aufruf")
	check(fish.pause_menu.visible, "fish.pause_menu.visible ist wahr")
	check(not fish.is_physics_processing(), "is_physics_processing() ist falsch")
	check(fish.world.process_mode == Node.PROCESS_MODE_DISABLED, "world.process_mode ist DISABLED")
	fish.toggle_pause()
	check(not fish.paused, "fish.paused ist falsch nach zweitem Aufruf")
	check(fish.is_physics_processing(), "is_physics_processing() ist wahr")


## Test: 'Weiter'-Knopf setzt Pause auf falsch.
func test_weiter_knopf() -> void:
	fish.toggle_pause()
	check(fish.paused, "fish.paused ist wahr")
	fish.pause_menu.resume.emit()
	check(not fish.paused, "fish.paused ist falsch nach resume.emit()")


## Test: toggle_pause() wirkt nicht, wenn Entwicklungsmenü offen ist.
func test_nicht_im_entwicklungsmenue() -> void:
	fish.toggle_evolve()
	fish.toggle_pause()
	check(not fish.paused, "fish.paused bleibt falsch während evolve.visible wahr")


## Test: MAIN_SCENE-Datei existiert.
func test_hauptszene_vorhanden() -> void:
	check(ResourceLoader.exists(fish.MAIN_SCENE), "MAIN_SCENE existiert")


## Test: save_now() gibt false zurück ohne Pfad.
func test_ohne_pfad() -> void:
	fish.save_path = ""
	check(not fish.save_now(), "save_now() gibt false ohne Pfad")


## Test: save_now() speichert FishSave.KEY und behält dna=12 bei.
func test_speichern() -> void:
	var test_path := "user://test_save.godot"
	SaveGame.write_file(test_path, {"version": 1, "dna": 5})
	fish.save_path = test_path
	fish.progress.dna = 12
	check(fish.save_now(), "save_now() gibt true bei vorhandenem Pfad")
	var data := SaveGame.read_file(test_path)
	check(FishSave.KEY in data, "FishSave.KEY ist in der Datei")
	var fish_data = data[FishSave.KEY]
	check(fish_data["dna"] == 12, "dna=12 wurde gespeichert")
	check_eq(data["dna"], 5, "DNA der Zellenphase bleibt erhalten")
	_remove_save(test_path)


## Test: pending_save_path wird korrekt von main.gd übertragen.
func test_pfad_uebergabe() -> void:
	var test_path := "user://test_save_transfer.godot"
	SaveGame.write_file(test_path, {})
	FishStart.pending_save_path = test_path
	var f2: Node3D = load("res://scenes/fish.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(f2)
	check_eq(f2.save_path, test_path, "save_path wurde übertragen")
	check_eq(FishStart.pending_save_path, "", "pending_save_path ist nach dem Laden leer")
	f2.free()
	_remove_save(test_path)


## Test: save_now() speichert verbesserte Levels korrekt.
func test_speichern_nach_verbessern() -> void:
	var test_path := "user://test_save_upgrade.godot"
	SaveGame.write_file(test_path, {})
	fish.save_path = test_path
	fish.progress.dna = 20
	fish.toggle_evolve()
	fish.evolve.try_upgrade("schwanz")
	check(fish.save_now(), "save_now() gibt true")
	var data := SaveGame.read_file(test_path)
	var fish_data = data[FishSave.KEY]
	check(fish_data["build"]["levels"]["schwanz"] == 1, "Level schwanz=1 gespeichert")
	_remove_save(test_path)


## Löscht eine Test-Spielstanddatei, falls sie existiert.
func _remove_save(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


## Test: Fortsetzen übernimmt gespeicherten Fischstand.
func test_fortsetzen_uebernimmt_stand() -> void:
	var b := FishBuild.new()
	b.upgrade("schwanz")
	b.upgrade("schwanz")
	var p := FishProgress.new()
	p.dna = 17
	p.stage = 2
	p.growth = 5
	FishStart.pending_fish = FishSave.to_dict(b, p)
	var f2: Node3D = load("res://scenes/fish.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(f2)
	check_eq(f2.progress.dna, 17, "progress.dna ist 17")
	check_eq(f2.progress.stage, 2, "progress.stage ist 2")
	check_eq(f2.progress.growth, 5, "progress.growth ist 5")
	check_eq(f2.player.build.level("schwanz"), 2, "player.build.level('schwanz') ist 2")
	check_eq(f2.player.size, FishProgress.SIZES[2], "player.size ist SIZES[2]")
	check_eq(f2.player.motion.max_speed, 12.0, "player.motion.max_speed ist 12.0")
	check(FishStart.pending_fish.is_empty(), "FishStart.pending_fish ist leer nach Laden")
	f2.free()


## Test: Ohne Fischstand startet Fisch frisch.
func test_ohne_fischstand() -> void:
	FishStart.clear()
	var f2: Node3D = load("res://scenes/fish.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(f2)
	check_eq(f2.progress.stage, 0, "progress.stage ist 0")
	check_eq(f2.player.size, 1.0, "player.size ist 1.0")
	f2.free()


## Test: Audio-Knoten vorhanden und enthält Klänge aus FishSounds.
func test_audio_knoten() -> void:
	_clear_ai_fishes()
	check(fish.get_node("Audio") is GameAudio, "fish.get_node('Audio') is GameAudio")
	check(fish.audio.streams.has("biss"), "fish.audio.streams.has('biss')")
	check(fish.audio.streams.has("fressen_pflanze"), "fish.audio.streams.has('fressen_pflanze')")


## Test: Klang 'verbessern' wird abgespielt bei Upgrade.
func test_klang_verbessern() -> void:
	_clear_ai_fishes()
	fish.progress.dna = 20
	fish.toggle_evolve()
	fish.evolve.try_upgrade("schwanz")
	check_eq(fish.audio.last_played, "verbessern", "fish.audio.last_played ist 'verbessern'")


## Test: Klang 'wachsen' wird abgespielt wenn Fisch wächst.
func test_klang_wachsen() -> void:
	_clear_ai_fishes()
	fish.eat_value(FishProgress.GROWTH_NEEDED[0])
	check_eq(fish.audio.last_played, "wachsen", "fish.audio.last_played ist 'wachsen'")


## Test: Klang 'tod' wird abgespielt wenn Fisch stirbt.
func test_klang_tod() -> void:
	_clear_ai_fishes()
	fish.player_health.hp = 0.0
	fish.check_death()
	check_eq(fish.audio.last_played, "tod", "fish.audio.last_played ist 'tod'")


## Test: Lichtstrahlen-Knoten existiert und ist vom Typ LightRays.
func test_lichtstrahlen_knoten() -> void:
	check(fish.get_node("World/Rays") is LightRays, "fish.get_node('World/Rays') is LightRays")


## Test: Lichtstrahlen folgen der Kamera (Position wird übernommen).
func test_lichtstrahlen_folgen() -> void:
	fish.camera.position = Vector3(12.0, -10.0, 4.0)
	fish.rays.update(fish.camera.position, 0.1)
	check_eq(fish.rays.position.x, 12.0, "fish.rays.position.x ist 12.0")
	check_eq(fish.rays.position.z, 4.0, "fish.rays.position.z ist 4.0")


## Test: Lichtstrahlen werden im _process()-Schritt aktualisiert.
func test_lichtstrahlen_in_process() -> void:
	fish._process(0.1)
	check_eq(fish.rays.position.x, fish.camera.position.x, "fish.rays.position.x entspricht fish.camera.position.x")


## Test: Der Hinweis ist am Anfang unsichtbar (dna=0).
func test_hinweis_anfang() -> void:
	fish.progress.dna = 0
	fish.update_upgrade_hint()
	check(not fish.hud.upgrade_label.visible, "upgrade_label.visible ist falsch bei dna=0")


## Test: Der Hinweis wird angezeigt, wenn DNA für Verbesserung reicht.
func test_hinweis_genug_dna() -> void:
	fish.progress.dna = 10
	fish.feed_player()
	check(fish.hud.upgrade_label.visible, "upgrade_label.visible ist wahr bei dna=10")


## Test: Nach einem Upgrade verschwindet der Hinweis.
func test_hinweis_nach_kauf() -> void:
	fish.progress.dna = 10
	fish.update_upgrade_hint()
	fish.toggle_evolve()
	fish.evolve.try_upgrade("augen")
	check_eq(fish.progress.dna, 0, "progress.dna ist 0 nach Upgrade")
	check(not fish.hud.upgrade_label.visible, "upgrade_label.visible ist falsch nach Upgrade")


## Test: Tiefenlicht setzt Farben für Wasseroberfläche.
func test_tiefenlicht() -> void:
	fish.apply_depth_light(0.0)
	check(fish.water.environment.background_color.r == FishWorld.WATER_COLOR.r && fish.water.environment.background_color.g == FishWorld.WATER_COLOR.g && fish.water.environment.background_color.b == FishWorld.WATER_COLOR.b, "background_color bei Oberfläche ist WATER_COLOR")

	fish.apply_depth_light(FishWorld.DEPTH)
	check(is_equal_approx(fish.water.environment.background_color.r, 0.01), "background_color am Boden r = 0.01")
	check(is_equal_approx(fish.water.environment.background_color.g, 0.06), "background_color am Boden g = 0.06")
	check(is_equal_approx(fish.water.environment.background_color.b, 0.13), "background_color am Boden b = 0.13")
	check(is_equal_approx(fish.water.environment.fog_light_color.r, 0.01), "fog_light_color am Boden r = 0.01")
	check(is_equal_approx(fish.water.environment.fog_light_color.g, 0.06), "fog_light_color am Boden g = 0.06")
	check(is_equal_approx(fish.water.environment.fog_light_color.b, 0.13), "fog_light_color am Boden b = 0.13")
	check_eq(fish.water.environment.ambient_light_energy, 0.35, "ambient_light_energy am Boden ist 0.35")


## Test: Tiefenlicht ändert nicht die Nebeldichte.
func test_tiefenlicht_nebel_bleibt() -> void:
	var dichte: float = fish.water.environment.fog_density
	fish.apply_depth_light(40.0)
	check_eq(fish.water.environment.fog_density, dichte, "fog_density bleibt unverändert nach apply_depth_light")


## Test: _process ruft apply_depth_light mit der richtigen Tiefe.
func test_tiefenlicht_in_process() -> void:
	fish._process(0.1)
	check_eq(fish.water.environment.ambient_light_energy, FishWorld.ambient_energy_at(FishWorld.depth_of(fish.camera.position)), "ambient_light_energy im _process ist ambient_energy_at(depth_of(camera.position))")


func test_warnung_nah() -> void:
	_clear_ai_fishes()
	fish.add_fish("zackenbarsch", fish.player.motion.position + Vector3(8, 0, 0))
	fish.update_warning()
	check(fish.hud.warning_label.visible, "warning_label.visible ist wahr bei 8 m")
	check_eq(fish.hud.warning_label.text, "Vorsicht: Raubfisch in 8 m!", "Text korrekt bei 8 m")


func test_warnung_fern() -> void:
	_clear_ai_fishes()
	fish.add_fish("zackenbarsch", fish.player.motion.position + Vector3(40, 0, 0))
	fish.update_warning()
	check(!fish.hud.warning_label.visible, "warning_label.visible ist falsch bei 40 m")


func test_keine_warnung_bei_beute() -> void:
	_clear_ai_fishes()
	fish.add_fish("grasfisch", fish.player.motion.position + Vector3(5, 0, 0))
	fish.update_warning()
	check(!fish.hud.warning_label.visible, "warning_label.visible ist falsch bei Beute")


func test_biss_blitzt() -> void:
	_clear_ai_fishes()
	var f: AiFish = fish.add_fish("zackenbarsch", fish.player.motion.position + Vector3(0, 0, 1.5))
	fish.predators_bite()
	check(fish.hud.flash_rect.color.a > 0.0, "fish.hud.flash_rect.color.a > 0.0 nach Biss")


## Test: Statistik fressen wird gezählt.
func test_statistik_fressen() -> void:
	_clear_ai_fishes()
	fish.player.build.diet = Diet.FLEISCHFRESSER
	var f: AiFish = fish.add_fish("silberling", fish.player.mouth_point())
	f.health.hp = 1.0
	fish.player_bites()
	check_eq(fish.stats.total_eaten(), 1, "total_eaten ist 1")
	check_eq(fish.stats.eaten["silberling"], 1, "eaten['silberling'] ist 1")


## Test: Statistik Tod wird gezählt.
func test_statistik_tod() -> void:
	_clear_ai_fishes()
	fish.player_health.hp = 0.0
	fish.check_death()
	check_eq(fish.stats.deaths, 1, "deaths ist 1 nach check_death()")


## Test: Statistik Tiefe wird gezählt.
func test_statistik_tiefe() -> void:
	_clear_ai_fishes()
	fish.player.motion.position = Vector3(0, -35, 0)
	fish._physics_process(0.016)
	check(fish.stats.max_depth >= 34.0, "max_depth ist mindestens 34.0")


## Test: Statistik in Pause wird angezeigt.
func test_statistik_in_pause() -> void:
	_clear_ai_fishes()
	fish.stats.record_death()
	var vorherige_sichtbarkeit = fish.hud.message_label.visible
	fish.toggle_pause()
	check(fish.hud.message_label.visible, "message_label.visible wahr nach toggle_pause")
	check_eq(fish.hud.message_label.text, fish.stats.summary(), "message_text ist summary()")
	fish.toggle_pause()


## Test: Der Boden hat die Sandtextur, die Oberfläche keine.
func test_sandboden() -> void:
	check(((fish.floor_mesh.mesh as PlaneMesh).material as StandardMaterial3D).albedo_texture == FishTextures.SAND, "Boden hat SAND-Textur")
	check((fish.surface_mesh.mesh as PlaneMesh).material.albedo_texture == null, "Oberfläche hat keine Textur")


## Test: Nachschub wartet, bis RESPAWN_INTERVAL Sekunden vergangen sind.
func test_nachschub_wartet() -> void:
	_clear_ai_fishes()
	fish.respawn_timer = 0.0
	check_eq(fish.refill_fish(1.0), 0, "fish.refill_fish(1.0) ist 0")
	check_eq(fish.fishes.size(), 0, "fish.fishes.size() ist 0")


## Test: Nachschub füllt alle fehlenden Fische auf Zielanzahl.
func test_nachschub() -> void:
	_clear_ai_fishes()
	fish.respawn_timer = 0.0
	var gezaehlt: int = fish.refill_fish(fish.RESPAWN_INTERVAL)
	var zielsumme := 0
	for v in FishSchool.target_counts().values():
		zielsumme += v
	check_eq(gezaehlt, zielsumme, "Anzahl neuer Fische gleich Summe von target_counts()")
	check(FishSchool.missing(fish.fishes).is_empty(), "FishSchool.missing(fish.fishes) ist leer")
	check_eq(fish.respawn_timer, 0.0, "fish.respawn_timer ist 0.0")


## Test: Nachschub platziert Fische außer Sicht (mindestens MIN_DIST vom Spieler entfernt).
func test_nachschub_ausser_sicht() -> void:
	_clear_ai_fishes()
	fish.respawn_timer = 0.0
	var gezaehlt: int = fish.refill_fish(fish.RESPAWN_INTERVAL)
	var zielsumme := 0
	for v in FishSchool.target_counts().values():
		zielsumme += v
	check_eq(gezaehlt, zielsumme, "Anzahl neuer Fische gleich Summe von target_counts()")
	for f in fish.fishes:
		check(f.motion.position.distance_to(fish.player.motion.position) >= FishSchool.MIN_DIST, "jeder Fisch mindestens MIN_DIST vom Spieler entfernt")


## Test: Schwierigkeitsgrad Normal - Schaden ist Basis-Schaden.
func test_schaden_normal() -> void:
	fish.settings.difficulty = Difficulty.NORMAL
	check_eq(fish.predator_damage(15.0), FishCombat.damage_to_player(15.0, fish.player.build), "Schaden bei Normal")


## Test: Schwierigkeitsgrad Leicht - Schaden ist 60% des Basis-Schadens.
func test_schaden_leicht() -> void:
	fish.settings.difficulty = 0
	check_eq(fish.predator_damage(15.0), FishCombat.damage_to_player(15.0, fish.player.build) * 0.6, "Schaden bei Leicht")


## Test: Schwierigkeitsgrad Schwer - Schaden ist größer als Basis-Schaden.
func test_schaden_schwer() -> void:
	fish.settings.difficulty = 2
	check(fish.predator_damage(10.0) > FishCombat.damage_to_player(10.0, fish.player.build), "Schaden bei Schwer größer als Basis")


## Test: Fischszene spielt die eigene Musik (FishMusic.theme() statt CellMusic.theme()).
func test_fischmusik() -> void:
	check(fish.audio.music.stream is AudioStreamWAV, "fish.audio.music.stream ist AudioStreamWAV")
	var fish_stream: AudioStreamWAV = fish.audio.music.stream as AudioStreamWAV
	var cell_stream: AudioStreamWAV = CellMusic.theme()
	check_eq(fish_stream.data.size(), FishMusic.theme().data.size(), "Stream-Größe entspricht FishMusic.theme()")
	check(fish_stream.data.size() != cell_stream.data.size(), "Stream-Größe ungleich CellMusic.theme()")


## Test: Wächst der Fisch, ohne ausgewachsen zu sein, kommt die normale Meldung.
func test_gewachsen_meldung() -> void:
	_clear_ai_fishes()
	fish.progress.stage = 0
	fish.progress.growth = 0
	fish.eat_value(FishProgress.GROWTH_NEEDED[0])
	check_eq(fish.hud.message_label.text, "Dein Fisch ist gewachsen!", "normale Wachstumsmeldung")


## Test: Erreicht der Fisch die letzte Größe, kommt GROWN_MESSAGE.
func test_ausgewachsen_meldung() -> void:
	_clear_ai_fishes()
	fish.progress.stage = 2
	fish.progress.growth = 0
	fish.eat_value(FishProgress.GROWTH_NEEDED[2])
	check(fish.progress.is_final_stage(), "Fisch ist ausgewachsen")
	check_eq(fish.hud.message_label.text, fish.GROWN_MESSAGE, "Meldung ist GROWN_MESSAGE")


## Test: Der FadeIn-CanvasLayer und ColorRect werden angelegt.
func test_fadein_angelegt() -> void:
	check(fish.get_node("FadeIn") is CanvasLayer, "Knoten 'FadeIn' ist CanvasLayer")
	check(fish.fade_rect != null, "fade_rect existiert")
	check_eq(fish.fade_rect.color.a, 1.0, "fade_rect.color.a ist 1.0 am Anfang")
	check(fish.fade_rect.visible, "fade_rect.visible ist wahr zu Beginn")


## Test: FadeIn blendet während _process() aus und wird unsichtbar.
func test_einblenden() -> void:
	check_eq(fish.fade_rect.color.a, 1.0, "fade_rect.color.a ist 1.0 nach dem Start")
	fish._process(0.4)
	var alpha_nach_04: float = fish.fade_rect.color.a
	check(alpha_nach_04 > 0.4 && alpha_nach_04 < 0.6, "nach _process(0.4) ist Alpha ca. 0.5 (ist %f)" % [alpha_nach_04])
	fish._process(0.5)
	check(not fish.fade_rect.visible, "fade_rect.visible ist falsch nach vollständiger Einblendung")


func test_zeitstrahl_verbesserung() -> void:
	fish.progress.dna = 50
	fish.evolve.open(fish.player.build, fish.progress)
	fish.evolve.buttons["schwanz"].pressed.emit()
	check_eq(fish.timeline.last().get("kind", ""), EvolutionTimeline.UPGRADE, "letzter Eintrag ist eine Verbesserung")
	check_eq(fish.timeline.last().get("phase", ""), "fisch", "Eintrag gehört zur Fischphase")


func test_zeitstrahl_wachsen() -> void:
	var before: int = fish.timeline.size()
	for i in 200:
		fish.eat_value(5)
		if fish.progress.stage > 0:
			break
	check_eq(fish.timeline.size(), before + 1, "neue Fischgröße im Zeitstrahl")
	check_eq(fish.timeline.last().get("kind", ""), EvolutionTimeline.FISH_SIZE, "Art Fischgröße")


func test_zeitstrahl_taste() -> void:
	check(not fish.timeline_view.visible, "Zeitstrahl anfangs verborgen")
	fish.toggle_timeline()
	check(fish.timeline_view.visible, "toggle_timeline zeigt den Zeitstrahl")
	fish.toggle_timeline()
	check(not fish.timeline_view.visible, "und verbirgt ihn wieder")
