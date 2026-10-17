---
id: T-0113
title: Stacheln, Gift und Elektroorgan im Spiel
project: zellenphase
priority: 3
after: T-0109, T-0107, T-0110, T-0111, T-0112
---
## Ziel
Die Waffen der Spielerzelle wirken im Spiel auf KI-Zellen: Stachelspitzen verletzen bei Berührung, die Giftdrüse hinterlässt beim Schwimmen Wolken, das Elektroorgan entlädt sich bei nahen Gegnern. Besiegte Zellen räumt wie bisher `resolve_combat()` ab.

## Dateien
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Neue Variablen direkt unter `var pickup_view: PickupView`:
```gdscript
var poison := PoisonClouds.new()
var electric := ElectricOrgan.new()
```
- In `_physics_process` direkt vor der Zeile `resolve_combat()` die Zeile `resolve_weapons(delta)` einfügen.
- Neue Funktion am Ende:
```gdscript
## Stacheln, Gift und Elektroorgan der Spielerzelle gegen KI-Zellen.
func resolve_weapons(delta: float) -> void:
	var pos := player.motion.position
	var heading := player.motion.heading
	var tips := WeaponRules.spike_tips(pos, heading, player.radius, player.build)
	poison.tick(delta)
	electric.tick(delta)
	if player.build.count("gift") > 0 and player.motion.speed() > 20.0:
		poison.emit(PartGeometry.world_point(pos, heading, player.radius, Vector2(-1.2, 0)))
	var zap := player.build.count("elektro") > 0 and electric.is_ready()
	var zapped := false
	for cell in ai_cells:
		if WeaponRules.spike_hits(tips, cell.motion.position, cell.radius) > 0:
			if cell.health.damage(WeaponRules.SPIKE_DAMAGE):
				cell.motion.knockback(cell.motion.position - pos, 100.0)
		cell.health.drain(poison.damage_at(cell.motion.position, cell.radius, delta))
		if zap and ElectricOrgan.in_range(pos, player.radius, cell.motion.position, cell.radius):
			cell.health.damage(ElectricOrgan.DAMAGE)
			zapped = true
	if zapped:
		electric.fire()
```
- Sonst nichts an `main.gd` ändern.

## Tests
In `tests/test_main_wiring.gd` anhängen. Die Hilfsfunktion `_add_ai(id, pos, heading)` gibt es in der Datei schon; benutze sie. Die Spielerzelle steht bei (0, 0), Blick nach rechts, Radius 12.
- `test_stachel_hinten`: `var b := CellBuild.starter(Diet.PFLANZENFRESSER)`, `b.add_part("stachel", Vector2(-1, 0))`, `main.player.set_build(b)`; `var cell := _add_ai("weidezelle", Vector2(-40, 0), 0.0)`; `main.resolve_weapons(0.016)` → `cell.health.hp` ist 105.0
- `test_ohne_stachel`: ohne `set_build`; `var cell := _add_ai("weidezelle", Vector2(-40, 0), 0.0)`; `main.resolve_weapons(0.016)` → `cell.health.hp` ist 120.0
- `test_gift`: Startaufbau plus `b.add_part("gift", Vector2(-1, 0))`, `main.player.set_build(b)`, `main.player.motion.velocity = Vector2(100, 0)`; `var cell := _add_ai("blasenling", Vector2(-20, 0), 0.0)`; `main.resolve_weapons(0.5)` → `main.poison.clouds.size()` ist 1, `cell.health.hp` ist 14.0
- `test_elektro`: Startaufbau plus `b.add_part("elektro", Vector2(0, 0.5))`, `main.player.set_build(b)`; `var cell := _add_ai("schnapper", Vector2(25, 0), PI)`; `main.resolve_weapons(0.016)` → `cell.health.hp` ist 22.0, `main.electric.is_ready()` falsch

Review (16.10.2026): gemergt.
