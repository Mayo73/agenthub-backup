---
id: T-0190
title: Spielerzelle pulsiert beim Wachsen
project: zellenphase
priority: 3
after: T-0189
---
## Ziel
Beim Wechsel in den nächsten Größenabschnitt bläht sich die Spielerzelle kurz auf und schrumpft wieder auf ihre neue Größe. Das macht den Wachstumsschritt sichtbar (Lastenheft: „Zoom und Größenwechsel vermitteln den Wechsel des Maßstabs“). Ausgelöst wird es später aus `main.gd`.

## Dateien
- `scripts/player_cell.gd`
- `tests/test_player_cell.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
In `scripts/player_cell.gd`:
- Neue Konstante direkt unter `const CHEW_TIME := 0.3`: `const PULSE_TIME := 0.6`
- Neue Variable direkt unter `var chew_left := 0.0`:
```gdscript
## Restzeit des Wachstumspulses in Sekunden.
var pulse_left := 0.0
```
- In `drive(delta, wish)` am Ende (nach `queue_redraw()`):
```gdscript
	pulse_left = maxf(0.0, pulse_left - delta)
	scale = Vector2.ONE * pulse_scale()
```
- Neue Funktionen am Ende:
```gdscript
## Startet den Wachstumspuls.
func pulse() -> void:
	pulse_left = PULSE_TIME


## Größenfaktor der Darstellung: steigt während des Pulses bis 1,25 und fällt zurück auf 1.
func pulse_scale() -> float:
	return 1.0 + 0.25 * sin(PI * pulse_left / PULSE_TIME)
```
- Sonst nichts ändern.

## Tests
In `tests/test_player_cell.gd` anhängen:
- `test_puls_ruhig`: `cell.pulse_scale()` ist 1.0
- `test_puls`: `cell.pulse()`, `cell.drive(0.3, Vector2.ZERO)` → `cell.pulse_scale()` ist 1.25; `cell.scale.x` ist 1.25
- `test_puls_vorbei`: `cell.pulse()`, `cell.drive(1.0, Vector2.ZERO)` → `cell.scale.x` ist 1.0; `cell.radius` ist 12.0

Review (17.10.2026): gemergt.
