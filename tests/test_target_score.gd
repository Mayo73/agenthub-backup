extends "res://tests/base_test.gd"

var target: TargetScore


func setup() -> void:
	target = TargetScore.new(1.0, 10)


func teardown() -> void:
	target = null


## Test aus der Spezifikation: Mitte ergibt Ring 10, nahe Mitte ebenfalls, weiter weg Ring 9
func test_mitte() -> void:
	check_eq(target.ring_for(0.0), 10, "Mitte (0.0) ist Ring 10")
	check_eq(target.ring_for(0.05), 10, "nahe Mitte (0.05) ist Ring 10")
	check_eq(target.ring_for(0.15), 9, "weiter (0.15) ist Ring 9")


## Test aus der Spezifikation: Rand und daneben
func test_rand() -> void:
	check_eq(target.ring_for(1.0), 1, "exakter Rand (1.0) ist Ring 1")
	check_eq(target.ring_for(1.01), 0, "daneben (1.01) ist 0")


## Test aus der Spezifikation: Treffer erfassen und auswerten
func test_treffer() -> void:
	# Vector2(5, 5) zu (5, 5.25): dist = 0.25, ring_for(0.25) mit radius=1.0, rings=10
	# d = 0.25 / 1.0 * 10 = 2.5, floori(2.5)=2, ring = 10 - 2 = 8
	check_eq(target.hit_2d(Vector2(5, 5), Vector2(5, 5.25)), 8, "2D Treffer bei dist=0.25 gibt Ring 8")
	# Vector3.ZERO zu (0,0,2): dist = 2.0 > radius=1.0 → 0
	check_eq(target.hit_3d(Vector3.ZERO, Vector3(0, 0, 2)), 0, "3D Treffer daneben gibt Ring 0")
	# hits = [8, 0]
	check_eq(target.total(), 8, "Summe der Treffer ist 8")
	# average = (8+0)/2 = 4.0
	check_eq(target.average(), 4.0, "Durchschnitt ist 4.0")


## Test aus der Spezifikation: Zurücksetzen leert hits
func test_zuruecksetzen() -> void:
	target.reset()
	check_eq(target.total(), 0, "total nach reset ist 0")
	check_eq(target.average(), 0.0, "average nach reset ist 0.0")
