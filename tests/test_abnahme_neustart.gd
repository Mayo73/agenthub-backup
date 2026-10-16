extends "res://tests/base_test.gd"

const P := "user://test_abnahme_neustart_"
const S := "user://test_abnahme_neustart.cfg"
var main: Node2D


func _is_equal_approx(a: float, b: float) -> bool:
	return is_equal_approx(float(a), float(b))


func _start_game() -> Node2D:
	var m: Node2D = load("res://scenes/main.tscn").instantiate()
	m.slot_prefix = P
	m.settings_path = S
	(Engine.get_main_loop() as SceneTree).root.add_child(m)
	return m


func teardown() -> void:
	if main != null and is_instance_valid(main):
		main.free()
		main = null
	for slot in range(1, 4):
		var slot_path := SaveSlots.path_for(slot, P)
		var cfg_path := ProjectSettings.globalize_path(S)
		if FileAccess.file_exists(slot_path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(slot_path))
		if FileAccess.file_exists(cfg_path):
			DirAccess.remove_absolute(cfg_path)


func test_spielstand() -> void:
	main = _start_game()
	main.ask_slot_new(Diet.FLEISCHFRESSER)
	main.slot_menu.slot_buttons[0].pressed.emit()

	check(not main.in_menu, "Zu Spielbeginn im Spiel")

	# Nach Speichern, vollständigem Beenden und Neustart prüfen wir den Spielstand.
	main.progress.eat(30)  # Abschnitt 2, Wachstum 5
	main.progress.dna = 42
	main.unlocks.unlock("stachel")

	var b: CellBuild = main.player.build.copy()
	b.add_part("stachel", Vector2(1, 0))
	main.player.set_build(b)
	main.player.set_stage(main.progress.stage)
	main.player_health.hp = 55.0

	var l := CellLook.new()
	l.color = Color.RED
	l.set_pattern("punkte")
	main.player.set_look(l)

	check(main.save_now(), "speichern sollte wahr sein")

	# Beenden und neustarten
	main.free()
	main = _start_game()

	check(main.in_menu, "Nach Neustart im Hauptmenü")
	check(not main.main_menu.continue_button.disabled, "Weiter-Knopf ist aktiv")

	main.ask_slot_continue()
	main.slot_menu.slot_buttons[0].pressed.emit()

	check(not main.in_menu, "Nach Fortsetzen nicht im Menü")
	check(_is_equal_approx(main.progress.dna, 42), "DNA stimmt (42)")
	check(main.progress.stage == 2, "Abschnitt stimmt (2)")
	check(main.progress.growth == 5, "Wachstum stimmt (5)")
	check(main.unlocks.is_unlocked("stachel"), "Stachel ist freigeschaltet")

	check(main.player.build.parts.size() == 3, "Zellaufbau hat 3 Teile")
	check(main.player.build.count("stachel") == 1, "Ein Stachel vorhanden")
	check(main.player.diet == Diet.FLEISCHFRESSER, "Ernährung stimmt")
	check(_is_equal_approx(main.player_health.hp, 55.0), "Gesundheit stimmt (55)")

	check(main.player.look.color.is_equal_approx(Color.RED), "Farbe stimmt (ROT)")
	check(main.player.look.pattern == "punkte", "Muster stimmt (punkte)")
	check(_is_equal_approx(main.player.radius, CellProgress.radius_for_stage(2)), "Radius stimmt")


func test_einstellungen() -> void:
	main = _start_game()

	main.settings.set_music_volume(0.3)
	main.settings.set_sfx_volume(0.6)
	main.settings.fullscreen = true
	main.settings.set_resolution_index(1)
	main.close_settings()

	main.free()
	main = _start_game()

	check(main.settings.music_volume == 0.3, "Musiklautstärke stimmt (0.3)")
	check(main.settings.sfx_volume == 0.6, "SFX-Lautstärke stimmt (0.6)")
	check(main.settings.fullscreen, "Vollbild stimmt")
	check(main.settings.resolution_index == 1, "Auflösungsindex stimmt (1)")

	var music_bus := AudioServer.get_bus_index("Musik")
	if music_bus >= 0:
		var expected_db := UserSettings.to_db(0.3)
		var actual_db := AudioServer.get_bus_volume_db(music_bus)
		check(_is_equal_approx(actual_db, expected_db), "Audiobus Musiklautstärke stimmt")

	# Lautstärken zurücksetzen, damit andere Tests nicht gestört werden
	main.settings = UserSettings.new()
	main.apply_settings()
