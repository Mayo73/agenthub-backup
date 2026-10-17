---
id: T-0120
title: Teile im Kampf erbeuten
project: zellenphase
priority: 3
after: T-0113, T-0119
---
## Ziel
Besiegt die Spielerzelle eine andere Zelle, schaltet sie deren typisches Teil frei, falls es noch gesperrt ist, und eine Meldung erscheint.

## Dateien
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- In `resolve_combat()` im Block `if cell.health.is_dead():` direkt vor der Zeile `remove_ai(cell)` einfügen (gleiche Einrückung wie `remove_ai(cell)`):
```gdscript
			var part := PartDrops.drop_for(cell.species_id, unlocks)
			if part != "" and unlocks.unlock(part):
				hud.show_message("Teil erbeutet: %s" % PartCatalog.name_of(part))
```
- Sonst nichts an `main.gd` ändern.

## Tests
In `tests/test_main_wiring.gd` anhängen; die vorhandene Hilfsfunktion `_add_ai(id, pos, heading)` benutzen. Die Spielerzelle steht bei (0, 0), Blick nach rechts, Radius 12.
- `test_teil_erbeuten`: `main.player.diet = Diet.FLEISCHFRESSER`; `_add_ai("blasenling", Vector2(20, 0), 0.0)`; `main.resolve_combat()` → `main.ai_cells.size()` ist 0, `main.unlocks.is_unlocked("stielauge")` wahr, `main.hud.message_label.text` ist `"Teil erbeutet: Stielauge"`
- `test_teil_schon_frei`: `main.unlocks.unlock("stielauge")`; `main.player.diet = Diet.FLEISCHFRESSER`; `_add_ai("blasenling", Vector2(20, 0), 0.0)`; `main.resolve_combat()` → `main.unlocks.unlocked.size()` ist 4, `main.hud.message_label.text` ist `""`

Review (16.10.2026): gemergt.
