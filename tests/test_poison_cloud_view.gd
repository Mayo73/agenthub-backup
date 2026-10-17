extends "res://tests/base_test.gd"

func test_alpha() -> void:
	check_eq(PoisonCloudView.cloud_alpha(0.0), 0.45, "cloud_alpha(0.0) ist 0.45")
	check_eq(PoisonCloudView.cloud_alpha(PoisonClouds.LIFETIME / 2.0), 0.225, "cloud_alpha(LIFETIME/2) ist 0.225")
	check_eq(PoisonCloudView.cloud_alpha(PoisonClouds.LIFETIME), 0.0, "cloud_alpha(LIFETIME) ist 0.0")
	check_eq(PoisonCloudView.cloud_alpha(10.0), 0.0, "cloud_alpha(10.0) ist 0.0")


func test_radius() -> void:
	check_eq(PoisonCloudView.cloud_radius(0.0), PoisonClouds.RADIUS * 0.6, "cloud_radius(0.0) ist RADIUS*0.6")
	check_eq(PoisonCloudView.cloud_radius(PoisonClouds.LIFETIME), PoisonClouds.RADIUS, "cloud_radius(LIFETIME) ist RADIUS")
	check_eq(PoisonCloudView.cloud_radius(99.0), PoisonClouds.RADIUS, "cloud_radius(99.0) ist RADIUS")


func test_zaehlen() -> void:
	var a := PoisonClouds.new()
	a.emit(Vector2.ZERO)
	var b := PoisonClouds.new()
	b.emit(Vector2(50, 0))
	b.cooldown = 0.0
	b.emit(Vector2(90, 0))
	var v := PoisonCloudView.new()
	v.sources = [a, b]
	check_eq(v.cloud_count(), 3, "cloud_count ist 3")
	v.free()


func test_leer() -> void:
	var v := PoisonCloudView.new()
	check_eq(v.cloud_count(), 0, "cloud_count ist 0 bei leerem View")
	v.free()
