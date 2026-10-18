---
id: T-0300
title: Anzeige zeigt die Größe des Fischs
project: zellenphase
priority: 4
after: T-0292
---
## Ziel
Die Anzeige der Fischphase zeigt bisher DNA und Wachstum, aber nicht, in welcher der vier Größen der Fisch gerade ist. Eine Zeile „Größe: 2 / 4“ ergänzt das, wie „Abschnitt“ in der Zellenphase.

## Dateien
- `scripts/fish_hud.gd`
- `tests/test_fish_hud.gd` – Tests anhängen

## Akzeptanzkriterien
- `scripts/fish_hud.gd`:
  - Variable `var size_label: Label` unter `var upgrade_label: Label`.
  - In `_init()` direkt nach `upgrade_label.visible = false`: `size_label = make_label("Size", Vector2(320, 116), 28)` (rechts neben dem Wachstum). Die Zeile `show_progress(FishProgress.new())` am Ende von `_init()` muss danach stehen bleiben, damit `size_label` gefüllt wird; steht sie davor, ans Ende von `_init()` verschieben.
  - Neue statische Funktion unter `growth_text(progress)`:
```gdscript
static func size_text(progress: FishProgress) -> String:
	return "Größe: %d / %d" % [progress.stage + 1, FishProgress.SIZES.size()]
```
  - In `show_progress(progress)` als letzte Zeile: `size_label.text = size_text(progress)`.
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_hud.gd` anhängen:
- `test_groesse_text`: `var p := FishProgress.new()` → `FishHud.size_text(p)` ist `"Größe: 1 / 4"`; `p.stage = 3` → `"Größe: 4 / 4"`
- `test_groesse_anzeige`: `hud.size_label.text` ist `"Größe: 1 / 4"`; `var p := FishProgress.new()`; `p.stage = 1`; `hud.show_progress(p)` → `hud.size_label.text` ist `"Größe: 2 / 4"`

Review (18.10.2026): gemergt.
