class_name FishReadiness
extends RefCounted
## Logik, wann eine Zelle im Editor zum Fisch werden darf.

const NEEDED_PARTS := 6

## Anzahl aller sammelbaren Teile laut UNLOCK_ORDER.
static func total_parts() -> int:
	return PartCatalog.UNLOCK_ORDER.size()


## Wie viele Teile aus PartCatalog.UNLOCK_ORDER sind freigeschaltet?
static func parts_found(unlocks: PartUnlocks) -> int:
	var count := 0
	for id in PartCatalog.UNLOCK_ORDER:
		if unlocks.is_unlocked(id):
			count += 1
	return count


## Darf die Zelle jetzt zum Fisch werden? Nur im letzten Abschnitt und mit mindestens NEEDED_PARTS Teilen.
static func is_ready(progress: CellProgress, unlocks: PartUnlocks) -> bool:
	return progress.is_final_stage() and parts_found(unlocks) >= NEEDED_PARTS


## Fehlende Teile oder Begründung für den Editor.
static func missing_text(progress: CellProgress, unlocks: PartUnlocks) -> String:
	if is_ready(progress, unlocks):
		return ""
	if not progress.is_final_stage():
		return "Erst im letzten Größenabschnitt"
	var found := parts_found(unlocks)
	var missing := NEEDED_PARTS - found
	if missing == 1:
		return "Noch 1 Teil finden"
	return "Noch %d Teile finden" % missing


## HUD-Text für den Editor.
static func hud_text(progress: CellProgress, unlocks: PartUnlocks) -> String:
	if not progress.is_final_stage():
		return ""
	var found := parts_found(unlocks)
	if is_ready(progress, unlocks):
		return "Bereit: Im Editor kannst du zum Fisch werden"
	return "Teile %d/%d – ab %d kannst du im Editor zum Fisch werden" % [found, total_parts(), NEEDED_PARTS]
