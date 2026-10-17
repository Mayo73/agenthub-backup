extends "res://tests/base_test.gd"

const P := "user://test_main_blitz.json"

var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	main.save_path = P
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()
	if FileAccess.file_exists(P):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(P))


func test_knoten() -> void:
	check(main.world.get_node("Zaps") is ZapView, "Knoten Zaps ist ein ZapView")


func test_blitz_bei_entladung() -> void:
	main.start_scene("elektro")
	main.ai_cells[0].motion.position = Vector2(40, 0)
	main.resolve_weapons(0.016)
	check(main.zap_view.is_zap_visible(), "Blitz nach der Entladung sichtbar")
	check_eq(main.zap_view.lines.size(), 1, "ein Blitz je getroffener Zelle")
	check_eq(main.zap_view.lines[0][6], Vector2(40, 0), "Blitz endet an der getroffenen Zelle")


func test_kein_ziel() -> void:
	main.start_scene("elektro")
	main.ai_cells[0].motion.position = Vector2(500, 0)
	main.resolve_weapons(0.016)
	check(not main.zap_view.is_zap_visible(), "ohne Ziel in Reichweite kein Blitz")
