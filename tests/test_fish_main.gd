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
