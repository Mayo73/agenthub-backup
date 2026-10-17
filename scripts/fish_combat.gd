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
