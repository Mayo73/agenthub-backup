extends "res://tests/base_test.gd"

const P := "user://test_abnahme_durchlauf.json"
var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	main.save_path = P
	Engine.get_main_loop().root.add_child(main)


func teardown() -> void:
	main.free()
	var dir := FileAccess.open(P, FileAccess.READ)
	if dir != null:
		dir.close()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(P))


## Ein Stück Nahrung direkt ans Maul legen und fressen.
func _bite(kind: String) -> void:
	main.food.items.clear()
	main.food.add_item(kind, main.player.mouth_point())
	main.feed_player()


## Frisst, bis die Bedingung erfüllt ist (höchstens 500 Bissen).
func _eat_until_stage(kind: String, stage: int) -> void:
	var n := 0
	while main.progress.stage < stage and n < 500:
		_bite(kind)
		n += 1


func _eat_until_end(kind: String) -> void:
	var n := 0
	while not PhaseEnd.can_finish(main.progress) and n < 500:
		_bite(kind)
		n += 1


func _visit() -> void:
	main.mate.add_charge()
	main.call_mate()
	main.player.position = main.mate.partner_pos
	main.update_mate()


func test_pflanzenfresser() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	_eat_until_end(Diet.PFLANZE)
	check(PhaseEnd.can_finish(main.progress), "PhaseEnd.can_finish muss wahr sein")
	check_eq(main.progress.stage, 4, "main.progress.stage muss 4 sein")
	check_eq(main.player.radius, 60.0, "main.player.radius muss 60.0 sein")
	check(main.stats.food_eaten > 0, "main.stats.food_eaten muss größer 0 sein")
	main.finish_phase()
	check(main.finished, "main.finished muss wahr sein")
	check(main.end_screen.visible, "main.end_screen.visible muss wahr sein")
	check(FileAccess.file_exists(P), "Save-Datei muss existieren")


func test_fleischfresser() -> void:
	main.start_new(Diet.FLEISCHFRESSER)
	_eat_until_end(Diet.FLEISCH)
	check(PhaseEnd.can_finish(main.progress), "PhaseEnd.can_finish muss wahr sein")
	check_eq(main.progress.stage, 4, "main.progress.stage muss 4 sein")
	check_eq(main.player.radius, 60.0, "main.player.radius muss 60.0 sein")
	check(main.stats.food_eaten > 0, "main.stats.food_eaten muss größer 0 sein")
	main.finish_phase()
	check(main.finished, "main.finished muss wahr sein")
	check(main.end_screen.visible, "main.end_screen.visible muss wahr sein")
	check(FileAccess.file_exists(P), "Save-Datei muss existieren")


func test_mit_umbau() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	_eat_until_stage(Diet.PFLANZE, 1)
	check_eq(main.progress.stage, 1, "main.progress.stage muss 1 sein")
	_visit()
	check(main.editor_open, "main.editor_open muss wahr sein")
	main.editor.set_color(Color.RED)
	main.editor.confirm()
	check(not main.editor_open, "main.editor_open muss falsch sein")
	_eat_until_end(Diet.PFLANZE)
	main.finish_phase()
	check(main.finished, "main.finished muss wahr sein")
	check_eq(main.stats.editor_visits, 1, "main.stats.editor_visits muss 1 sein")
	check(main.player.look.color.is_equal_approx(Color.RED), "Farbe muss ROT sein")


func test_zurueck_ins_menue() -> void:
	main.start_new(Diet.FLEISCHFRESSER)
	_eat_until_end(Diet.FLEISCH)
	main.finish_phase()
	main._on_end_to_menu()
	check(main.in_menu, "main.in_menu muss wahr sein")
	check(not main.end_screen.visible, "main.end_screen.visible muss falsch sein")
	check(not main.finished, "main.finished muss falsch sein")
