---
id: T-0192
title: Schatten und Glanzlicht der Zellen berechnen (CellShading)
project: zellenphase
priority: 3
---
## Ziel
Zellen sollen räumlich wirken (Lastenheft: „räumlich wirkende Zellen“, „mehrere Tiefenebenen“): ein weicher Schatten nach unten rechts und ein Glanzlicht oben links. Das Licht kommt immer von oben links auf dem Bildschirm, auch wenn die Zelle gedreht ist. Hier nur die Berechnung; gezeichnet wird in einem Folgeticket.

## Dateien
- `scripts/cell_shading.gd`: neu
- `tests/test_cell_shading.gd`: neu

## Akzeptanzkriterien
`scripts/cell_shading.gd` genau so:
```gdscript
class_name CellShading
extends RefCounted
## Räumliche Wirkung der Zellen: Schatten nach unten rechts, Glanzlicht oben links.
## Das Licht kommt immer von oben links auf dem Bildschirm, auch wenn die Zelle gedreht ist.

const SHADOW_OFFSET := Vector2(0.12, 0.16)
const SHADOW_COLOR := Color(0.0, 0.05, 0.1, 0.35)
const HIGHLIGHT_POS := Vector2(-0.35, -0.4)
const HIGHLIGHT_SIZE := 0.28


## Versatz des Schattens in Pixeln, im Koordinatensystem der um rotation gedrehten Zelle.
static func shadow_offset(radius: float, rotation: float) -> Vector2:
	return (SHADOW_OFFSET * radius).rotated(-rotation)


## Mitte des Glanzlichts in Pixeln, im Koordinatensystem der um rotation gedrehten Zelle.
static func highlight_center(radius: float, rotation: float) -> Vector2:
	return (HIGHLIGHT_POS * radius).rotated(-rotation)


static func highlight_radius(radius: float) -> float:
	return radius * HIGHLIGHT_SIZE


static func highlight_color(look: CellLook) -> Color:
	var c := look.color.lightened(0.6)
	c.a = 0.35
	return c
```

## Tests
`tests/test_cell_shading.gd` mit `extends "res://tests/base_test.gd"`:
- `test_schatten`: `CellShading.shadow_offset(10.0, 0.0).is_equal_approx(Vector2(1.2, 1.6))` wahr
- `test_schatten_gedreht`: `CellShading.shadow_offset(10.0, PI / 2.0).is_equal_approx(Vector2(1.6, -1.2))` wahr
- `test_glanzlicht`: `CellShading.highlight_center(10.0, 0.0).is_equal_approx(Vector2(-3.5, -4.0))` wahr; `CellShading.highlight_radius(10.0)` ist 2.8
- `test_glanzfarbe`: `var l := CellLook.new()`, `l.color = Color(0, 0, 0)` → `CellShading.highlight_color(l).is_equal_approx(Color(0.6, 0.6, 0.6, 0.35))` wahr

Review (17.10.2026): gemergt, nachgebessert: Tippfehler im Kommentar (gedrohten → gedrehten).
