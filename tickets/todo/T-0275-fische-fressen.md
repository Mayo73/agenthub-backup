---
id: T-0275
title: Spielerfisch beißt und frisst andere Fische
project: zellenphase
priority: 4
after: T-0274, T-0271
---
## Ziel
Meilenstein „Fischphase – Leben im Meer“: Ein Fleisch- oder Allesfresser-Fisch beißt andere Fische mit dem Maul. Der Kiefer bestimmt den Schaden (`FishAbilities.bite_damage`). Ist ein Fisch besiegt, wird er gefressen: Nahrung, DNA und Wachstum wie beim Fressen von Nahrung. Pflanzenfresser beißen nicht.

## Dateien
- `scripts/fish_main.gd`
- `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- In `scripts/fish_main.gd`, `_physics_process(delta)`: direkt nach `think_fish(delta)` die Zeile `player_bites()`.
- Die Wirkung eines Bissens Nahrung in eine eigene Funktion auslagern; `feed_player()` sieht danach so aus:
```gdscript
## Frisst, was das Maul berührt und zur Ernährung passt. Wächst der Fisch, wird er größer.
func feed_player() -> void:
	for item in food.take_at(player.mouth_point(), MOUTH_REACH * player.size, player.build.diet):
		eat_value(item["value"])
	hud.show_progress(progress)


## Rechnet einen Bissen Nahrung an; wächst der Fisch dabei, wird er größer.
func eat_value(value: int) -> void:
	if progress.eat(value):
		player.set_size(progress.size())
		hud.show_message("Dein Fisch ist gewachsen!")
```
- Neue Funktion am Ende:
```gdscript
## Fleisch- und Allesfresser beißen Fische, die ihr Maul berührt; besiegte Fische werden gefressen.
func player_bites() -> void:
	if player.build.diet == Diet.PFLANZENFRESSER:
		return
	for f in fishes.duplicate():
		if FishCombat.bite_hits(player.mouth_point(), f.motion.position, f.radius()):
			if f.health.damage(FishAbilities.bite_damage(player.build)) and f.health.is_dead():
				remove_fish(f)
				eat_value(int(FishSpecies.data(f.species_id)["food"]))
				hud.show_progress(progress)
				hud.show_message("%s gefressen!" % FishSpecies.data(f.species_id)["name"])
```
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_main.gd` anhängen. Vor jedem dieser Tests alle KI-Fische entfernen: `for f in fish.fishes.duplicate(): fish.remove_fish(f)`.
- `test_pflanzenfresser_beisst_nicht`: `fish.player.build.diet = Diet.PFLANZENFRESSER`; `var f: AiFish = fish.add_fish("silberling", fish.player.mouth_point())`; `fish.player_bites()` → `f.health.hp` ist `f.health.max_hp`
- `test_biss_verletzt`: `fish.player.build.diet = Diet.FLEISCHFRESSER`; `var f: AiFish = fish.add_fish("zackenbarsch", fish.player.mouth_point())`; `fish.player_bites()` → `f.health.hp` ist `90.0 - 10.0`; `fish.fishes.has(f)` wahr
- `test_besiegt_und_gefressen`: `fish.player.build.diet = Diet.FLEISCHFRESSER`; `var dna: int = fish.progress.dna`; `var f: AiFish = fish.add_fish("silberling", fish.player.mouth_point())`; `f.health.hp = 5.0` → `fish.player_bites()` → `fish.fishes.has(f)` falsch; `fish.progress.dna` ist `dna + 4`
- `test_zu_weit`: `fish.player.build.diet = Diet.FLEISCHFRESSER`; `var f: AiFish = fish.add_fish("silberling", fish.player.mouth_point() + Vector3(5, 0, 0))`; `fish.player_bites()` → `f.health.hp` ist `f.health.max_hp`
