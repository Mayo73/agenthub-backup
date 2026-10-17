class_name FishProgress
extends RefCounted
## DNA und Wachstum in der Fischphase. Der Fisch wächst in vier Größen (SIZES, 1 = Anfang).

## Wachstum, das für die nächste Größe nötig ist (je Stufe).
const GROWTH_NEEDED := [20, 30, 45]
const SIZES := [1.0, 1.4, 1.9, 2.5]

var dna := 0
var growth := 0
var stage := 0


## Rechnet gefressene Nahrung an. true, wenn der Fisch dabei mindestens eine Größe wächst.
func eat(value: int) -> bool:
	if value <= 0:
		return false
	dna += value
	growth += value
	var grew := false
	while stage < SIZES.size() - 1 and growth >= GROWTH_NEEDED[stage]:
		growth -= GROWTH_NEEDED[stage]
		stage += 1
		grew = true
	return grew


## Gibt DNA aus. false (und keine Änderung), wenn cost negativ ist oder die DNA nicht reicht.
func spend(cost: int) -> bool:
	if cost < 0 or cost > dna:
		return false
	dna -= cost
	return true


func is_final_stage() -> bool:
	return stage == SIZES.size() - 1


## Anteil des Wachstums bis zur nächsten Größe (0 bis 1); in der letzten Größe 1.
func growth_ratio() -> float:
	if is_final_stage():
		return 1.0
	return clampf(float(growth) / GROWTH_NEEDED[stage], 0.0, 1.0)


func size() -> float:
	return SIZES[stage]
