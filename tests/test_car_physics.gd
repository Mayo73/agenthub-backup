extends "res://tests/base_test.gd"
## Diese Tests halten das gewünschte Fahrgefühl fest. Schlägt einer nach einer Änderung
## an der Abstimmung fehl, fühlt sich das Auto anders an als vereinbart.

const DT := 1.0 / 60.0

var car: CarPhysics


func setup() -> void:
	car = CarPhysics.new()


## Simuliert eine Zeit lang mit den aktuell gesetzten Eingaben.
func drive(seconds: float) -> void:
	for i in roundi(seconds / DT):
		car.step(DT)


func test_gas_beschleunigt_geradeaus() -> void:
	car.throttle = 1.0
	drive(1.0)
	check(car.forward_speed() > 300.0, "Tempo nach 1 s Vollgas: %.0f" % car.forward_speed())
	check(absf(car.position.y) < 0.01, "fährt geradeaus")
	check_eq(car.heading, 0.0, "Richtung unverändert")


func test_hoechstgeschwindigkeit() -> void:
	car.throttle = 1.0
	drive(10.0)
	check(car.speed() <= car.max_speed, "nicht schneller als max_speed: %.0f" % car.speed())
	check(car.speed() > car.max_speed * 0.95, "erreicht fast max_speed: %.0f" % car.speed())


func test_bremsen_staerker_als_ausrollen() -> void:
	var coasting := CarPhysics.new()
	coasting.velocity = Vector2(500, 0)
	car.velocity = Vector2(500, 0)
	car.brake = 1.0
	for i in 18:
		car.step(DT)
		coasting.step(DT)
	check(car.speed() < coasting.speed() - 200.0, "Bremse %.0f vs. Ausrollen %.0f" % [car.speed(), coasting.speed()])


func test_rueckwaerts_aus_dem_stand() -> void:
	car.brake = 1.0
	drive(2.0)
	check(car.forward_speed() < -100.0, "fährt rückwärts: %.0f" % car.forward_speed())
	check(car.forward_speed() >= -car.reverse_max_speed - 0.01, "nicht schneller als reverse_max_speed")


func test_im_stand_dreht_lenken_nicht() -> void:
	car.steer = 1.0
	drive(1.0)
	check_eq(car.heading, 0.0, "Richtung im Stand")


func test_lenken_rechts_dreht_im_uhrzeigersinn() -> void:
	car.velocity = Vector2(400, 0)
	car.throttle = 0.5
	car.steer = 1.0
	drive(0.5)
	check(car.heading > 0.3, "Richtung nach 0,5 s: %.2f rad" % car.heading)


func test_moderates_tempo_haftet_beim_lenken() -> void:
	car.velocity = Vector2(300, 0)
	car.throttle = 0.3
	car.steer = 1.0
	drive(1.0)
	check(not car.sliding, "bei 300 px/s greifen die Reifen")
	check(absf(car.slip_angle_deg()) < CarPhysics.DRIFT_MIN_ANGLE, "Schräglauf klein: %.1f°" % car.slip_angle_deg())


func test_scharfes_lenken_bei_hohem_tempo_bricht_aus() -> void:
	car.velocity = Vector2(720, 0)
	car.throttle = 1.0
	car.steer = 1.0
	var slid := false
	for i in 60:
		car.step(DT)
		slid = slid or car.sliding
	check(slid, "Haftung reißt bei vollem Einlenken mit hohem Tempo ab")


func test_handbremse_loest_drift_aus() -> void:
	car.velocity = Vector2(600, 0)
	car.steer = 1.0
	car.handbrake = true
	drive(0.4)
	check(car.sliding, "rutscht")
	check(car.is_drifting(), "zählt als Drift (Winkel %.1f°, Tempo %.0f)" % [car.slip_angle_deg(), car.speed()])


func test_gegenlenken_faengt_drift_ab() -> void:
	car.velocity = Vector2(600, 0)
	car.steer = 1.0
	car.handbrake = true
	drive(0.4)
	car.handbrake = false
	# Wie ein Spieler: in die Rutschrichtung gegenlenken, bis das Auto wieder geradeaus zeigt.
	for i in 120:
		car.steer = clampf(car.slip_angle_deg() / 20.0, -1.0, 1.0)
		car.step(DT)
	check(not car.sliding, "Reifen greifen wieder (Schräglauf %.1f°)" % car.slip_angle_deg())


func test_schraeglauf_bleibt_begrenzt() -> void:
	car.velocity = Vector2(700, 0)
	car.throttle = 1.0
	car.steer = 1.0
	car.handbrake = true
	var worst := 0.0
	for i in 90:
		car.step(DT)
		worst = maxf(worst, absf(car.slip_angle_deg()))
	check(worst < 100.0, "kein Dreher nach hinten (größter Schräglauf %.0f°)" % worst)


func test_weiter_drift_kostet_tempo() -> void:
	var results := {}
	for target in [20.0, 45.0]:
		car = CarPhysics.new()
		car.velocity = Vector2(600, 0)
		car.steer = 1.0
		car.handbrake = true
		drive(0.3)
		car.handbrake = false
		car.throttle = 1.0
		# Den Drift mit der Lenkung auf dem Zielwinkel halten
		for i in 180:
			car.steer = clampf((target - absf(car.slip_angle_deg())) / 10.0, -1.0, 1.0)
			car.step(DT)
		results[target] = car.forward_speed()
	check(results[45.0] < results[20.0] - 100.0, "45°-Drift %.0f px/s vs. 20°-Drift %.0f px/s" % [results[45.0], results[20.0]])


func test_gras_bremst_staerker() -> void:
	var on_road := CarPhysics.new()
	on_road.velocity = Vector2(600, 0)
	car.velocity = Vector2(600, 0)
	car.surface = CarPhysics.Surface.GRASS
	for i in 60:
		car.step(DT)
		on_road.step(DT)
	check(car.speed() < on_road.speed() - 150.0, "Gras %.0f vs. Asphalt %.0f" % [car.speed(), on_road.speed()])


func test_gleiche_eingaben_gleiches_ergebnis() -> void:
	var other := CarPhysics.new()
	for c in [car, other]:
		c.throttle = 1.0
		c.steer = 0.6
		c.handbrake = true
	for i in 90:
		car.step(DT)
		other.step(DT)
	check_eq(car.position, other.position, "deterministisch")
