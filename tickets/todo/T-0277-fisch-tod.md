---
id: T-0277
title: Tod und Wiedereinstieg in der Fischphase
project: zellenphase
priority: 4
after: T-0276
---
## Ziel
Meilenstein „Fischphase – Leben im Meer“: Wird der Spielerfisch gefressen, taucht er an der Startstelle wieder auf. DNA, Größe und Ausbau bleiben, nahe Raubfische verschwinden, und er ist kurz unverwundbar (wie in der Zellenphase).

## Dateien
- `scripts/fish_main.gd`
- `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- In `scripts/fish_main.gd`: Variable `var deaths := 0` unter `var player_health := ...`; Konstante `const SAFE_RADIUS := 25.0` unter `const MOUTH_REACH := 0.5` mit dem Kommentar `## Raubfische in diesem Umkreis (Meter) verschwinden beim Wiedereinstieg.`
- In `_physics_process(delta)` direkt nach `hud.show_health(player_health.ratio())` die Zeile `check_death()`.
- Neue Funktion am Ende:
```gdscript
## Nach dem Tod taucht der Fisch an der Startstelle wieder auf: DNA, Größe und Ausbau bleiben.
func check_death() -> void:
	if not player_health.is_dead():
		return
	deaths += 1
	player.motion.position = FishWorld.START
	player.motion.velocity = Vector3.ZERO
	player.sync()
	for f in fishes.duplicate():
		if FishSpecies.is_predator(f.species_id) and f.motion.position.distance_to(FishWorld.START) < SAFE_RADIUS:
			remove_fish(f)
	player_health.reset(2.0)
	hud.show_health(player_health.ratio())
	hud.show_message("Dein Fisch wurde gefressen und schwimmt neu los.")
```
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_main.gd` anhängen; vor jedem Test alle KI-Fische entfernen:
- `test_lebt`: `fish.check_death()` → `fish.deaths` ist 0
- `test_tod`: `fish.progress.dna = 30`; `fish.player.motion.position = FishWorld.START + Vector3(40, 0, 0)`; `var nah: AiFish = fish.add_fish("zackenbarsch", FishWorld.START + Vector3(5, 0, 0))`; `var fern: AiFish = fish.add_fish("zackenbarsch", FishWorld.START + Vector3(60, 0, 0))`; `var beute: AiFish = fish.add_fish("silberling", FishWorld.START + Vector3(3, 0, 0))`; `fish.player_health.hp = 0.0`; `fish.check_death()` → `fish.deaths` ist 1; `fish.player.motion.position` ist `FishWorld.START`; `fish.fishes.has(nah)` falsch; `fish.fishes.has(fern)` wahr; `fish.fishes.has(beute)` wahr; `fish.progress.dna` ist 30; `fish.player_health.hp` ist 100.0; `fish.player_health.invulnerable > 0.0` wahr
