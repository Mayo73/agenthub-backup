class_name Difficulty
extends RefCounted
## Schwierigkeitsgrade (Lastenheft „Kann"): Faktor für den Schaden, den Bisse anderer Zellen der Spielerzelle zufügen.

const NAMES := ["Leicht", "Normal", "Schwer"]
const DAMAGE := [0.6, 1.0, 1.5]
const NORMAL := 1


## Begrenzt einen Index auf die gültigen Stufen.
static func clamp_index(i: int) -> int:
	return clampi(i, 0, NAMES.size() - 1)


static func name_of(i: int) -> String:
	return NAMES[clamp_index(i)]


static func damage_factor(i: int) -> float:
	return DAMAGE[clamp_index(i)]
