---
id: T-0431
title: FishReadiness – wann die Zelle zum Fisch werden kann
project: zellenphase
priority: 4
---
## Ziel
Auftrag „Übergang zum Fisch im Editor“: Im letzten Größenabschnitt und mit mindestens 6 der 8 sammelbaren Teile darf die Zelle im Editor zum Fisch werden. Eine Logikklasse prüft das und liefert die Texte für Editor und HUD.

## Dateien
- `scripts/fish_readiness.gd` – neu, Klasse `FishReadiness`
- `tests/test_fish_readiness.gd` – neu

## Akzeptanzkriterien
`class_name FishReadiness`, `extends RefCounted`, nur statische Funktionen. Vorher `scripts/cell_progress.gd`, `scripts/part_unlocks.gd` und `scripts/part_catalog.gd` lesen.
- `const NEEDED_PARTS := 6`
- `static func total_parts() -> int`: `PartCatalog.UNLOCK_ORDER.size()` (derzeit 8)
- `static func parts_found(unlocks: PartUnlocks) -> int`: wie viele Teile aus `PartCatalog.UNLOCK_ORDER` freigeschaltet sind
- `static func is_ready(progress: CellProgress, unlocks: PartUnlocks) -> bool`: `progress.is_final_stage()` und `parts_found(unlocks) >= NEEDED_PARTS`
- `static func missing_text(progress: CellProgress, unlocks: PartUnlocks) -> String`: bereit → „“; nicht im letzten Abschnitt → „Erst im letzten Größenabschnitt“; sonst `"Noch %d Teile finden" % fehlend` (bei genau 1: „Noch 1 Teil finden“)
- `static func hud_text(progress: CellProgress, unlocks: PartUnlocks) -> String`: nicht im letzten Abschnitt → „“; bereit → „Bereit: Im Editor kannst du zum Fisch werden“; sonst `"Teile %d/%d – ab %d kannst du im Editor zum Fisch werden" % [gefunden, gesamt, NEEDED_PARTS]`

## Tests
`tests/test_fish_readiness.gd` (letzten Abschnitt mit `progress.stage = CellProgress.STAGE_COUNT - 1` herstellen, Teile mit `unlocks.unlock(PartCatalog.UNLOCK_ORDER[i])`):
- `test_zu_frueh`: Abschnitt 0, alle Teile → nicht bereit, Text „Erst im letzten Größenabschnitt“
- `test_zu_wenig_teile`: letzter Abschnitt, 4 Teile → nicht bereit, „Noch 2 Teile finden“; 5 Teile → „Noch 1 Teil finden“
- `test_bereit`: letzter Abschnitt, 6 Teile → bereit, `missing_text` leer, `hud_text` „Bereit: Im Editor kannst du zum Fisch werden“
- `test_hud`: letzter Abschnitt, 5 Teile → „Teile 5/8 – ab 6 kannst du im Editor zum Fisch werden“; Abschnitt 0 → „“

Review (20.10.2026): gemergt.
