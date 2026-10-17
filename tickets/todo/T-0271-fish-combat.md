---
id: T-0271
title: FishCombat – Bisse und Stacheln in der Fischphase
project: zellenphase
priority: 4
after: T-0262
---
## Ziel
Meilenstein „Fischphase – Leben im Meer“: Regeln für Bisse unter Wasser. Ein Biss trifft, wenn das Maul den Körper des Ziels berührt. Stacheln wehren einen Teil des Schadens ab und verletzen den Angreifer.

## Dateien
- `scripts/fish_combat.gd` – neu
- `tests/test_fish_combat.gd` – neu

## Akzeptanzkriterien
Neue Datei `scripts/fish_combat.gd`, genau so:
```gdscript
class_name FishCombat
extends RefCounted
## Kampfregeln der Fischphase.

## Reichweite des Mauls über den Körperradius des Ziels hinaus, in Metern.
const REACH := 0.4
## Schaden je Stachelstufe, den ein beißender Angreifer selbst erleidet.
const SPIKE_DAMAGE := 6.0


## Trifft ein Biss? Das Maul muss höchstens target_radius + REACH vom Ziel entfernt sein.
static func bite_hits(mouth: Vector3, target_pos: Vector3, target_radius: float) -> bool:
	return mouth.distance_to(target_pos) <= target_radius + REACH


## Schaden, den der Spielerfisch nach Abzug seiner Stachel-Abwehr erleidet.
static func damage_to_player(raw: float, build: FishBuild) -> float:
	return raw * (1.0 - FishAbilities.defense(build))


## Schaden, den ein Angreifer beim Biss in den Spielerfisch durch dessen Stacheln erleidet.
static func spike_reflect(build: FishBuild) -> float:
	return SPIKE_DAMAGE * build.level("stacheln")
```

## Tests
Neue Datei `tests/test_fish_combat.gd` (`extends "res://tests/base_test.gd"`):
- `test_biss_trifft`: `bite_hits(Vector3.ZERO, Vector3(0, 0, 1.0), 0.6)` wahr; `bite_hits(Vector3.ZERO, Vector3(0, 0, 1.01), 0.6)` falsch
- `test_abwehr`: `var b := FishBuild.new()`; `damage_to_player(20.0, b)` ist 20.0; nach zweimal `b.upgrade("stacheln")` ist es 14.0 (Toleranz 0,001)
- `test_stacheln_verletzen`: `spike_reflect(FishBuild.new())` ist 0.0; nach dreimal `upgrade("stacheln")` 18.0
