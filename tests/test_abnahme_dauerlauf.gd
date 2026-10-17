extends "res://tests/base_test.gd"

const P := "user://test_abnahme_dauerlauf.json"
const DT := 0.05
var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	main.save_path = P
	(Engine.get_main_loop() as SceneTree).root.add_child(main)
	main.start_new(Diet.PFLANZENFRESSER)


func teardown() -> void:
	main.free()
	if FileAccess.file_exists(P):
		DirAccess.remove_absolute(P)


func _step(i: int) -> void:
	main.player.drive(DT, Vector2.from_angle(i * 0.02))
	main._physics_process(DT)
	for cell in main.ai_cells:
		cell.drive(DT)


func test_eine_minute() -> void:
	for i in 1200:
		_step(i)

	check(main.ai_cells.size() > 0, "KI-Zellen sollten vorhanden sein")
	check(main.ai_cells.size() <= EcoSpawner.TARGET_COUNT, "Nicht mehr als TARGET_COUNT KI-Zellen")
	check(main.food.items.size() > 0, "Nahrung sollte noch vorhanden sein")
	check(not main.player_health.is_dead(), "Spielerzelle sollte leben")
	check(not main.in_menu, "Nicht im Menü während des Spiels")
	check(not main.editor_open, "Editor sollte nicht offen sein")
	check(main.player.motion.position.length() > 100.0, "Zelle sollte geschwommen sein")


func test_tod_und_weiter() -> void:
	main.player_health.drain(1000.0)
	main._physics_process(DT)

	check(main.deaths == 1, "Sollte einen Tod registriert haben")
	# Nach Wiedereinstieg ist die Zelle unverwundbar und hat volles Leben, daher nicht tot
	check(not main.player_health.is_dead(), "Nach Tod und Neuschläpfung sollte Spieler wieder leben")

	for i in 200:
		_step(i)

	check(not main.in_menu, "Sollte nach Wiedereinstieg im Spiel sein")
	check(not main.player_health.is_dead(), "Spielerzelle sollte nach Wiedereinstieg leben")


func test_pause_mitten() -> void:
	for i in 100:
		_step(i)

	main.toggle_pause()

	check(main.paused, "Spiel sollte paused sein")
	check(main.pause_menu.visible, "Pause-Menü sollte sichtbar sein")

	main.toggle_pause()

	check(not main.paused, "Spiel sollte nicht mehr paused sein")
	check(not main.pause_menu.visible, "Pause-Menü sollte unsichtbar sein")


func test_menue_und_zurueck() -> void:
	for i in 100:
		_step(i)

	main.back_to_menu()

	check(main.in_menu, "Sollte im Menü sein")

	main.start_new(Diet.FLEISCHFRESSER)

	check(not main.in_menu, "Nicht mehr im Menü nach start_new")

	for i in 100:
		_step(i)

	check(main.player.diet == Diet.FLEISCHFRESSER, "Spielerzelle sollte Fleischfresser sein")
