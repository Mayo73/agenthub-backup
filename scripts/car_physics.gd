class_name CarPhysics
extends RefCounted
## Fahrphysik eines Driftautos in Weltkoordinaten (von oben gesehen, y zeigt nach unten).
## Reine Rechnung ohne Nodes, damit sie sich testen lässt: Eingaben setzen, dann step(delta).
##
## Kernidee: Die Geschwindigkeit wird zerlegt in einen Anteil entlang der Fahrzeugachse und
## einen seitlichen Anteil. Die Reifen bauen den seitlichen Anteil ab (Grip). Verlangt eine Kurve
## mehr Querbeschleunigung, als die Reifen hergeben (oder ist die Handbremse gezogen), reißt die
## Haftung ab: Der Grip wird klein, das Auto driftet.

enum Surface { ROAD, GRASS }

## Ab diesem Schräglaufwinkel (Grad) und Tempo (px/s) zählt das Rutschen als Drift.
const DRIFT_MIN_ANGLE := 12.0
const DRIFT_MIN_SPEED := 150.0

# --- Abstimmung (Pixel und Sekunden) -----------------------------------------
var engine_accel := 520.0       # Beschleunigung bei Vollgas (px/s²)
var max_speed := 760.0          # Höchsttempo auf Asphalt (px/s)
var reverse_max_speed := 220.0  # Höchsttempo rückwärts (px/s)
var brake_decel := 900.0        # Bremsverzögerung (px/s²)
var rolling_drag := 0.35        # Rollwiderstand (Anteil pro Sekunde)
var slide_drag := 0.8          # Rutschen kostet Tempo: mal sin(Schräglauf), nur im Drift (pro Sekunde)
var grip := 30.0                # Seitenhaftung mit greifenden Reifen (1/s)
var slide_grip := 1.6           # Seitenhaftung im Drift (1/s)
var handbrake_grip := 0.6       # Seitenhaftung mit gezogener Handbremse (1/s)
var traction_limit := 1400.0    # Mehr Querbeschleunigung halten die Reifen nicht (px/s²)
var traction_recover := 60.0    # Unter dieser Seitwärtsgeschwindigkeit greifen sie wieder (px/s)
var steer_rate := 2.6           # Drehrate bei voller Lenkung (rad/s)
var full_steer_speed := 250.0   # Ab diesem Tempo wirkt die Lenkung voll (px/s)
var drift_steer_bonus := 1.4    # Lenken wirkt im Drift stärker (Gegenlenken)
var power_oversteer := 1.1      # Gas im Drift dreht das Heck weiter heraus (rad/s)
var max_slip_angle := 70.0      # Darüber dreht das Auto nur noch zögerlich weiter ein (Grad)
var grass_drag := 2.0           # Zusätzlicher Widerstand auf Gras (Anteil pro Sekunde)
var grass_grip_factor := 0.5    # Auf Gras: Haftung mal diesem Faktor
var grass_max_speed := 300.0    # Höchsttempo auf Gras (px/s)

# --- Zustand -------------------------------------------------------------------
var position := Vector2.ZERO
var heading := 0.0              # Fahrzeugrichtung in rad, 0 = Welt-x
var velocity := Vector2.ZERO
var sliding := false            # Haftung abgerissen?
var surface := Surface.ROAD

# --- Eingaben, vor jedem step() setzen ----------------------------------------
var throttle := 0.0             # 0 .. 1
var brake := 0.0                # 0 .. 1, im Stand: rückwärts
var steer := 0.0                # -1 (links) .. 1 (rechts)
var handbrake := false


func forward() -> Vector2:
	return Vector2.from_angle(heading)


## Rechts vom Auto (y zeigt nach unten, also im Uhrzeigersinn gedreht).
func right() -> Vector2:
	return Vector2.from_angle(heading + PI / 2.0)


func speed() -> float:
	return velocity.length()


func forward_speed() -> float:
	return velocity.dot(forward())


func lateral_speed() -> float:
	return velocity.dot(right())


## Winkel zwischen Fahrzeugachse und Bewegungsrichtung in Grad (positiv: rutscht nach rechts).
func slip_angle_deg() -> float:
	if speed() < 30.0:
		return 0.0
	return rad_to_deg(atan2(lateral_speed(), absf(forward_speed())))


func is_drifting() -> bool:
	return sliding and absf(slip_angle_deg()) >= DRIFT_MIN_ANGLE and speed() >= DRIFT_MIN_SPEED


func step(delta: float) -> void:
	var fwd := forward()
	var rgt := right()
	var v_fwd := velocity.dot(fwd)
	var v_lat := velocity.dot(rgt)
	var on_grass := surface == Surface.GRASS

	# Lenken wirkt erst mit Tempo, rückwärts andersherum.
	var steer_factor := clampf(absf(v_fwd) / full_steer_speed, 0.0, 1.0) * signf(v_fwd)
	var turn := steer * steer_rate * steer_factor

	# Haftung reißt ab, wenn die Kurve mehr Querbeschleunigung verlangt, als die Reifen halten.
	# Sie greift erst wieder, wenn kaum noch etwas rutscht (Abstand der Schwellen gegen Flackern).
	var limit := traction_limit * (grass_grip_factor if on_grass else 1.0)
	var demand := absf(v_fwd * turn)
	if handbrake and absf(v_fwd) > 80.0:
		sliding = true
	elif sliding and absf(v_lat) < traction_recover and demand < limit * 0.8:
		sliding = false
	elif not sliding and demand > limit:
		sliding = true

	# Gas und Bremse wirken entlang der Fahrzeugachse.
	var top := grass_max_speed if on_grass else max_speed
	if throttle > 0.0 and v_fwd < top:
		v_fwd = minf(v_fwd + engine_accel * throttle * delta, top)
	if brake > 0.0:
		if v_fwd > 20.0:
			v_fwd = maxf(v_fwd - brake_decel * brake * delta, 0.0)
		else:
			v_fwd = maxf(v_fwd - engine_accel * 0.5 * brake * delta, -reverse_max_speed)
	if handbrake:
		v_fwd = move_toward(v_fwd, 0.0, brake_decel * 0.3 * delta)

	# Die Reifen bauen das Seitwärtsrutschen ab.
	var lateral_grip := handbrake_grip if handbrake else (slide_grip if sliding else grip)
	if on_grass:
		lateral_grip *= grass_grip_factor
	v_lat *= exp(-lateral_grip * delta)

	# Roll- und Graswiderstand; im Drift zusätzlich je nach Winkel. So kostet ein weiter
	# Drift Rundenzeit, bringt aber mehr Punkte: Das ist die Abwägung im Spiel.
	var drag := rolling_drag + (grass_drag if on_grass else 0.0)
	if sliding:
		drag += slide_drag * absf(sin(atan2(v_lat, absf(v_fwd))))
	v_fwd *= exp(-drag * delta)

	if sliding:
		turn *= drift_steer_bonus
		turn -= power_oversteer * throttle * signf(v_lat)
		# Über max_slip_angle dreht das Auto nur noch zögerlich weiter ein (kein ständiger Dreher).
		var slip := rad_to_deg(atan2(v_lat, absf(v_fwd)))
		if absf(slip) > max_slip_angle and signf(turn) == -signf(v_lat):
			turn *= 0.25
	heading = wrapf(heading + turn * delta, -PI, PI)

	velocity = fwd * v_fwd + rgt * v_lat
	position += velocity * delta
