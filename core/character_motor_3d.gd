## CharacterMotor3D – 3D-Bewegungslogik für eine spielersteuerte Figur
extends RefCounted
class_name CharacterMotor3D

## Maximale horizontale Laufgeschwindigkeit
var max_speed: float = 5.0

## Beschleunigung beim Laufen (m/s²)
var accel: float = 25.0

## Verzögerung beim Bremsen (m/s²)
var decel: float = 30.0

## Sprunggeschwindigkeit nach oben (m/s)
var jump_speed: float = 5.0

## Schwerkraft (m/s²), wirkt nach −y
var gravity: float = 9.81

## Aktuelle Geschwindigkeitsvektor
var velocity: Vector3 = Vector3.ZERO

## Ist die Figur am Boden?
var on_floor: bool = false


## Berechnet die gewünschte Bewegungsrichtung basierend auf Eingabe und Yaw-Winkel
## input.y ist vorwärts, input.x rechts
## Bei yaw=0 zeigt „vorne" in -z-Richtung, „rechts" in +x-Richtung
## Ergebnis ist normiert (Länge höchstens 1)
static func wish_direction(input: Vector2, yaw: float) -> Vector3:
	var vorne: Vector3 = Vector3(sin(yaw), 0.0, -cos(yaw))
	var rechts: Vector3 = Vector3(cos(yaw), 0.0, sin(yaw))
	var result: Vector3 = vorne * input.y + rechts * input.x
	return result.limit_length(1.0)


## Führt einen einzelnen Physik-Schritt aus und gibt die neue velocity zurück
## input: horizontale Eingabe (x=rechts, y=vorne)
## yaw: Yaw-Winkel der Figur in Radiant
## jump: true wenn springen ausgelöst wurde
## dt: Zeit seit dem letzten Schritt
## floor_now: true wenn Figur jetzt am Boden ist
func step(input: Vector2, yaw: float, jump: bool, dt: float, floor_now: bool) -> Vector3:
	## 1. Bodenzustand aktualisieren
	on_floor = floor_now

	## 2. Horizontale Bewegung berechnen
	var wish: Vector3 = wish_direction(input, yaw)
	var flat: Vector2 = Vector2(velocity.x, velocity.z)

	if input != Vector2.ZERO:
		var ziel: Vector2 = Vector2(wish.x, wish.z) * max_speed
		flat = flat.move_toward(ziel, accel * dt)
	else:
		flat = flat.move_toward(Vector2.ZERO, decel * dt)

	velocity.x = flat.x
	velocity.z = flat.y

	## 3. Vertikale Bewegung (Schwerkraft und Springen)
	if on_floor and jump:
		velocity.y = jump_speed
	elif on_floor:
		if velocity.y < 0.0:
			velocity.y = 0.0
	else:
		velocity.y -= gravity * dt

	return velocity


## Gibt die horizontale Geschwindigkeit zurück (Länge des horizontalen Anteils)
func horizontal_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()
