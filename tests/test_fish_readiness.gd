extends "res://tests/base_test.gd"

var progress: CellProgress
var unlocks: PartUnlocks


func setup() -> void:
	progress = CellProgress.new()
	unlocks = PartUnlocks.new()


func test_zu_frueh():
	# Abschnitt 0, alle Teile → nicht bereit, Text „Erst im letzten Größenabschnitt"
	progress.stage = 0
	progress.growth = 0

	for id in PartCatalog.UNLOCK_ORDER:
		unlocks.unlock(id)

	check(not FishReadiness.is_ready(progress, unlocks), "Nicht bereit im frühen Abschnitt")
	var text := FishReadiness.missing_text(progress, unlocks)
	check_eq(text, "Erst im letzten Größenabschnitt", "Fehlertext für frühen Abschnitt falsch: %s" % text)


func test_zu_wenig_teile():
	# letzter Abschnitt, 4 Teile aus UNLOCK_ORDER → nicht bereit, „Noch 2 Teile finden"
	progress.stage = CellProgress.STAGE_COUNT - 1
	progress.growth = 0

	# Freischalte genau 4 Teile aus UNLOCK_ORDER
	unlocks.unlock(PartCatalog.UNLOCK_ORDER[0])  # geissel
	unlocks.unlock(PartCatalog.UNLOCK_ORDER[1])  # stachel
	unlocks.unlock(PartCatalog.UNLOCK_ORDER[2])  # wimpern
	unlocks.unlock(PartCatalog.UNLOCK_ORDER[3])  # ruessel

	check(not FishReadiness.is_ready(progress, unlocks), "Nicht bereit mit 4 Teilen")
	var text := FishReadiness.missing_text(progress, unlocks)
	check_eq(text, "Noch 2 Teile finden", "Fehlertext für 4 Teile falsch: %s" % text)

	# letzter Abschnitt, 5 Teile aus UNLOCK_ORDER → „Noch 1 Teil finden"
	unlocks.unlock(PartCatalog.UNLOCK_ORDER[4])  # gift
	text = FishReadiness.missing_text(progress, unlocks)
	check_eq(text, "Noch 1 Teil finden", "Fehlertext für 5 Teile falsch: %s" % text)


func test_bereit():
	# letzter Abschnitt, 6 Teile aus UNLOCK_ORDER → bereit, missing_text leer, hud_text korrekt
	progress.stage = CellProgress.STAGE_COUNT - 1
	progress.growth = 0

	for i in 6:
		unlocks.unlock(PartCatalog.UNLOCK_ORDER[i])

	check(FishReadiness.is_ready(progress, unlocks), "Bereit mit 6 Teilen")
	var missing := FishReadiness.missing_text(progress, unlocks)
	check_eq(missing, "", "missing_text sollte leer sein bei Bereitschaft: %s" % missing)
	var hud := FishReadiness.hud_text(progress, unlocks)
	check_eq(hud, "Bereit: Im Editor kannst du zum Fisch werden", "HUD-Text falsch: %s" % hud)


func test_hud():
	# letzter Abschnitt, 5 Teile aus UNLOCK_ORDER → HUD-Text mit Fortschritt
	progress.stage = CellProgress.STAGE_COUNT - 1
	progress.growth = 0

	for i in 5:
		unlocks.unlock(PartCatalog.UNLOCK_ORDER[i])

	var hud := FishReadiness.hud_text(progress, unlocks)
	check_eq(hud, "Teile 5/8 – ab 6 kannst du im Editor zum Fisch werden", "HUD-Text falsch: %s" % hud)

	# Abschnitt 0 → leerer HUD-Text
	progress.stage = 0
	hud = FishReadiness.hud_text(progress, unlocks)
	check_eq(hud, "", "HUD-Text für frühen Abschnitt sollte leer sein: %s" % hud)


func test_total_parts():
	check_eq(FishReadiness.total_parts(), 8, "total_parts soll 8 zurückgeben")
