---
id: T-0293
title: Hinweis „Verbesserung möglich“ in der Fischszene
project: zellenphase
priority: 4
after: T-0289, T-0292
---
## Ziel
Die Fischszene blendet den Hinweis aus T-0292 ein, sobald die DNA für eine Verbesserung reicht, und blendet ihn wieder aus, wenn nicht mehr.

## Dateien
- `scripts/fish_main.gd`
- `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- Neue Funktion am Ende von `scripts/fish_main.gd`:
```gdscript
## Zeigt „E: Verbesserung möglich“, solange die DNA für mindestens eine Verbesserung reicht.
func update_upgrade_hint() -> void:
	hud.show_upgrade_hint(FishUpgrades.any_affordable(player.build, progress))
```
- `update_upgrade_hint()` aufrufen: in `feed_player()` als letzte Zeile; in `_on_upgraded(slot)` als letzte Zeile; in `_ready()` direkt nach `hud.show_progress(progress)`.
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_main.gd` anhängen:
- `test_hinweis_anfang`: `fish.progress.dna = 0`; `fish.update_upgrade_hint()` → `fish.hud.upgrade_label.visible` falsch
- `test_hinweis_genug_dna`: `fish.progress.dna = 10`; `fish.feed_player()` → `fish.hud.upgrade_label.visible` wahr
- `test_hinweis_nach_kauf`: `fish.progress.dna = 10`; `fish.update_upgrade_hint()`; `fish.toggle_evolve()`; `fish.evolve.try_upgrade("augen")` → `fish.progress.dna` ist 0 und `fish.hud.upgrade_label.visible` falsch

Review (18.10.2026): gemergt.
