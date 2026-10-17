---
id: T-0209
title: Farbvarianten für Zellen derselben Art (ColorVariants)
project: zellenphase
priority: 3
---
## Ziel
Im Lastenheft (Kann) stehen Farbvarianten. Zellen derselben Art sollen sich leicht in Farbton und Helligkeit unterscheiden, damit ein Schwarm lebendiger wirkt. Diese Klasse rechnet die Variante aus; eingebaut wird sie im nächsten Ticket. Die Variante hängt nur von der Startlage ab, damit sie reproduzierbar bleibt.

## Dateien
- `scripts/color_variants.gd`: neu
- `tests/test_color_variants.gd`: neu

## Akzeptanzkriterien
`scripts/color_variants.gd` genau so:
```gdscript
class_name ColorVariants
extends RefCounted
## Leichte Farbvarianten für Zellen derselben Art (Farbton und Helligkeit).

const HUE_SPREAD := 0.03
const VALUE_SPREAD := 0.08


## Variante von c; t von -1 bis 1 (wird begrenzt), 0 = unverändert.
static func vary(c: Color, t: float) -> Color:
	var k := clampf(t, -1.0, 1.0)
	var h := wrapf(c.h + HUE_SPREAD * k, 0.0, 1.0)
	var v := clampf(c.v + VALUE_SPREAD * k, 0.0, 1.0)
	return Color.from_hsv(h, c.s, v, c.a)


## Reproduzierbarer Wert von -1 bis 1 aus einer Lage; (0, 0) ergibt 0.
static func seed_for(pos: Vector2) -> float:
	return sin(pos.x * 0.013 + pos.y * 0.007)
```

## Tests
`tests/test_color_variants.gd` mit `extends "res://tests/base_test.gd"`:
- `test_unveraendert`: `var c := Color.from_hsv(0.5, 0.6, 0.5)` → `ColorVariants.vary(c, 0.0).is_equal_approx(c)` wahr
- `test_heller`: `var v := ColorVariants.vary(Color.from_hsv(0.5, 0.6, 0.5), 1.0)` → `v.h` ist 0.53; `v.v` ist 0.58; `v.s` ist 0.6
- `test_dunkler`: `var v := ColorVariants.vary(Color.from_hsv(0.5, 0.6, 0.5), -1.0)` → `v.h` ist 0.47; `v.v` ist 0.42
- `test_begrenzt`: `ColorVariants.vary(Color.from_hsv(0.5, 0.6, 0.5), 5.0).is_equal_approx(ColorVariants.vary(Color.from_hsv(0.5, 0.6, 0.5), 1.0))` wahr
- `test_farbkreis`: `ColorVariants.vary(Color.from_hsv(0.99, 0.6, 0.5), 1.0).h` ist 0.02
- `test_durchsichtig`: `ColorVariants.vary(Color(0.2, 0.6, 0.4, 0.5), 1.0).a` ist 0.5
- `test_lage`: `ColorVariants.seed_for(Vector2.ZERO)` ist 0.0; `ColorVariants.seed_for(Vector2(100, 0))` ist `sin(1.3)`; `ColorVariants.seed_for(Vector2(37, -90)) >= -1.0` wahr

Review (17.10.2026): gemergt.
