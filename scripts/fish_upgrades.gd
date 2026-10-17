class_name FishUpgrades
extends RefCounted
## Verbessern der Bauteile mit DNA. Preis für die nächste Stufe: COSTS[aktuelle Stufe].

const COSTS := [10, 20, 35]


## DNA für die nächste Stufe; -1, wenn das Bauteil schon die höchste Stufe hat oder unbekannt ist.
static func cost(b: FishBuild, slot: String) -> int:
	if not slot in FishBuild.SLOTS or b.level(slot) >= FishBuild.MAX_LEVEL:
		return -1
	return COSTS[b.level(slot)]


static func can_upgrade(b: FishBuild, progress: FishProgress, slot: String) -> bool:
	var c := cost(b, slot)
	return c >= 0 and progress.dna >= c


## Gibt die DNA aus und erhöht das Bauteil um eine Stufe. false (ohne Änderung), wenn es nicht geht.
static func upgrade(b: FishBuild, progress: FishProgress, slot: String) -> bool:
	if not can_upgrade(b, progress, slot):
		return false
	progress.spend(cost(b, slot))
	b.upgrade(slot)
	return true


## Reicht die DNA für mindestens eine Verbesserung?
static func any_affordable(b: FishBuild, progress: FishProgress) -> bool:
	for slot: String in FishBuild.SLOTS:
		if can_upgrade(b, progress, slot):
			return true
	return false
