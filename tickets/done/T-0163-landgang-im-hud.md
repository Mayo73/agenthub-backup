---
id: T-0163
title: Fortschritt zum Landgang im HUD
project: zellenphase
priority: 3
after: T-0147
---
## Ziel
Im letzten Größenabschnitt zeigt der Wachstumsbalken den Fortschritt bis „An Land gehen“ (`PhaseEnd.ratio`) statt immer voll zu sein. So sieht der Spieler, wie weit es noch bis zum Ende der Zellenphase ist.

## Dateien
- `scripts/hud.gd`
- `tests/test_hud_landgang.gd`: neu

## Akzeptanzkriterien
In `scripts/hud.gd` in `show_progress(progress)` die Zeile `growth_bar.value = progress.growth_ratio() * 100.0` ersetzen durch:
```gdscript
	if progress.is_final_stage():
		growth_bar.value = PhaseEnd.ratio(progress) * 100.0
	else:
		growth_bar.value = progress.growth_ratio() * 100.0
```
Sonst nichts ändern (die Texte bleiben gleich).

## Tests
`tests/test_hud_landgang.gd` mit `extends "res://tests/base_test.gd"`, `var hud: Hud`, `var p: CellProgress`; `setup()`: `hud = Hud.new()`, `p = CellProgress.new()`; `teardown()`: `hud.free()`.
- `test_vorher`: `p.eat(5)`, `hud.show_progress(p)` → `hud.growth_bar.value` ist 50.0
- `test_letzter_abschnitt`: `p.eat(70)`, `hud.show_progress(p)` → `hud.growth_bar.value` ist 0.0; `hud.stage_label.text` ist `"Größe 5/5"`
- `test_halb`: `p.eat(70)`, `p.eat(15)`, `hud.show_progress(p)` → `hud.growth_bar.value` ist 50.0

Review (16.10.2026): gemergt.
