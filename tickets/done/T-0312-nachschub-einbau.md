---
id: T-0312
title: Gefressene Fische kommen in der Fischszene nach
project: zellenphase
priority: 3
after: T-0311, T-0309
---
## Ziel
Auftrag „Fischphase – lebendige Welt“: Alle 10 Sekunden ergänzt die Fischszene fehlende Fische außer Sicht des Spielers (Logik aus T-0311), damit das Meer auch nach langem Spielen belebt bleibt.

## Dateien
- `scripts/fish_main.gd`
- `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- Neue Konstante direkt unter `const SAFE_RADIUS := …`:
```gdscript
## Alle so vielen Sekunden kommen fehlende Fische nach.
const RESPAWN_INTERVAL := 10.0
```
- Neue Variable `var respawn_timer := 0.0` unter `var save_path := ""`.
- Neue Funktion direkt unter `remove_fish(f)`:
```gdscript
## Ergänzt fehlende Fische außer Sicht, sobald RESPAWN_INTERVAL Sekunden vergangen sind. Gibt die Zahl neuer Fische zurück.
func refill_fish(delta: float) -> int:
	respawn_timer += delta
	if respawn_timer < RESPAWN_INTERVAL:
		return 0
	respawn_timer = 0.0
	var ids := FishSchool.missing(fishes)
	for i in ids.size():
		add_fish(ids[i], FishSchool.respawn_position(player.motion.position, randi() + i))
	return ids.size()
```
- In `_physics_process(delta)` direkt nach `refill_food()` die Zeile `refill_fish(delta)`.
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_main.gd` anhängen:
- `test_nachschub_wartet`: alle KI-Fische entfernen (`for f in fish.fishes.duplicate(): fish.remove_fish(f)`); `fish.respawn_timer = 0.0`; `fish.refill_fish(1.0)` ist 0; `fish.fishes.size()` ist 0
- `test_nachschub`: alle KI-Fische entfernen; `fish.respawn_timer = 0.0`; `fish.refill_fish(fish.RESPAWN_INTERVAL)` ist gleich der Summe der Werte von `FishSchool.target_counts()`; `FishSchool.missing(fish.fishes)` ist leer; `fish.respawn_timer` ist 0.0
- `test_nachschub_ausser_sicht`: wie `test_nachschub`, danach hat jeder Fisch in `fish.fishes` einen Abstand zu `fish.player.motion.position` von mindestens `FishSchool.MIN_DIST`

Review (18.10.2026): gemergt, nachgebessert: Testkommentar und Variablenname bereinigt.
