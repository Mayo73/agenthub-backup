---
id: T-0306
title: Roter Bildschirmrand bei Bissen in der Fischphase
project: zellenphase
priority: 3
after: T-0304
---
## Ziel
Beißt ein Raubfisch den Spielerfisch, leuchtet der Bildschirm kurz rötlich auf. So merkt der Spieler den Treffer auch, wenn er gerade nicht auf die Gesundheit schaut.

## Dateien
- `scripts/fish_hud.gd` – rote Fläche und Ausblenden
- `scripts/fish_main.gd` – bei Treffer auslösen
- `tests/test_fish_hud.gd`, `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- `scripts/fish_hud.gd`:
  - Neue Konstante unter `const HELP := ...`: `const FLASH_TIME := 0.4`
  - Neue Variablen unter `var message_left := 0.0`: `var flash_rect: ColorRect` und `var flash_left := 0.0`
  - In `_init()` direkt nach `layer = 5` (damit die Fläche hinter den Schriften liegt):
```gdscript
	flash_rect = ColorRect.new()
	flash_rect.name = "Flash"
	flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_rect.color = Color(0.85, 0.1, 0.1, 0.0)
	add_child(flash_rect)
```
  - Neue Funktion unter `show_health(ratio)`:
```gdscript
## Lässt den Bildschirm kurz rot aufleuchten (Biss eines Raubfischs).
func flash() -> void:
	flash_left = FLASH_TIME
	flash_rect.color.a = 0.35
```
  - `tick(delta)` am **Anfang** um diese Zeilen ergänzen (vor der Prüfung `if message_left <= 0.0`):
```gdscript
	if flash_left > 0.0:
		flash_left = maxf(0.0, flash_left - delta)
		flash_rect.color.a = 0.35 * flash_left / FLASH_TIME
```
- `scripts/fish_main.gd`: In `predators_bite()` im Zweig `if player_health.damage(...):` als erste Zeile `hud.flash()`.
- Sonst nichts ändern.

## Tests
- `tests/test_fish_hud.gd`, anhängen:
  - `test_blitz_anfangs_aus`: `hud.flash_rect.color.a` ist 0.0
  - `test_blitz`: `hud.flash()` → `hud.flash_rect.color.a` ist 0.35; `hud.tick(0.2)` → `color.a` ist `0.35 * 0.5` (Toleranz über `check_eq`); `hud.tick(1.0)` → `color.a` ist 0.0
- `tests/test_fish_main.gd`, anhängen (vorher `_clear_ai_fishes()`):
  - `test_biss_blitzt`: `fish.add_fish("zackenbarsch", fish.player.motion.position + Vector3(0, 0, 1.5))` (wie in `test_raubfisch_beisst`); `fish.predators_bite()` → `fish.hud.flash_rect.color.a` größer als 0.0

Review (18.10.2026): gemergt.
