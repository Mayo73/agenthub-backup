extends "res://tests/base_test.gd"

const P := "user://test_abnahme_nahrung.json"
var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	main.save_path = P
	(Engine.get_main_loop() as SceneTree).root.add_child(main)


func teardown() -> void:
	main.free()
	if FileAccess.file_exists(P):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(P))


func _feed(kind: String) -> void:
	main.food.items.clear()
	main.food.add_item(kind, main.player.mouth_point())
	main.feed_player()


func _allesfresser() -> void:
	var b := CellBuild.new()
	b.add_part("ruessel", Vector2(1, 0))
	main.player.set_build(b)


func test_pflanzenfresser_pflanze() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	_feed(Diet.PFLANZE)
	check(main.progress.dna > 0, "dna > 0 nach Fressen einer Pflanze")
	check(main.progress.growth > 0, "growth > 0 nach Fressen einer Pflanze")
	check_eq(main.food.items.size(), 0, "main.food.items.size() ist 0")


func test_pflanzenfresser_fleisch() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	_feed(Diet.FLEISCH)
	check_eq(main.progress.dna, 0, "dna ist 0 bei ungeeigneter Nahrung")
	check_eq(main.progress.growth, 0, "growth ist 0 bei ungeeigneter Nahrung")
	check_eq(main.food.items.size(), 1, "main.food.items.size() ist 1")


func test_fleischfresser_fleisch() -> void:
	main.start_new(Diet.FLEISCHFRESSER)
	_feed(Diet.FLEISCH)
	check(main.progress.dna > 0, "dna > 0 nach Fressen von Fleisch")
	check_eq(main.food.items.size(), 0, "main.food.items.size() ist 0")


func test_fleischfresser_pflanze() -> void:
	main.start_new(Diet.FLEISCHFRESSER)
	_feed(Diet.PFLANZE)
	check_eq(main.progress.dna, 0, "dna ist 0 bei ungeeigneter Nahrung")
	check_eq(main.progress.growth, 0, "growth ist 0 bei ungeeigneter Nahrung")
	check_eq(main.food.items.size(), 1, "main.food.items.size() ist 1")


func test_allesfresser() -> void:
	main.start_new(Diet.PFLANZENFRESSER)
	_allesfresser()
	check(main.player.diet == Diet.ALLESFRESSER, "diet ist ALLESFRESSER nach Rüssel")
	_feed(Diet.PFLANZE)
	var nach_pflanze: int = main.progress.dna
	check(nach_pflanze > 0, "dna > 0 nach Fressen einer Pflanze als Allesfresser")
	_feed(Diet.FLEISCH)
	check(main.progress.dna > nach_pflanze, "dna > nach_pflanze nach zusätzlichem Fleisch")
