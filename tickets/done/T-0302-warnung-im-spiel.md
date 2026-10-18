---
id: T-0302
title: Raubfisch-Warnung in der Anzeige der Fischphase
project: zellenphase
priority: 2
after: T-0301, T-0297, T-0300
---
## Ziel
Kommt ein Raubfisch näher als 15 m, zeigt die Anzeige der Fischphase eine orangefarbene Warnung mit dem Abstand. Nutzt `FishThreat` aus T-0301.

## Dateien
- `scripts/fish_hud.gd` – Warnzeile
- `scripts/fish_main.gd` – Warnung jedes Bild aktualisieren
- `tests/test_fish_hud.gd`, `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- `scripts/fish_hud.gd`:
  - Neue Variable `var warning_label: Label` unter `var health_label: Label`.
  - In `_init()` direkt vor `help_label = make_label(...)`:
```gdscript
	warning_label = make_label("Warning", Vector2(560, 200), 30)
	warning_label.add_theme_color_override("font_color", Color(1.0, 0.55, 0.15))
	warning_label.visible = false
```
  - Neue Funktion unter `show_health(ratio)`:
```gdscript
## Zeigt die Warnung vor Raubfischen; ein leerer Text blendet sie aus.
func show_warning(text: String) -> void:
	warning_label.text = text
	warning_label.visible = text != ""
```
- `scripts/fish_main.gd`:
  - Neue Funktion am Ende:
```gdscript
## Warnt, wenn ein Raubfisch nahe am Spielerfisch ist.
func update_warning() -> void:
	hud.show_warning(FishThreat.warning_text(FishThreat.nearest_predator(player.motion.position, fishes)))
```
  - In `_physics_process(delta)` direkt nach der Zeile `check_death()` die Zeile `update_warning()`.
- Sonst nichts ändern.

## Tests
- `tests/test_fish_hud.gd`, anhängen:
  - `test_warnung_anfangs_aus`: `hud.warning_label.visible` ist falsch
  - `test_warnung_zeigen`: `hud.show_warning("Vorsicht: Raubfisch in 8 m!")` → `hud.warning_label.visible` wahr, `hud.warning_label.text` ist `"Vorsicht: Raubfisch in 8 m!"`; danach `hud.show_warning("")` → `visible` falsch
- `tests/test_fish_main.gd`, anhängen (vorher `_clear_ai_fishes()` aufrufen, wie die übrigen Tests dort):
  - `test_warnung_nah`: `fish.add_fish("zackenbarsch", fish.player.motion.position + Vector3(8, 0, 0))`; `fish.update_warning()` → `fish.hud.warning_label.visible` wahr und `fish.hud.warning_label.text` ist `"Vorsicht: Raubfisch in 8 m!"`
  - `test_warnung_fern`: `fish.add_fish("zackenbarsch", fish.player.motion.position + Vector3(40, 0, 0))`; `fish.update_warning()` → `fish.hud.warning_label.visible` falsch
  - `test_keine_warnung_bei_beute`: `fish.add_fish("grasfisch", fish.player.motion.position + Vector3(5, 0, 0))`; `fish.update_warning()` → `fish.hud.warning_label.visible` falsch

Hinweis: Liegt der Spieler nahe am Rand der Welt, kann `add_fish` die Lage begrenzen. Der Spieler startet bei `FishWorld.START`, dort ist in x-Richtung genug Platz.

Review (18.10.2026): gemergt, nachgebessert: Anführungszeichen im Kommentar wiederhergestellt.
