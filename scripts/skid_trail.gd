extends RefCounted
class_name SkidTrail

## Mindestabstand zwischen zwei Punkten in px
const MIN_SEGMENT := 8.0
## Höchstens so viele Punkte über alle Spuren zusammen
const MAX_POINTS := 400

## Alle Spuren, die letzte ist die aktuelle
var trails: Array[PackedVector2Array] = []
## Ob gerade eine Spur aktiv ist (Punkte werden angehängt)
var is_trailing_active := false


func update(point: Vector2, marking: bool) -> void:
	if marking:
		if not is_trailing_active:
			# Neue Spur mit diesem einen Punkt anhängen
			var new_trail := PackedVector2Array()
			new_trail.append(point)
			trails.append(new_trail)
			is_trailing_active = true
		else:
			# Spur läuft bereits, Punkt nur anhängen wenn MIN_SEGMENT erreicht
			var trail_idx := trails.size() - 1
			var trail := trails[trail_idx]
			if trail.is_empty() or point.distance_to(trail[-1]) >= MIN_SEGMENT:
				trail.append(point)
				trails[trail_idx] = trail
	else:
		# Spur ist beendet, keine Punkte mehr anhängen
		is_trailing_active = false

	# Nach jedem Aufruf auf MAX_POINTS prüfen und überzählige entfernen
	_truncate_if_needed()


func _truncate_if_needed() -> void:
	var total := point_count()
	if total > MAX_POINTS:
		# Von der ältesten Spur Punkte entfernen, bis MAX_POINTS erreicht
		while total > MAX_POINTS and not trails.is_empty():
			var trail := trails[0]
			if trail.size() <= 1:
				# Spur hat nur 1 Punkt oder wird leer, ganz entfernen
				trails.remove_at(0)
			else:
				# Einen Punkt von der ältesten Spur entfernen (neu erstellen ohne erstes Element)
				var new_trail := PackedVector2Array()
				for i in range(1, trail.size()):
					new_trail.append(trail[i])
				trails[0] = new_trail
			total = point_count()

		# Leere Spuren entfernen
		while not trails.is_empty() and trails[0].is_empty():
			trails.remove_at(0)


func point_count() -> int:
	var count := 0
	for trail in trails:
		count += trail.size()
	return count


func clear() -> void:
	trails.clear()
	is_trailing_active = false
