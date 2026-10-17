---
id: T-0187
title: Schlagende Wimpern und pulsierende Düse berechnen (PartAnimation)
project: zellenphase
priority: 3
---
## Ziel
Neben der Geißel sollen auch Wimpern und Düse animiert sein (Lastenheft: „animierte Körperteile“). `PartAnimation` bekommt dafür zwei neue Funktionen.

## Dateien
- `scripts/part_animation.gd`
- `tests/test_part_animation.gd`: neue Tests anhängen, bestehende nicht ändern

## Akzeptanzkriterien
In `scripts/part_animation.gd`:
- Neue Konstanten direkt unter `const FLAGELLUM_SPEED := 10.0`:
```gdscript
const CILIA_COUNT := 5
const CILIA_LENGTH := 0.3
const CILIA_SPREAD := 0.5
const CILIA_SPEED := 12.0
const JET_PULSE := 0.15
const JET_SPEED := 8.0
```
- Neue Funktionen am Ende:
```gdscript
## Wimpern nebeneinander, je ein Linienzug aus Ansatz und Spitze (in Zellradien, nach -x zeigend).
## Sie schlagen versetzt hin und her.
static func cilia(time: float) -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = []
	for i in CILIA_COUNT:
		var y := CILIA_SPREAD * (float(i) / (CILIA_COUNT - 1) - 0.5)
		var swing := 0.6 * sin(time * CILIA_SPEED + i * 1.2)
		var base := Vector2(0, y)
		out.append(PackedVector2Array([base, base + Vector2(-CILIA_LENGTH, 0).rotated(swing)]))
	return out


## Größenfaktor der Düse, pulsiert zwischen 1 - JET_PULSE und 1 + JET_PULSE.
static func jet_scale(time: float) -> float:
	return 1.0 + JET_PULSE * sin(time * JET_SPEED)
```
- Sonst nichts ändern.

## Tests
In `tests/test_part_animation.gd` anhängen:
- `test_wimpern_anzahl`: `var c := PartAnimation.cilia(0.0)` → `c.size()` ist 5; `c[0].size()` ist 2
- `test_wimpern_ansatz`: `var c := PartAnimation.cilia(0.7)` → `c[0][0].is_equal_approx(Vector2(0, -0.25))` wahr; `c[4][0].is_equal_approx(Vector2(0, 0.25))` wahr
- `test_wimpern_laenge`: für `t` in `[0.0, 0.4, 1.3]` und jede Wimper `w` aus `PartAnimation.cilia(t)`: `w[0].distance_to(w[1])` liegt zwischen 0.299 und 0.301
- `test_wimpern_schlagen`: `PartAnimation.cilia(0.0)[2][1].is_equal_approx(PartAnimation.cilia(0.1)[2][1])` falsch
- `test_duese`: `PartAnimation.jet_scale(0.0)` ist 1.0; `PartAnimation.jet_scale(PI / 16.0)` ist 1.15

Review (17.10.2026): gemergt.
