---
id: T-0274
title: KI-Fische schwimmen in der Fischszene
project: zellenphase
priority: 4
after: T-0267, T-0273
---
## Ziel
Meilenstein „Fischphase – Leben im Meer“: Beim Start der Fischszene werden die KI-Fische nach `FishSchool.spawn_plan` verteilt und schwimmen in jedem Physikschritt nach ihrem Verhalten (Silberlinge mit ihrem Schwarm).

## Dateien
- `scripts/fish_main.gd`
- `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- In `scripts/fish_main.gd`: Variable `var fishes: Array[AiFish] = []` unter `var evolve: EvolveMenu`.
- In `_ready()` direkt nach dem Block mit `food_view` (nach `world.add_child(food_view)`) die Zeile `spawn_fish()`.
- In `_physics_process(delta)` direkt nach `player.drive(FishInput.read(), delta)` die Zeile `think_fish(delta)`.
- Neue Funktionen am Ende:
```gdscript
## Verteilt die KI-Fische um den Spielerfisch.
func spawn_fish() -> void:
	for entry in FishSchool.spawn_plan(player.motion.position, 7):
		add_fish(entry["id"], entry["position"])


func add_fish(id: String, pos: Vector3) -> AiFish:
	var f := AiFish.new()
	f.setup(id, pos)
	world.add_child(f)
	fishes.append(f)
	return f


func remove_fish(f: AiFish) -> void:
	fishes.erase(f)
	f.queue_free()


## Alle KI-Fische entscheiden und schwimmen; Silberlinge halten sich an ihren Schwarm.
func think_fish(delta: float) -> void:
	var center: Variant = FishSchool.flock_center(fishes, "silberling")
	for f in fishes:
		f.think(delta, player.motion.position, player.size, center if f.species_id == "silberling" else null)
```
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_main.gd` anhängen:
- `test_fische_verteilt`: `fish.fishes.size()` ist 17; jeder Eintrag ist `AiFish` und hat `fish.world` als Elternknoten
- `test_fische_schwimmen`: `var f: AiFish = fish.fishes[0]`; `var vorher: Vector3 = f.motion.position`; zehnmal `fish.think_fish(0.1)` → `f.motion.position != vorher`
- `test_fisch_hinzufuegen_entfernen`: `var f: AiFish = fish.add_fish("grasfisch", Vector3(3, -20, 0))` → `fish.fishes.size()` ist 18; `fish.remove_fish(f)` → 17; `fish.fishes.has(f)` falsch
