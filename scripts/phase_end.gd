class_name PhaseEnd
extends RefCounted
## Ende der Zellenphase: Im letzten Größenabschnitt muss die Zelle noch FINAL_GROWTH Wachstum sammeln.

const FINAL_GROWTH := 30


static func can_finish(progress: CellProgress) -> bool:
	return progress.is_final_stage() and progress.growth >= FINAL_GROWTH


## Fortschritt zum Ende von 0 bis 1; vor dem letzten Abschnitt 0.
static func ratio(progress: CellProgress) -> float:
	if not progress.is_final_stage():
		return 0.0
	return clampf(float(progress.growth) / FINAL_GROWTH, 0.0, 1.0)
