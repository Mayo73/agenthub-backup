extends "res://tests/base_test.gd"

var pause: CanvasLayer


func setup() -> void:
	Controls.setup()
	pause = load("res://scenes/pause_menu.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(pause)


func teardown() -> void:
	(Engine.get_main_loop() as SceneTree).paused = false
	pause.free()
	pause = null


func test_start_geschlossen() -> void:
	check(not pause.visible, "PauseMenu soll am Anfang unsichtbar sein")


func test_oeffnen_und_schliessen() -> void:
	pause.open()
	check(pause.visible, "PauseMenu soll nach open() sichtbar sein")
	check((Engine.get_main_loop() as SceneTree).paused, "Spiel soll nach open() pausiert sein")

	pause.close()
	check(not pause.visible, "PauseMenu soll nach close() unsichtbar sein")
	check(not (Engine.get_main_loop() as SceneTree).paused, "Spiel soll nach close() fortgesetzt sein")


func test_umschalten() -> void:
	pause.toggle()
	check(pause.visible, "PauseMenu soll nach erstem toggle() sichtbar sein")

	pause.toggle()
	check(not pause.visible, "PauseMenu soll nach zweitem toggle() unsichtbar sein")


func test_neustart_signal() -> void:
	var count := [0]
	pause.restart_requested.connect(func() -> void: count[0] += 1)

	pause.open()
	check(pause.visible, "PauseMenu muss vor _on_restart() sichtbar sein")
	check((Engine.get_main_loop() as SceneTree).paused, "Spiel muss vor _on_restart() pausiert sein")

	pause._on_restart()
	check(count[0] == 1, "restart_requested-Signal wurde erwartet")
	check(not (Engine.get_main_loop() as SceneTree).paused, "Spiel soll nach Neustart fortgesetzt sein")


func test_menueszene_existiert() -> void:
	ResourceLoader.exists(pause.MENU_SCENE)
	check(ResourceLoader.exists(pause.MENU_SCENE), "main_menu.tscn existiert")
