extends CanvasLayer
## Anzeige über dem Spiel: Tempo, Driftwinkel und Drift-Hinweis.
## Punkte, Kombo und Rundenzeiten haben schon Labels und werden später angebunden.

## Umrechnung Pixel pro Sekunde -> angezeigte km/h (nur für die Anzeige).
const PX_PER_KMH := 4.0

@onready var speed_label: Label = $Speed
@onready var angle_label: Label = $Angle
@onready var drift_label: Label = $Drift
@onready var score_label: Label = $Score
@onready var combo_label: Label = $Combo
@onready var lap_label: Label = $Lap
@onready var time_label: Label = $Time
@onready var best_label: Label = $Best


func show_car(car: CarPhysics) -> void:
	speed_label.text = "%d km/h" % roundi(car.speed() / PX_PER_KMH)
	angle_label.text = "Winkel %d°" % roundi(absf(car.slip_angle_deg()))
	drift_label.visible = car.is_drifting()


func show_score(scorer: DriftScorer) -> void:
	score_label.text = "Punkte %d" % scorer.total
	if scorer.current > 0.0:
		combo_label.text = "+%d  x%d" % [roundi(scorer.current), scorer.combo]
	else:
		combo_label.text = ""


func show_laps(timer: LapTimer) -> void:
	lap_label.text = "Runde %d" % (timer.lap + 1)
	time_label.text = "Zeit " + LapTimer.format_time(timer.current_time)
	best_label.text = "Beste " + LapTimer.format_time(timer.best_lap_time)
