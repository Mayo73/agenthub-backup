extends RefCounted
class_name PlatformerMotor

## Beschleunigung, Bremsen, Sprung und Schwerkraft für eine Jump-and-Run-Figur.
## Achsen wie im Projekt: +y ist unten, Schwerkraft 9,81.

## Maximale Laufgeschwindigkeit
var max_speed := 5.0
## Beschleunigung beim Laufen
var accel := 30.0
## Bremsverzögerung wenn keine Eingabe
var decel := 40.0
## Sprunggeschwindigkeit (negativ nach oben)
var jump_speed := 6.0
## Zeitfenster zum Springen nach Verlassen des Bodens (Nachsprungzeit)
var coyote_time := 0.1
## Zeitfenster zum Merken eines Sprungwegs vor der Landung
var buffer_time := 0.1
## Schwerkraftbeschleunigung nach unten
var gravity := 9.81

## Aktuelle Geschwindigkeit der Figur
var velocity := Vector2.ZERO
## Status: ob die Figur aktuell auf dem Boden ist
var on_floor := false
## Zeit seit letztem Bodenkontakt
var _since_floor := 999.0
## Zeit seit gedrücktem Sprungknopf
var _since_jump := 999.0


## Springen anstoßen – wird beim nächsten Schritt verwendet, wenn Nachsprungzeit erlaubt
func press_jump() -> void:
	_since_jump = 0.0


## Einen Physikschritt verarbeiten und neue Velocity zurückgeben.
## dir: horizontale Eingabe (-1 links, 0 nichts, 1 rechts)
## dt: Zeit seit letztem Schritt
## floor_now: ob die Figur in diesem Schritt auf dem Boden ist
func step(dir: float, dt: float, floor_now: bool) -> Vector2:
	## 1. Bodenzustand aktualisieren
	on_floor = floor_now
	if on_floor:
		_since_floor = 0.0
	else:
		_since_floor += dt

	## 2. Waagerecht beschleunigen/bremsen
	if dir != 0:
		velocity.x = move_toward(velocity.x, clampf(dir, -1, 1) * max_speed, accel * dt)
	else:
		velocity.x = move_toward(velocity.x, 0, decel * dt)

	## 3. Sprung, wenn Sprungknopf gedrückt (innerhalb buffer_time) und Nachsprungzeit erlaubt (coyote_time)
	if _since_jump <= buffer_time and _since_floor <= coyote_time:
		velocity.y = -jump_speed
		_since_jump = 999.0
		_since_floor = 999.0
	else:
		## 4. Schwerkraft anwenden
		if on_floor and velocity.y > 0:
			velocity.y = 0
		elif not on_floor:
			velocity.y += gravity * dt

	## 5. Sprungtimer erhöhen und Velocity zurückgeben
	_since_jump += dt
	return velocity
