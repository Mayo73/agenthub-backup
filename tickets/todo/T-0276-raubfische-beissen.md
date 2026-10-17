---
id: T-0276
title: Raubfische beißen den Spielerfisch, Gesundheit in der Anzeige
project: zellenphase
priority: 4
after: T-0275
---
## Ziel
Meilenstein „Fischphase – Leben im Meer“: Zackenbarsche sind eine Gefahr. Berührt ihr Maul den Spielerfisch, verliert er Gesundheit; Stacheln wehren einen Teil ab und verletzen den Angreifer. Die Anzeige zeigt die Gesundheit.

## Dateien
- `scripts/fish_main.gd`
- `scripts/fish_hud.gd`
- `tests/test_fish_main.gd` – Tests anhängen
- `tests/test_fish_hud.gd` – Tests anhängen

## Akzeptanzkriterien
- `scripts/fish_hud.gd`: neue Variable `var health_label: Label`; in `_init()` nach `growth_label = ...` die Zeile `health_label = make_label("Health", Vector2(40, 156), 28)` und danach `show_health(1.0)`. Neue Funktionen:
```gdscript
static func health_text(ratio: float) -> String:
	return "Gesundheit: %d %%" % roundi(clampf(ratio, 0.0, 1.0) * 100.0)


func show_health(ratio: float) -> void:
	health_label.text = health_text(ratio)
```
- `scripts/fish_main.gd`:
  - Variable `var player_health := CellHealth.new(100.0)` unter `var fishes: Array[AiFish] = []`.
  - In `_physics_process(delta)` direkt nach `player_bites()`:
```gdscript
	predators_bite()
	player_health.tick(delta)
	hud.show_health(player_health.ratio())
```
  - Neue Funktion am Ende:
```gdscript
## Raubfische beißen, wenn ihr Maul den Spielerfisch berührt; Stacheln wehren ab und verletzen sie.
func predators_bite() -> void:
	for f in fishes.duplicate():
		if not FishSpecies.is_predator(f.species_id):
			continue
		if FishCombat.bite_hits(f.mouth_point(), player.motion.position, 0.5 * player.size):
			var raw := float(FishSpecies.data(f.species_id)["bite"])
			if player_health.damage(FishCombat.damage_to_player(raw, player.build)):
				f.health.damage(FishCombat.spike_reflect(player.build))
				if f.health.is_dead():
					remove_fish(f)
```
- Sonst nichts ändern.

## Tests
- `tests/test_fish_hud.gd`, anhängen: `test_gesundheit_text`: `FishHud.health_text(1.0)` ist `"Gesundheit: 100 %"`; `health_text(0.456)` ist `"Gesundheit: 46 %"`; `health_text(-1.0)` ist `"Gesundheit: 0 %"`; ein neues `FishHud` hat `health_label.text` `"Gesundheit: 100 %"` (danach `free()`)
- `tests/test_fish_main.gd`, anhängen; vor jedem Test alle KI-Fische entfernen (`for f in fish.fishes.duplicate(): fish.remove_fish(f)`):
  - `test_raubfisch_beisst`: Zackenbarsch so setzen, dass sein Maul den Spieler berührt: `var f: AiFish = fish.add_fish("zackenbarsch", fish.player.motion.position + Vector3(0, 0, 1.5))` (er schaut nach -z, sein Maul liegt 1,44 m vor ihm); `fish.predators_bite()` → `fish.player_health.hp` ist 85.0
  - `test_stacheln_wehren_ab`: `fish.player.build.levels["stacheln"] = 2`; Zackenbarsch wie oben; `fish.predators_bite()` → `fish.player_health.hp` ist `100.0 - 15.0 * 0.7` (Toleranz 0,001); `f.health.hp` ist `90.0 - 12.0`
  - `test_beute_beisst_nicht`: `fish.add_fish("grasfisch", fish.player.motion.position + Vector3(0, 0, 1.0))`; `fish.predators_bite()` → `fish.player_health.hp` ist 100.0
  - `test_anzeige`: `fish.player_health.hp = 50.0`; `fish._physics_process(0.016)` → `fish.hud.health_label.text` ist `"Gesundheit: 50 %"`
