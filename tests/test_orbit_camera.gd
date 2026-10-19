extends "res://tests/base_test.gd"

var cam: OrbitCamera

func setup() -> void:
	cam = OrbitCamera.new()

func test_vorne() -> void:
	cam.pitch = 0.0
	var pos: Vector3 = cam.position()
	check_eq(pos.x, 0.0, "x bei yaw=0, pitch=0")
	check_eq(pos.y, 0.0, "y bei yaw=0, pitch=0")
	check_eq(pos.z, 6.0, "z bei yaw=0, pitch=0")

func test_seite() -> void:
	cam.pitch = 0.0
	cam.yaw = 90.0
	var pos: Vector3 = cam.position()
	check_eq(pos.x, 6.0, "x bei yaw=90, pitch=0")
	check_eq(pos.y, 0.0, "y bei yaw=90, pitch=0")
	check_eq(pos.z, 0.0, "z bei yaw=90, pitch=0")

func test_oben() -> void:
	cam.pitch = 89.0
	var pos: Vector3 = cam.position()
	check(pos.y > 5.99, "pitch=89 ergibt position().y > 5.99")

func test_grenzen() -> void:
	# pitch begrenzen
	cam.pitch = 0.0
	cam.orbit(0.0, 500.0)
	check_eq(cam.pitch, 89.0, "pitch wird auf MAX_PITCH=89 geklammert")

	# yaw modulo 360
	cam.yaw = 0.0
	cam.orbit(40.0, 0.0)
	check_eq(cam.yaw, 40.0, "yaw wird mit fposmod auf 0-360 begrenzt")

	# distance begrenzen
	cam.distance = 1.0
	cam.zoom(1000.0)
	check_eq(cam.distance, 500.0, "distance wird auf MAX_DISTANCE=500 geklammert")

	# factor <= 0 ignorieren
	var dist_before: float = cam.distance
	cam.zoom(-1.0)
	check_eq(cam.distance, dist_before, "zoom(-1) ändert distance nicht")

func test_ziel() -> void:
	cam.pan(Vector3(1.0, 2.0, 3.0))
	cam.pitch = 0.0
	var pos: Vector3 = cam.position()
	check_eq(pos.x, 1.0, "x nach pan bei yaw=0, pitch=0")
	check_eq(pos.y, 2.0, "y nach pan bei yaw=0, pitch=0")
	check_eq(pos.z, 9.0, "z nach pan bei yaw=0, pitch=0 (3+6)")

func test_speichern() -> void:
	cam.yaw = 45.0
	var saved: OrbitCamera = OrbitCamera.from_dict(cam.to_dict())
	check_eq(saved.yaw, 45.0, "yaw wird über to_dict/from_dict gespeichert")
