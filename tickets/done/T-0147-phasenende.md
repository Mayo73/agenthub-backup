---
id: T-0147
title: Ende der Zellenphase und Knopf „An Land gehen“ (PhaseEnd, Hud)
project: zellenphase
priority: 3
---
## Ziel
Wie im Vorbild endet die Zellenphase, wenn die Zelle im letzten Größenabschnitt weiter gewachsen ist: Dann erscheint im HUD der Knopf „An Land gehen“ (Lastenheft „Vollständiger Durchlauf“). Hier entstehen die Regel und der Knopf; den Einbau ins Spiel macht ein späteres Ticket.

## Dateien
- `scripts/phase_end.gd`: neu
- `scripts/hud.gd`: Knopf ergänzen
- `tests/test_phase_end.gd`: neu
- `tests/test_hud_finish.gd`: neu

## Akzeptanzkriterien
`scripts/phase_end.gd` genau so:
```gdscript
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
```

In `scripts/hud.gd`:
- Direkt unter `extends CanvasLayer` und dem Klassenkommentar: `signal finish_pressed`
- Neue Variable unter `var message_time := 0.0`: `var finish_button: Button`
- Am Ende von `_init()`:
```gdscript
	finish_button = Button.new()
	finish_button.name = "Finish"
	finish_button.text = "An Land gehen"
	finish_button.custom_minimum_size = Vector2(320, 56)
	finish_button.add_theme_font_size_override("font_size", 26)
	finish_button.position = Vector2(1576, 24)
	finish_button.visible = false
	finish_button.pressed.connect(func() -> void: finish_pressed.emit())
	add_child(finish_button)
```
- Neue Funktion am Ende:
```gdscript
## Zeigt den Knopf „An Land gehen“, sobald die Zellenphase beendet werden kann.
func show_can_finish(value: bool) -> void:
	finish_button.visible = value
```
- Sonst nichts an `hud.gd` ändern.

## Tests
`tests/test_phase_end.gd` mit `extends "res://tests/base_test.gd"`, `var p: CellProgress`; `setup()`: `p = CellProgress.new()`.
- `test_am_anfang`: `PhaseEnd.can_finish(p)` falsch; `PhaseEnd.ratio(p)` ist 0.0
- `test_letzter_abschnitt`: `p.eat(70)` → `p.is_final_stage()` wahr; `PhaseEnd.can_finish(p)` falsch; `PhaseEnd.ratio(p)` ist 0.0
- `test_fertig`: `p.eat(70)`, `p.eat(15)` → `PhaseEnd.ratio(p)` ist 0.5; `p.eat(15)` → `PhaseEnd.can_finish(p)` wahr; `PhaseEnd.ratio(p)` ist 1.0; `p.eat(20)` → `PhaseEnd.ratio(p)` ist 1.0

`tests/test_hud_finish.gd` mit `extends "res://tests/base_test.gd"`, `var hud: Hud`; `setup()`: `hud = Hud.new()`; `teardown()`: `hud.free()`.
- `test_verborgen`: `hud.finish_button.visible` falsch; `hud.finish_button.text` ist `"An Land gehen"`
- `test_zeigen`: `hud.show_can_finish(true)` → `hud.finish_button.visible` wahr; `hud.show_can_finish(false)` → falsch
- `test_signal`: `var got: Array = []`, `hud.finish_pressed.connect(func() -> void: got.append(1))`, `hud.finish_button.pressed.emit()` → `got.size()` ist 1

Review (16.10.2026): gemergt.
