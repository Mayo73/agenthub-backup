extends "res://tests/base_test.gd"

var fish: Node3D


func setup() -> void:
	fish = load("res://scenes/fish.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(fish)


func teardown() -> void:
	FishStart.clear()
	fish.free()


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
