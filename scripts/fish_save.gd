class_name FishSave
extends RefCounted
## Spielstand der Fischphase: Ausbau und Fortschritt als Dictionary (Schlüssel "fish" im Spielstand).

const KEY := "fish"


static func to_dict(build: FishBuild, progress: FishProgress) -> Dictionary:
	return {"build": build.to_dict(), "dna": progress.dna, "growth": progress.growth, "stage": progress.stage}


## Überträgt DNA, Wachstum und Größe auf progress und gibt den gespeicherten Ausbau zurück.
static func apply(data: Dictionary, progress: FishProgress) -> FishBuild:
	progress.dna = maxi(0, int(data.get("dna", 0)))
	progress.growth = maxi(0, int(data.get("growth", 0)))
	progress.stage = clampi(int(data.get("stage", 0)), 0, FishProgress.SIZES.size() - 1)
	var b: Variant = data.get("build", {})
	return FishBuild.from_dict(b if b is Dictionary else {})


## Hat ein Spielstand schon einen Teil für die Fischphase?
static func has_fish(save_data: Dictionary) -> bool:
	return save_data.get(KEY) is Dictionary
