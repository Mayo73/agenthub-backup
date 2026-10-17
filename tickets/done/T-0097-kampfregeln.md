---
id: T-0097
title: Kampfregeln (CombatRules)
project: zellenphase
priority: 4
after: T-0087
---
## Ziel
Ein Biss trifft nur, wenn das Maul des Angreifers die andere Zelle berührt; bloße Nähe der Körper reicht nicht. Größere Angreifer beißen stärker. Besiegte Zellen hinterlassen Fleischbrocken.

## Dateien
- `scripts/combat_rules.gd`: neu
- `tests/test_combat_rules.gd`: neu

## Akzeptanzkriterien
`scripts/combat_rules.gd` genau so:
```gdscript
class_name CombatRules
extends RefCounted
## Regeln für Bisse zwischen Zellen.

const BITE_REACH := 4.0
## Grundschaden eines Bisses der Spielerzelle
const PLAYER_BITE := 20.0
const MEAT_PER_KILL := 3


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
```

## Tests
`tests/test_combat_rules.gd` mit `extends "res://tests/base_test.gd"`:
- `test_biss_vorn`: `CombatRules.bite_hits(Vector2.ZERO, 0.0, 10.0, Vector2(20, 0), 8.0)` wahr
- `test_biss_hinten_trifft_nicht`: `CombatRules.bite_hits(Vector2.ZERO, 0.0, 10.0, Vector2(-20, 0), 8.0)` falsch (gleicher Körperabstand wie oben)
- `test_biss_zu_weit`: `CombatRules.bite_hits(Vector2.ZERO, 0.0, 10.0, Vector2(30, 0), 8.0)` falsch
- `test_wer_beisst`: `can_bite(Diet.FLEISCHFRESSER)` wahr, `can_bite(Diet.ALLESFRESSER)` wahr, `can_bite(Diet.PFLANZENFRESSER)` falsch
- `test_schaden`: `bite_damage(20.0, 18.0, 12.0)` ist 30.0; `bite_damage(20.0, 12.0, 60.0)` ist 10.0; `bite_damage(20.0, 60.0, 12.0)` ist 40.0
- `test_fleischbrocken`: `meat_positions(Vector2.ZERO, 20.0)` hat Größe 3, `[0]` ist (10, 0), jeder Punkt hat Abstand 10.0 zum Ursprung

Review (16.10.2026): gemergt.
