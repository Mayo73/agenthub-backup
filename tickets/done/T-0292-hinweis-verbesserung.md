---
id: T-0292
title: Anzeige meldet, wenn eine Verbesserung bezahlbar ist
project: zellenphase
priority: 4
after: T-0276
---
## Ziel
Meilenstein „Fischphase – Weiterentwicklung“, Nachtrag: Spieler sollen merken, dass sie das Entwicklungsmenü öffnen können. Sobald die DNA für mindestens eine Verbesserung reicht, zeigt die Anzeige „E: Verbesserung möglich“. Eingebaut wird der Aufruf in T-0293.

## Dateien
- `scripts/fish_upgrades.gd`
- `scripts/fish_hud.gd`
- `tests/test_fish_upgrades.gd` – Tests anhängen
- `tests/test_fish_hud.gd` – Tests anhängen

## Akzeptanzkriterien
- `scripts/fish_upgrades.gd`, neue Funktion am Ende:
```gdscript
## Reicht die DNA für mindestens eine Verbesserung?
static func any_affordable(b: FishBuild, progress: FishProgress) -> bool:
	for slot: String in FishBuild.SLOTS:
		if can_upgrade(b, progress, slot):
			return true
	return false
```
- `scripts/fish_hud.gd`:
  - Konstante `const UPGRADE_HINT := "E: Verbesserung möglich"` unter `const HELP := …`
  - Variable `var upgrade_label: Label` unter `var health_label: Label`
  - In `_init()` direkt nach der Zeile mit `health_label = make_label(...)`:
```gdscript
	upgrade_label = make_label("UpgradeHint", Vector2(40, 196), 26)
	upgrade_label.text = UPGRADE_HINT
	upgrade_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.45))
	upgrade_label.visible = false
```
  - Neue Funktion am Ende:
```gdscript
func show_upgrade_hint(value: bool) -> void:
	upgrade_label.visible = value
```
- Sonst nichts ändern.

## Tests
- `tests/test_fish_upgrades.gd` anhängen:
  - `test_etwas_bezahlbar`: `progress.dna = 9` → `FishUpgrades.any_affordable(build, progress)` falsch; `progress.dna = 10` → wahr
  - `test_alles_ausgebaut`: alle fünf Bauteile aus `FishBuild.SLOTS` je dreimal `build.upgrade(slot)`; `progress.dna = 500` → `any_affordable` falsch
- `tests/test_fish_hud.gd` anhängen (dort gibt es eine `FishHud`; sonst `var hud := FishHud.new()` und am Ende `hud.free()`):
  - `test_hinweis_verbesserung`: `hud.upgrade_label.text` ist `"E: Verbesserung möglich"`; am Anfang unsichtbar; `hud.show_upgrade_hint(true)` → sichtbar; `hud.show_upgrade_hint(false)` → unsichtbar

Review (18.10.2026): gemergt.
