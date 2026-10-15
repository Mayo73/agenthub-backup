extends CanvasLayer
## Anzeige über dem Spiel: Tempo, Driftwinkel und Drift-Hinweis.
## Punkte, Kombo und Rundenzeiten haben schon Labels und werden später angebunden.

## Umrechnung Pixel pro Sekunde -> angezeigte km/h (nur für die Anzeige).
const PX_PER_KMH := 4.0

signal again_pressed
signal menu_pressed

@onready var speed_label: Label = $Speed
@onready var angle_label: Label = $Angle
@onready var drift_label: Label = $Drift
@onready var score_label: Label = $Score
@onready var combo_label: Label = $Combo
@onready var lap_label: Label = $Lap
@onready var time_label: Label = $Time
@onready var best_label: Label = $Best
@onready var countdown_label: Label = $Countdown
@onready var result_label: Label = $Result
@onready var result_buttons: HBoxContainer = $ResultButtons
@onready var again_button: Button = $ResultButtons/Again
@onready var menu_button: Button = $ResultButtons/Menu

func _ready() -> void:
	again_button.pressed.connect(again_pressed.emit)
	menu_button.pressed.connect(menu_pressed.emit)


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
	lap_label.text = "Runde %d/%d" % [mini(timer.lap + 1, RaceState.TOTAL_LAPS), RaceState.TOTAL_LAPS]
	time_label.text = "Zeit " + LapTimer.format_time(timer.current_time)
	best_label.text = "Beste " + LapTimer.format_time(timer.best_lap_time)


func show_race(race: RaceState, points: int, new_time: bool = false, new_points: bool = false) -> void:
	countdown_label.text = race.countdown_text()
	var finished := race.phase == RaceState.Phase.FINISHED
	if finished and not result_buttons.visible:
		again_button.grab_focus()
	result_buttons.visible = finished
	result_label.visible = finished
	if finished:
		result_label.text = race.result_text(points, new_time, new_points)
