extends RefCounted
class_name Projectile3D

## Hit-Verhalten nach einem Treffer
const STOP := "stop"
const REMOVE := "remove"
const BOUNCE := "bounce"

var position := Vector3.ZERO
var velocity := Vector3.ZERO
var gravity := 9.81
var lifetime := 5.0
var age := 0.0
var on_hit := STOP
var restitution := 0.5
var alive := true
var stopped := false
var hits: Array[Dictionary] = []

## Simuliert einen Zeitschritt des Projektils und prüft auf Kollisionen mit Quadern.
## dt: Zeitschritt in Sekunden
## boxes: Array von AABBs (Quadern) zur Kollisionsprüfung
## Zurück: bei Treffer {"index": int, "position": Vector3, "normal": Vector3, "age": float}, sonst {}
func step(dt: float, boxes: Array[AABB]) -> Dictionary:
	if not alive or stopped:
		return {}

	age += dt
	if age >= lifetime:
		alive = false
		return {}

	## Neue Geschwindigkeit unter Schwerkraft (−y in 3D)
	var v: Vector3 = velocity + Vector3(0, -gravity, 0) * dt
	var to: Vector3 = position + v * dt

	## Trefferprüfung mit SweepHit3D
	var hit: Dictionary = SweepHit3D.first_hit(position, to, boxes)

	if hit.is_empty():
		## Kein Treffer – einfach bewegen
		position = to
		velocity = v
		return {}
	else:
		## Treffer erfolgt – Eintrag zu hits hinzufügen
		var hit_entry: Dictionary = {
			"index": hit.get("index", -1),
			"position": hit.get("position", Vector3.ZERO),
			"normal": hit.get("normal", Vector3.ZERO),
			"age": age
		}
		hits.append(hit_entry)

		match on_hit:
			STOP:
				position = hit_entry["position"]
				velocity = Vector3.ZERO
				stopped = true
			REMOVE:
				position = hit_entry["position"]
				alive = false
			BOUNCE:
				velocity = SweepHit3D.reflect(v, hit.get("normal", Vector3.ZERO), restitution)
				position = hit_entry["position"] + hit.get("normal", Vector3.ZERO) * 0.001

		return hit_entry

## Simuliert das Projektil über eine Dauer hinweg und gibt die Anzahl der Treffer zurück.
## duration: Gesamtdauer der Simulation in Sekunden
## boxes: Array von AABBs zur Kollisionsprüfung
## hz: Schrittgeschwindigkeit (Schritte pro Sekunde), Standard 120
## Zurück: Anzahl der registrierten Treffer
func run(duration: float, boxes: Array[AABB], hz: int = 120) -> int:
	var steps: int = roundi(duration * hz)
	for _i in steps:
		step(1.0 / hz, boxes)
	return hits.size()
