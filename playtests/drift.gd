extends "res://playtests/_drift.gd"
## Driften mit Handbremse in den Kurven: Rauch, Reifenspuren und Drift-Punkte.


func describe() -> String:
	return "Driften mit Handbremse: Rauch, Reifenspuren und Drift-Punkte (Bildstreifen „drift“)"


func run() -> void:
	if not await wait_for_start():
		return
	autopilot = true
	drift_in_curves = true
	if not await until(func() -> bool: return scene.car.physics.is_drifting(), 60.0, "Das Auto driftet"):
		return
	measure("driftwinkel", roundi(absf(scene.car.physics.slip_angle_deg())))
	check(scene.car.smoke.emitting, "Beim Driften kommt Reifenrauch")
	await film("drift", 1.5)
	await wait(2.0)
	shot("spuren")
	var marks: int = scene.skid_marks.left.point_count() + scene.skid_marks.right.point_count()
	measure("spurpunkte", marks)
	check(marks > 0, "Nach dem Drift sind Reifenspuren zu sehen")
	await until(func() -> bool: return scene.scorer.total > 0, 20.0, "Drift bringt Punkte")
	measure("punkte", scene.scorer.total)
	stop_driving()
