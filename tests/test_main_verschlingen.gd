extends "res://tests/base_test.gd"

const P := "user://test_main_verschlingen.json"
var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	main.save_path = P
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()
	if FileAccess.file_exists(P):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(P))


func test_kleine_beute_ganz() -> void:
	main.start_scene("flucht")
	var dna: int = main.progress.dna
	main.ai_cells[0].motion.position = Vector2(50, 0)
	main.resolve_combat()
	check_eq(main.ai_cells.size(), 0, "main.ai_cells.size() ist 0")
	check_eq(main.food.count_kind(Diet.FLEISCH), 0, "kein Fleisch (direkte Nahrung)")
	check_eq(main.progress.dna, dna + 6, "DNA um 6 erhöht")
	check_eq(main.stats.cells_defeated, 1, "cells_defeated ist 1")


func test_gleich_gross_nur_verletzt() -> void:
	main.start_scene("flucht")
	main.remove_ai(main.ai_cells[0])
	var c := AiCell.new()
	c.setup("weidezelle", Vector2(70, 0))
	main.world.add_child(c)
	main.ai_cells.append(c)
	c.motion.position = Vector2(70, 0)
	main.resolve_combat()
	check_eq(main.ai_cells.size(), 1, "main.ai_cells.size() ist 1")
	check(c.health.hp < c.health.max_hp, "c.health.hp < c.health.max_hp")


func test_pflanzenfresser_verschluckt_nicht() -> void:
	main.start_scene("flucht")
	main.player.diet = Diet.PFLANZENFRESSER
	main.ai_cells[0].motion.position = Vector2(50, 0)
	main.resolve_combat()
	check_eq(main.ai_cells.size(), 1, "main.ai_cells.size() ist 1")


func test_fressen_wie_bisher() -> void:
	main.start_scene("flucht")
	var dna: int = main.progress.dna
	main.eat_value(Diet.FLEISCH, 2)
	check_eq(main.progress.dna, dna + 2, "DNA um 2 erhöht")
	check_eq(main.stats.food_eaten, 1, "stats.food_eaten ist 1")


func test_szene() -> void:
	main.start_scene("verschlingen")
	check_eq(main.ai_cells.size(), 2, "main.ai_cells.size() ist 2")
	check_eq(main.player.radius, 27.0, "main.player.radius ist 27")
	check_eq(main.ai_cells[0].species_id, "blasenling", "main.ai_cells[0].species_id ist 'blasenling'")
	check_eq(main.ai_cells[1].species_id, "panzerling", "main.ai_cells[1].species_id ist 'panzerling'")


func test_szene_regel() -> void:
	main.start_scene("verschlingen")
	var klein: AiCell = main.ai_cells[0]
	var gross: AiCell = main.ai_cells[1]
	klein.motion.position = Vector2(35, 0)
	gross.motion.position = Vector2(500, 500)
	main.resolve_combat()
	check(not main.ai_cells.has(klein), "klein wurde verschluckt")
	check(main.ai_cells.has(gross), "gross ist noch da")
	gross.motion.position = Vector2(50, 0)
	main.resolve_combat()
	check(main.ai_cells.has(gross), "gross ist immer noch da")
	check(gross.health.hp < gross.health.max_hp, "gross.health.hp < gross.health.max_hp")
