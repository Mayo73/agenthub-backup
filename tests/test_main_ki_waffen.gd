extends "res://tests/base_test.gd"

const P := "user://test_main_ki_waffen.json"
var main: Node2D


func setup() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	main.save_path = P
	(Engine.get_main_loop() as SceneTree).root.add_child(main)
	main.start_new(Diet.PFLANZENFRESSER)
	for cell in main.ai_cells.duplicate():
		main.remove_ai(cell)
	main.settings.difficulty = Difficulty.NORMAL
	main.player_health.invulnerable = 0.0


func teardown() -> void:
	main.free()
	if FileAccess.file_exists(P):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(P))


func _add(id: String, offset: Vector2) -> AiCell:
	var cell := AiCell.new()
	var pos: Vector2 = main.player.motion.position + offset
	cell.setup(id, pos)
	cell.motion.heading = 0.0
	main.world.add_child(cell)
	main.ai_cells.append(cell)
	return cell


func test_stachelkugel_sticht() -> void:
	_add("stachelkugel", Vector2(-30, 0))
	var vorher: float = main.player_health.hp
	main.resolve_ai_weapons(0.016)
	check_eq(vorher - main.player_health.hp, WeaponRules.SPIKE_DAMAGE, "Stachelkugel verursacht SPIKE_DAMAGE")


func test_schwer() -> void:
	main.settings.difficulty = 2
	_add("stachelkugel", Vector2(-30, 0))
	var vorher: float = main.player_health.hp
	main.resolve_ai_weapons(0.016)
	check_eq(vorher - main.player_health.hp, WeaponRules.SPIKE_DAMAGE * 1.5, "Schwerer Schwierigkeitsgrad multipliziert mit 1.5")


func test_ohne_stacheln() -> void:
	_add("blasenling", Vector2(-30, 0))
	var vorher: float = main.player_health.hp
	main.resolve_ai_weapons(0.016)
	check_eq(main.player_health.hp, vorher, "Blasenling verursacht keinen Schaden")


func test_weit_weg() -> void:
	_add("stachelkugel", Vector2(-200, 0))
	var vorher: float = main.player_health.hp
	main.resolve_ai_weapons(0.016)
	check_eq(main.player_health.hp, vorher, "Zu weit entfernt verursacht keinen Schaden")


func test_im_ablauf() -> void:
	check(FileAccess.get_file_as_string("res://scripts/main.gd").contains("resolve_ai_weapons(delta)"), "main.gd enthält resolve_ai_weapons(delta)")


func test_giftling_hinterlaesst_wolke() -> void:
	var c := _add("giftling", Vector2(200, 0))
	c.motion.velocity = Vector2(50, 0)
	main.resolve_ai_weapons(0.1)
	check_eq(c.poison.clouds.size(), 1, "Giftwolke erzeugt")
	check(main.poison_view.sources.has(c.poison), "Giftwolke in Quellen der KI-Zelle")
	check(main.poison_view.sources.has(main.poison), "Giftwolke der Spielerzelle in Quellen")
	c.free()


func test_giftwolke_schadet() -> void:
	var c := _add("giftling", Vector2(200, 0))
	c.motion.velocity = Vector2.ZERO
	c.poison.clouds.append({"pos": main.player.motion.position, "age": 0.0})
	var vorher: float = main.player_health.hp
	main.resolve_ai_weapons(0.5)
	check_eq(vorher - main.player_health.hp, PoisonClouds.DPS * 0.5, "Giftwolke verursacht Schaden")
	c.free()


func test_zitterzelle_entlaedt_sich() -> void:
	var c := _add("zitterzelle", Vector2(40, 0))
	var vorher: float = main.player_health.hp
	main.resolve_ai_weapons(0.016)
	check_eq(vorher - main.player_health.hp, ElectricOrgan.DAMAGE, "Zitterzelle verursacht DAMAGE")
	check(!c.organ.is_ready(), "Zitterzelle ist nach Entladung nicht bereit")
	check(main.zap_view.is_zap_visible(), "Blitz sichtbar")
	c.free()


func test_zitterzelle_laedt_nach() -> void:
	_add("zitterzelle", Vector2(40, 0))
	main.resolve_ai_weapons(0.016)
	main.player_health.invulnerable = 0.0
	var vorher: float = main.player_health.hp
	main.resolve_ai_weapons(0.016)
	check_eq(main.player_health.hp, vorher, "Zitterzelle lädt nach, kein Schaden")


func test_zitterzelle_weit_weg() -> void:
	var c := _add("zitterzelle", Vector2(300, 0))
	main.resolve_ai_weapons(0.016)
	check(c.organ.is_ready(), "Zitterzelle ist bereit wenn weit weg")
	c.free()
