class_name CombatRules
extends RefCounted
## Regeln für Bisse zwischen Zellen.

const BITE_REACH := 4.0
## Grundschaden eines Bisses der Spielerzelle
const PLAYER_BITE := 20.0
const MEAT_PER_KILL := 3

## Ein-Biss-Regel: Beute mit höchstens SWALLOW_RATIO-mal so großem Radius wie der Angreifer
## wird mit einem Biss ganz verschluckt (bei den Größenabschnitten: mindestens zwei Abschnitte kleiner).
const SWALLOW_RATIO := 0.5


## Trifft der Biss? Nur das Maul zählt, nicht die Nähe der Körper.
static func bite_hits(attacker_pos: Vector2, attacker_heading: float, attacker_radius: float, target_pos: Vector2, target_radius: float) -> bool:
	var mouth := MouthContact.mouth_point(attacker_pos, attacker_heading, attacker_radius)
	return MouthContact.touches(mouth, BITE_REACH, target_pos, target_radius)


## Pflanzenfresser beißen nicht.
static func can_bite(diet: String) -> bool:
	return diet == Diet.FLEISCHFRESSER or diet == Diet.ALLESFRESSER


## Schaden mit der Größe skaliert: doppelt so große Angreifer beißen doppelt so stark (Faktor 0.5 bis 2).
static func bite_damage(base: float, attacker_radius: float, target_radius: float) -> float:
	return base * clampf(attacker_radius / target_radius, 0.5, 2.0)


## Lagen der Fleischbrocken einer besiegten Zelle, gleichmäßig im Kreis um center.
static func meat_positions(center: Vector2, radius: float, count: int = MEAT_PER_KILL) -> Array[Vector2]:
	var result: Array[Vector2] = []
	for i in count:
		result.append(center + Vector2.from_angle(TAU * i / count) * radius * 0.5)
	return result


## Ist die Beute deutlich kleiner, sodass ein Biss sie ganz verschluckt?
static func can_swallow(attacker_radius: float, target_radius: float) -> bool:
	return target_radius <= attacker_radius * SWALLOW_RATIO


## Nahrungswert einer verschluckten Zelle: so viel wie ihre Fleischbrocken zusammen.
static func swallow_value() -> int:
	return MEAT_PER_KILL * FoodField.MEAT_VALUE
