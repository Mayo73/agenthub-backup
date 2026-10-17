class_name FishThreat
extends RefCounted
## Warnung vor Raubfischen in der Nähe des Spielerfischs.

## Bis zu diesem Abstand in Metern warnt die Anzeige.
const WARN_DIST := 15.0


## Abstand zum nächsten Raubfisch; INF, wenn keiner da ist. fishes: Knoten mit species_id und motion (AiFish).
static func nearest_predator(player_pos: Vector3, fishes: Array) -> float:
	var best := INF
	for f in fishes:
		if FishSpecies.is_predator(f.species_id):
			best = minf(best, player_pos.distance_to(f.motion.position))
	return best


static func is_warning(distance: float) -> bool:
	return distance <= WARN_DIST


## Leerer Text, wenn kein Raubfisch nah genug ist.
static func warning_text(distance: float) -> String:
	if not is_warning(distance):
		return ""
	return "Vorsicht: Raubfisch in %d m!" % roundi(distance)
