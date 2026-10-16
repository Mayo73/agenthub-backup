extends "res://tests/base_test.gd"

var main: Node2D

func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)

func teardown() -> void:
	main.free()


func test_partner_wie_spieler() -> void:
	var l := CellLook.new()
	l.color = Color.RED
	main.player.set_look(l)
	main.mate.add_charge()
	main.call_mate()
	main.update_mate()
	check_eq(main.partner_view.look, l, "Partner sieht aus wie Spieler (Look)")
	check_eq(main.partner_view.radius, main.player.radius, "Partner-Radius ist Spieler-Radius")


func test_beruehrung_reicht() -> void:
	main.player.set_stage(3)
	main.mate.add_charge()
	main.call_mate()
	main.player.position = (main.mate.partner_pos as Vector2) + Vector2(main.player.radius * 1.9, 0)
	main.update_mate()
	check_eq(main.editor_open, true, "Editor öffnet bei Berührung")
	main.editor.cancel()


func test_zu_weit() -> void:
	main.mate.add_charge()
	main.call_mate()
	main.player.position = (main.mate.partner_pos as Vector2) + Vector2(main.player.radius * 2.5, 0)
	main.update_mate()
	check_eq(main.editor_open, false, "Editor bleibt zu bei zu großem Abstand")
