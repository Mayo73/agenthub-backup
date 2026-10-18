---
id: T-0310
title: Raubfische fliehen vor einem deutlich größeren Spielerfisch
project: zellenphase
priority: 2
---
## Ziel
Auftrag „Fischphase – lebendige Welt“: Wie in der Zellenphase sollen frühere Bedrohungen später zur Beute werden. Ist der Spielerfisch deutlich größer als ein Raubfisch, flieht der Raubfisch.

## Dateien
- `scripts/fish_brain.gd`
- `tests/test_fish_brain.gd` – Tests anhängen

## Akzeptanzkriterien
- Neue Konstante direkt unter `const FLEE_FACTOR := 0.8`:
```gdscript
## Raubfische fliehen, wenn der Spieler mindestens so viel größer ist (Vielfaches der eigenen Größe).
const HUNTER_FLEE_FACTOR := 1.2
```
- In `decide()` den Zweig für `"jaeger"` so ändern:
```gdscript
		if behavior == "jaeger":
			if player_size < own_size:
				return (player_pos - own_pos).normalized()
			if player_size >= own_size * HUNTER_FLEE_FACTOR:
				return (own_pos - player_pos).normalized()
```
- Zwischen eigener Größe und dem 1,2-Fachen bleibt der Jäger gleichgültig (Rückgabe wie bisher). Bestehende Tests nicht ändern; `test_jaeger_meidet_grossen` (Spieler 2,0, Jäger 1,8) bleibt grün.
- Sonst nichts ändern.

## Tests
Am Ende von `tests/test_fish_brain.gd` anhängen (dort gibt es `var P := Vector3(0, -20, 0)`):
- `test_jaeger_flieht_vor_riesen`: `FishBrain.decide("jaeger", P, 1.8, 18.0, P + Vector3(10, 0, 0), 2.5, null)` ist `Vector3(-1, 0, 0)`
- `test_jaeger_grenze`: mit Spielergröße `1.8 * FishBrain.HUNTER_FLEE_FACTOR` ist das Ergebnis `Vector3(-1, 0, 0)`; mit Spielergröße 2.1 ist es `Vector3.ZERO`
- `test_riese_ausser_sicht`: Spieler 2,5 bei `P + Vector3(30, 0, 0)` → `Vector3.ZERO`

Review (18.10.2026): gemergt.
