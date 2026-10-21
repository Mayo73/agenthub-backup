## FollowCamera2D – 2D-Kamera mit Totzone, Grenzen und weicher Bewegung
extends RefCounted
class_name FollowCamera2D

## Mitte des Bildes (Position der Kamera)
var position: Vector2 = Vector2.ZERO

## Sichtbarer Bereich in Einheiten
var view_size: Vector2 = Vector2(20.0, 11.25)

## Halbe Breite/Höhe der Totzone um die Mitte
var dead_zone: Vector2 = Vector2(2.0, 1.5)

## Glättungsrate pro Sekunde (0 = sofortige Bewegung)
var smoothing: float = 8.0

## Grenzen als Rechteck (leer = keine Grenzen)
var bounds: Rect2 = Rect2()


## Berechnet das gewünschte Ziel für den target basierend auf der Totzone
## Wenn target innerhalb der Totzone ist, bleibt die Achse unverändert
## Sonst liegt target genau am Rand der Totzone um position
func desired(target: Vector2) -> Vector2:
	var result: Vector2 = position

	## Berechne wo position sein muss damit target AM RAND der Totzone liegt
	if target.x >= position.x - dead_zone.x and target.x <= position.x + dead_zone.x:
		result.x = position.x
	elif target.x < position.x:
		result.x = target.x + dead_zone.x
	else:
		result.x = target.x - dead_zone.x

	if target.y >= position.y - dead_zone.y and target.y <= position.y + dead_zone.y:
		result.y = position.y
	elif target.y < position.y:
		result.y = target.y + dead_zone.y
	else:
		result.y = target.y - dead_zone.y

	return result


## Klemmt position so an die Grenzen, dass das sichtbare Rechteck (Mitte p, Größe view_size)
## vollständig innerhalb von bounds liegt. Bei leeren Grenzen unverändert.
## Ist bounds kleiner als view_size in einer Achse, wird die Mitte von bounds verwendet.
func clamp_to_bounds(p: Vector2) -> Vector2:
	if bounds.size.is_equal_approx(Vector2.ZERO):
		return p

	var half_view: Vector2 = view_size * 0.5
	var half_bounds: Vector2 = bounds.size * 0.5

	if half_bounds.x < half_view.x or half_bounds.y < half_view.y:
		return bounds.position + half_bounds

	var result: Vector2 = p

	var min_x: float = bounds.position.x + half_view.x
	var max_x: float = bounds.end.x - half_view.x
	result.x = clampf(result.x, min_x, max_x)

	var min_y: float = bounds.position.y + half_view.y
	var max_y: float = bounds.end.y - half_view.y
	result.y = clampf(result.y, min_y, max_y)

	return result


## Aktualisiert die Kamera-Position und gibt die neue Position zurück
func update(target: Vector2, dt: float) -> Vector2:
	var ziel: Vector2 = clamp_to_bounds(desired(target))

	if smoothing <= 0.0:
		position = ziel
	else:
		var factor: float = clampf(smoothing * dt, 0.0, 1.0)
		position = position.lerp(ziel, factor)

	return position


## Gibt das sichtbare Rechteck zurück (Mitte position, Größe view_size)
func visible_rect() -> Rect2:
	return Rect2(position - view_size * 0.5, view_size)


## Serialisiert den aktuellen Zustand in ein Dictionary
func to_dict() -> Dictionary:
	var bounds_dict: Dictionary = {}
	if not bounds.size.is_equal_approx(Vector2.ZERO):
		bounds_dict = {
			"position_x": bounds.position.x,
			"position_y": bounds.position.y,
			"size_x": bounds.size.x,
			"size_y": bounds.size.y
		}
	return {
		"position": position,
		"view_size": view_size,
		"dead_zone": dead_zone,
		"smoothing": smoothing,
		"bounds": bounds_dict
	}


## Erstellt eine neue FollowCamera2D aus einem Dictionary
static func from_dict(d: Dictionary) -> FollowCamera2D:
	var cam: FollowCamera2D = FollowCamera2D.new()
	cam.position = d.get("position", Vector2.ZERO)
	cam.view_size = d.get("view_size", Vector2(20.0, 11.25))
	cam.dead_zone = d.get("dead_zone", Vector2(2.0, 1.5))
	cam.smoothing = float(d.get("smoothing", 8.0))
	cam.bounds = Rect2()

	var bounds_data: Dictionary = d.get("bounds", {})
	if bounds_data.size() > 0:
		cam.bounds = Rect2(
			Vector2(float(bounds_data.get("position_x", 0.0)), float(bounds_data.get("position_y", 0.0))),
			Vector2(float(bounds_data.get("size_x", 0.0)), float(bounds_data.get("size_y", 0.0)))
		)

	return cam
