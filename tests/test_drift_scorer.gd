extends "res://tests/base_test.gd"

var scorer: DriftScorer


func setup() -> void:
	scorer = DriftScorer.new()


func test_kleiner_winkel_ist_kein_drift() -> void:
	for i in range(10):
		scorer.update(0.1, 5.0, 400.0, true)
	check_eq(scorer.current, 0.0, "current sollte bei 0 bleiben bei kleinem Winkel")


func test_drift_sammelt_punkte() -> void:
	for i in range(10):
		scorer.update(0.1, 30.0, 400.0, true)
	check_eq(scorer.current, 120.0, "current sollte 120.0 betragen (30*400*0.1/100*10)")


func test_punkte_werden_nach_pause_gesichert() -> void:
	# 10 Schritte Drift
	for i in range(10):
		scorer.update(0.1, 30.0, 400.0, true)
	check_eq(scorer.current, 120.0, "current sollte 120.0 sein")

	# 20 Schritte Pause (Winkel=0)
	for i in range(20):
		scorer.update(0.1, 0.0, 400.0, true)

	check_eq(scorer.total, 120, "total sollte 120 sein (current * combo)")
	check_eq(scorer.current, 0.0, "current sollte 0 sein")


func test_kombo_steigt_bei_kettendrift() -> void:
	# 10 Schritte Drift
	for i in range(10):
		scorer.update(0.1, 30.0, 400.0, true)
	check_eq(scorer.current, 120.0, "current sollte 120.0 sein")

	# 5 Schritte Pause (Winkel=0), _pause_seconds = 0.5s < 1.5s
	for i in range(5):
		scorer.update(0.1, 0.0, 400.0, true)

	# 10 Schritte Drift (Kombo steigt auf 2, da _pause_seconds=0.5 < 1.5)
	for i in range(10):
		scorer.update(0.1, 30.0, 400.0, true)
	check_eq(scorer.combo, 2, "combo sollte 2 sein")

	# 20 Schritte Pause (Winkel=0), CHAIN_TIME=1.5s wird erreicht
	for i in range(20):
		scorer.update(0.1, 0.0, 400.0, true)

	check_eq(scorer.total, 480, "total sollte 480 sein (120+120)*2 = 480")


func test_abflug_loescht_drift() -> void:
	# 10 Schritte Drift
	for i in range(10):
		scorer.update(0.1, 30.0, 400.0, true)
	check_eq(scorer.current, 120.0, "current sollte 120.0 sein")

	# Abflug: on_track = false
	scorer.update(0.1, 30.0, 400.0, false)

	check_eq(scorer.current, 0.0, "current sollte 0 sein nach Abflug")
	check_eq(scorer.combo, 1, "combo sollte auf 1 resetten")
	check_eq(scorer.total, 0, "total sollte 0 bleiben (Drift verloren)")


func test_signal_meldet_gesicherte_punkte() -> void:
	var banked := []
	scorer.drift_banked.connect(func(points: int) -> void: banked.append(points))
	for round_number in 2:
		for i in range(10):
			scorer.update(0.1, 30.0, 400.0, true)
		for i in range(20):
			scorer.update(0.1, 0.0, 400.0, true)
	check_eq(banked, [120, 120], "jedes Signal meldet nur die gerade gesicherten Punkte")
	check_eq(scorer.total, 240)
