class_name FishSave
extends RefCounted
## Spielstand der Fischphase: Ausbau und Fortschritt als Dictionary (Schlüssel "fish" im Spielstand).

const KEY := "fish"


static func to_dict(build: FishBuild, progress: FishProgress, timeline: EvolutionTimeline = null) -> Dictionary:
	var d := {"build": build.to_dict(), "dna": progress.dna, "growth": progress.growth, "stage": progress.stage}
	if timeline != null:
		d["timeline"] = timeline.to_dict()
	return d


## Zeitstrahl aus dem Fischteil des Spielstands; leer, wenn keiner gespeichert ist.
static func read_timeline(data: Dictionary) -> EvolutionTimeline:
	var t: Variant = data.get("timeline")
	if t is Dictionary:
		return EvolutionTimeline.from_dict(t)
	return EvolutionTimeline.new()


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
