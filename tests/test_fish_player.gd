extends "res://tests/base_test.gd"

var fish: FishPlayer


func setup() -> void:
	fish = FishPlayer.new()


func teardown() -> void:
	fish.free()


func test_start() -> void:
	check_eq(fish.position, FishWorld.START, "fish.position ist START")
	check(fish.get_node("Model") is FishModel, "Model ist FishModel")
	check_eq(fish.size, 1.0, "fish.size ist 1.0")


func test_schwimmen() -> void:
	fish.drive(Vector3(1, 0, 0), 0.1)
	check(fish.position.z < 0.0, "fish.position.z < 0.0 nach drive vorwärts")
	check_eq(fish.position, fish.motion.position, "position = motion.position")


func test_ausrichtung() -> void:
	fish.drive(Vector3(0, 1, 1), 0.5)
	check_eq(fish.rotation.y, fish.motion.yaw, "rotation.y = motion.yaw")
	check_eq(fish.rotation.x, fish.motion.pitch, "rotation.x = motion.pitch")
	check(fish.rotation.x > 0.0, "rotation.x > 0.0 nach positivem climb")


func test_ausbau() -> void:
	var b := FishBuild.new()
	b.upgrade("schwanz")
	b.upgrade("schwanz")
	fish.set_build(b)
	check_eq(fish.build.level("schwanz"), 2, "build.level('schwanz') ist 2")
	check(fish.model.build == b, "fish.model.build == b")


func test_groesse() -> void:
	fish.set_size(2.0)
	check_eq(fish.model.scale, Vector3(2, 2, 2), "model.scale ist Vector3(2,2,2)")
	check(fish.mouth_point().is_equal_approx(FishWorld.START + Vector3(0, 0, -1.6)), "mouth_point() mit size=2")


func test_maul() -> void:
	check(fish.mouth_point().is_equal_approx(FishWorld.START + Vector3(0, 0, -0.8)), "mouth_point() ist START + (0,0,-0.8)")
