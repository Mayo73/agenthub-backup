---
id: T-0224
title: Der Giftling hinterlässt Giftwolken
project: zellenphase
priority: 2
after: T-0223
---
## Ziel
Der Giftling hat zwei Giftdrüsen. Beim Schwimmen lässt er nun Giftwolken zurück, die der Spielerzelle schaden und wie die eigenen Wolken gezeichnet werden.

## Dateien
- `scripts/ai_cell.gd`
- `scripts/main.gd`
- `tests/test_ai_cell.gd` – Tests anhängen
- `tests/test_main_ki_waffen.gd` – Tests anhängen

## Akzeptanzkriterien
- `scripts/ai_cell.gd`: unter `var flash := HitFlash.new()` die Zeile `var poison: PoisonClouds = null` mit dem Kommentar `## Giftwolken der Zelle, nur bei Arten mit Giftdrüse.` darüber. Am Ende von `setup(id, pos)`:
```gdscript
	poison = PoisonClouds.new() if SpeciesWeapons.has_poison(id) else null
```
- `scripts/main.gd`, Funktion `resolve_ai_weapons(delta)`:
  - direkt nach der Zeile `var factor := ...` die Zeile `var sources: Array = [poison]` einfügen;
  - in der Schleife `for cell in ai_cells:` nach dem Stachel-Block (gleiche Einrückung wie `var tips := ...`):
```gdscript
		if cell.poison != null:
			sources.append(cell.poison)
			cell.poison.tick(delta)
			if cell.motion.speed() > 20.0:
				cell.poison.emit(PartGeometry.world_point(cell.motion.position, cell.motion.heading, cell.radius, Vector2(-1.2, 0)))
			player_health.drain(cell.poison.damage_at(player.motion.position, player.radius, delta) * factor)
```
  - nach der Schleife als letzte Zeile der Funktion: `poison_view.sources = sources`
- Sonst nichts ändern.

## Tests
In `tests/test_ai_cell.gd` anhängen (Zellen am Ende mit `free()` freigeben):
- `test_giftling_hat_gift`: `var c := AiCell.new()`, `c.setup("giftling", Vector2.ZERO)` → `c.poison != null` wahr
- `test_schnapper_ohne_gift`: `var c := AiCell.new()`, `c.setup("schnapper", Vector2.ZERO)` → `c.poison == null` wahr

In `tests/test_main_ki_waffen.gd` anhängen (nutzt `_add` und `setup()` von dort):
- `test_giftling_hinterlaesst_wolke`: `var c := _add("giftling", Vector2(200, 0))`, `c.motion.velocity = Vector2(50, 0)`, `main.resolve_ai_weapons(0.1)` → `c.poison.clouds.size()` ist 1; `main.poison_view.sources.has(c.poison)` wahr; `main.poison_view.sources.has(main.poison)` wahr
- `test_giftwolke_schadet`: `var c := _add("giftling", Vector2(200, 0))`, `c.motion.velocity = Vector2.ZERO`, `c.poison.clouds.append({"pos": main.player.motion.position, "age": 0.0})`, `var vorher: float = main.player_health.hp`, `main.resolve_ai_weapons(0.5)` → `vorher - main.player_health.hp` ist `PoisonClouds.DPS * 0.5`

Review (17.10.2026): gemergt.
