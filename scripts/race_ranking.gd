class_name RaceRanking
extends RefCounted

## Platz (1 = vorn) eines Fahrers mit `own` gefahrener Strecke gegen die Strecken der anderen.
static func place(own: float, others: Array) -> int:
	var result := 1
	for other in others:
		if float(other) > own:
			result += 1
	return result
