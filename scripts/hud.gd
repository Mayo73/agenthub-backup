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
