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


# Tests für FishAbilities.apply()

func test_faehigkeiten_anfang() -> void:
	var player := FishPlayer.new()
	check_eq(player.motion.max_speed, 8.0, "motion.max_speed am Anfang 8.0")
	check_eq(player.motion.turn_rate, 1.8, "motion.turn_rate am Anfang 1.8")
	player.free()


func test_faehigkeiten_nach_ausbau() -> void:
	var player := FishPlayer.new()
	var b := FishBuild.new()
	b.upgrade("schwanz")
	b.upgrade("schwanz")
	b.upgrade("flossen")
	player.set_build(b)
	check_eq(player.motion.max_speed, 12.0, "motion.max_speed nach Ausbau 12.0")
	check_eq(player.motion.accel, 15.0, "motion.accel nach Ausbau 15.0")
	check_eq(player.motion.turn_rate, 2.2, "motion.turn_rate nach Ausbau 2.2")
	player.free()


func test_schneller_ausgebaut() -> void:
	var player1 := FishPlayer.new()
	var player2 := FishPlayer.new()

	var b1 := FishBuild.new()
	b1.upgrade("schwanz")
	b1.upgrade("schwanz")
	b1.upgrade("schwanz")
	player1.set_build(b1)

	var b2 := FishBuild.new()
	player2.set_build(b2)

	for i in range(30):
		player1.drive(Vector3(1, 0, 0), 0.1)
		player2.drive(Vector3(1, 0, 0), 0.1)

	check(player1.motion.speed() > player2.motion.speed(), "ausgebauter Spielerfisch ist schneller nach 3s")
	player1.free()
	player2.free()
