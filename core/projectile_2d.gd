class_name Projectile2D

extends RefCounted

## Konstanten für die Trefferreaktion
const STOP := "stop"
const REMOVE := "remove"
const BOUNCE := "bounce"

## Aktuelle Position des Projektiles
var position := Vector2.ZERO

## Aktuelle Geschwindigkeit des Projektiles
var velocity := Vector2.ZERO

## Schwerkraft (nach +y in 2D)
var gravity := 9.81

## Lebensdauer des Projektiles
var lifetime := 5.0

## Aktuelles Alter des Projektiles
var age := 0.0

## Reaktion auf Treffer: STOP, REMOVE oder BOUNCE
var reaction := REMOVE

## Rückstoßkoeffizient für Rückprall (0 = kein Bounce, 1 = perfekt elastisch)
var restitution := 0.5

## Ob das Projektil noch aktiv ist
var alive := true

## Ob das Projektil gestoppt wurde
var stopped := false

## Array der getroffenen Wände
var hits: Array[Dictionary] = []

## Ein Schritt simuliert, zurückgegeben wird der Treffer dieses Schritts oder {}
func step(dt: float, walls: Array[Rect2]) -> Dictionary:
	# Keine Bewegung wenn nicht mehr alive oder bereits gestoppt
	if not alive or stopped:
		return {}

	age += dt
	# Lebensdauer überschritten
	if age > lifetime:
		alive = false
		return {}

	# Schwerkraft anwenden (nach +y in 2D)
	velocity.y += gravity * dt

	var target := position + velocity * dt

	# Ersten Treffer entlang der Strecke prüfen
	var hit: Dictionary = SweepHit.first_hit(position, target, walls)

	if hit.is_empty():
		# Kein Treffer → Position aktualisieren
		position = target
		return {}

	# Treffer gefunden → Eintrag an hits anhängen
	hits.append({
		"index": hit["index"],
		"position": hit["position"],
		"normal": hit["normal"],
		"velocity": velocity
	})

	# Reaktion ausführen
	match reaction:
		STOP:
			position = hit["position"]
			velocity = Vector2.ZERO
			stopped = true
		REMOVE:
			position = hit["position"]
			alive = false
		BOUNCE:
			velocity = SweepHit.reflect(velocity, hit["normal"], restitution)
			position = hit["position"] + hit["normal"] * 0.001

	return {
		"index": hit["index"],
		"position": hit["position"],
		"normal": hit["normal"],
		"velocity": velocity
	}

## Simulation über eine Dauer laufen lassen, gibt Anzahl der Treffer zurück
func run(duration: float, walls: Array[Rect2], hz: int = 120) -> int:
	var steps := roundi(duration * hz)
	for _i in steps:
		step(1.0 / hz, walls)
	return hits.size()
