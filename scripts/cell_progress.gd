class_name CellProgress
extends RefCounted
## DNA (ausgebbar) und Wachstum (Fortschritt zum nächsten Größenabschnitt) der Spielerzelle.

const STAGE_COUNT := 5
## Wachstum, das vom Abschnitt i zum Abschnitt i + 1 nötig ist.
const GROWTH_NEEDED := [10, 15, 20, 25]
## Zellradius je Abschnitt in Pixeln.
const RADII := [12.0, 18.0, 27.0, 40.0, 60.0]

var dna := 0
var growth := 0
var stage := 0


## Rechnet gefressene Nahrung an. true, wenn die Zelle dabei mindestens einen Abschnitt aufsteigt.
func eat(value: int) -> bool:
	if value <= 0:
		return false
	dna += value
	growth += value
	var grew := false
	while stage < STAGE_COUNT - 1 and growth >= GROWTH_NEEDED[stage]:
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
	return stage == STAGE_COUNT - 1


## Fortschritt zum nächsten Abschnitt von 0 bis 1; im letzten Abschnitt immer 1.
func growth_ratio() -> float:
	if is_final_stage():
		return 1.0
	return float(growth) / GROWTH_NEEDED[stage]


func radius() -> float:
	return radius_for_stage(stage)


static func radius_for_stage(s: int) -> float:
	return RADII[clampi(s, 0, STAGE_COUNT - 1)]
