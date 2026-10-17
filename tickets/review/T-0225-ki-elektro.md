---
id: T-0225
title: Die Zitterzelle entlädt sich bei der Spielerzelle
project: zellenphase
priority: 2
after: T-0224
---
## Ziel
Die Zitterzelle hat ein Elektroorgan. Kommt die Spielerzelle zu nah, entlädt es sich mit einem sichtbaren Blitz, schadet ihr und lädt dann nach.

## Dateien
- `scripts/ai_cell.gd`
- `scripts/main.gd`
- `tests/test_ai_cell.gd` – Tests anhängen
- `tests/test_main_ki_waffen.gd` – Tests anhängen

## Akzeptanzkriterien
- `scripts/ai_cell.gd`: unter `var poison: PoisonClouds = null` die Zeile `var organ: ElectricOrgan = null` mit dem Kommentar `## Elektroorgan, nur bei Arten mit Teil "elektro".` darüber. Am Ende von `setup(id, pos)`:
```gdscript
	organ = ElectricOrgan.new() if SpeciesWeapons.has_electric(id) else null
```
- `scripts/main.gd`, Funktion `resolve_ai_weapons(delta)`, in der Schleife `for cell in ai_cells:` nach dem Gift-Block (gleiche Einrückung wie `if cell.poison != null:`):
```gdscript
		if cell.organ != null:
			cell.organ.tick(delta)
			if cell.organ.is_ready() and ElectricOrgan.in_range(cell.motion.position, cell.radius, player.motion.position, player.radius):
				if player_health.damage(ElectricOrgan.DAMAGE * factor):
					player.flash.trigger()
					audio.play("treffer")
				cell.organ.fire()
				var target: Array[Vector2] = [player.motion.position]
				zap_view.show_zaps(cell.motion.position, target)
```
- Sonst nichts ändern.

## Tests
In `tests/test_ai_cell.gd` anhängen (Zellen am Ende mit `free()` freigeben):
- `test_zitterzelle_hat_organ`: `var c := AiCell.new()`, `c.setup("zitterzelle", Vector2.ZERO)` → `c.organ != null` wahr
- `test_blasenling_ohne_organ`: `var c := AiCell.new()`, `c.setup("blasenling", Vector2.ZERO)` → `c.organ == null` wahr

In `tests/test_main_ki_waffen.gd` anhängen:
- `test_zitterzelle_entlaedt_sich`: `var c := _add("zitterzelle", Vector2(40, 0))`, `var vorher: float = main.player_health.hp`, `main.resolve_ai_weapons(0.016)` → `vorher - main.player_health.hp` ist `ElectricOrgan.DAMAGE`; `c.organ.is_ready()` falsch; `main.zap_view.is_zap_visible()` wahr
- `test_zitterzelle_laedt_nach`: `_add("zitterzelle", Vector2(40, 0))`, `main.resolve_ai_weapons(0.016)`, `main.player_health.invulnerable = 0.0`, `var vorher: float = main.player_health.hp`, `main.resolve_ai_weapons(0.016)` → `main.player_health.hp` ist `vorher`
- `test_zitterzelle_weit_weg`: `var c := _add("zitterzelle", Vector2(300, 0))`, `main.resolve_ai_weapons(0.016)` → `c.organ.is_ready()` wahr
