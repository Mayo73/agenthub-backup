---
id: T-0313
title: Schwierigkeitsgrad gilt auch für Raubfischbisse
project: zellenphase
priority: 3
after: T-0312
---
## Ziel
Auftrag „Fischphase – lebendige Welt“: Der Schwierigkeitsgrad aus dem Einstellungsmenü (Leicht/Normal/Schwer) bestimmt bisher nur den Schaden in der Zellenphase. Er soll auch den Bissschaden der Raubfische in der Fischphase verändern.

## Dateien
- `scripts/fish_main.gd`
- `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- Neue Variable `var settings := UserSettings.new()` unter `var respawn_timer := 0.0`.
- In `_ready()` direkt nach `Controls.setup()`: `settings.load_from(UserSettings.DEFAULT_PATH)` (nur lesen, nie speichern).
- Neue Funktion direkt über `predators_bite()`:
```gdscript
## Schaden eines Raubfischbisses am Spielerfisch: Stacheln schützen, der Schwierigkeitsgrad verstärkt oder schwächt.
func predator_damage(raw: float) -> float:
	return FishCombat.damage_to_player(raw, player.build) * Difficulty.damage_factor(settings.difficulty)
```
- In `predators_bite()` den Ausdruck `FishCombat.damage_to_player(raw, player.build)` durch `predator_damage(raw)` ersetzen.
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_main.gd` anhängen (am Ende jedes Tests `fish.settings.difficulty = Difficulty.NORMAL`):
- `test_schaden_normal`: `fish.settings.difficulty = Difficulty.NORMAL` → `fish.predator_damage(15.0)` ist `FishCombat.damage_to_player(15.0, fish.player.build)`
- `test_schaden_leicht`: `fish.settings.difficulty = 0` → `fish.predator_damage(15.0)` ist `FishCombat.damage_to_player(15.0, fish.player.build) * 0.6` (Vergleich mit `is_equal_approx`)
- `test_schaden_schwer`: `fish.settings.difficulty = 2` → `fish.predator_damage(10.0) > FishCombat.damage_to_player(10.0, fish.player.build)` wahr

Review (18.10.2026): gemergt.
