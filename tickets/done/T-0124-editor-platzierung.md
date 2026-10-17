---
id: T-0124
title: Umrechnung und Auswahl im Editor (EditorPlacement)
project: zellenphase
priority: 3
---
## Ziel
Hilfsfunktionen für die Editor-Ansicht: Bildschirmpunkte in Teil-Lagen (Zellradien) umrechnen, Teile am Zellkörper halten, das Teil unter dem Mauszeiger finden und Drehwinkel einrasten.

## Dateien
- `scripts/editor_placement.gd`: neu
- `tests/test_editor_placement.gd`: neu

## Akzeptanzkriterien
`scripts/editor_placement.gd` genau so:
```gdscript
class_name EditorPlacement
extends RefCounted
## Umrechnung und Auswahl im Zelleditor. Lagen in Zellradien (wie CellBuild), Blick nach +x.

## Teile dürfen höchstens so weit von der Mitte weg sitzen (1 = Zellrand).
const MAX_DIST := 1.0
## So nah (in Zellradien) muss ein Klick an einem Teil liegen, um es auszuwählen.
const PICK_TOLERANCE := 0.2
const ANGLE_STEP := PI / 8


static func screen_to_local(screen: Vector2, center: Vector2, scale: float) -> Vector2:
	return (screen - center) / scale


static func local_to_screen(local: Vector2, center: Vector2, scale: float) -> Vector2:
	return center + local * scale


static func clamp_to_body(pos: Vector2) -> Vector2:
	if pos.length() > MAX_DIST:
		return pos.normalized() * MAX_DIST
	return pos


## Index des Teils, das local am nächsten liegt (höchstens PICK_TOLERANCE entfernt), sonst -1.
static func part_at(build: CellBuild, local: Vector2) -> int:
	var best := -1
	var best_dist := PICK_TOLERANCE
	for i in build.parts.size():
		var pos: Vector2 = build.parts[i]["pos"]
		var d := local.distance_to(pos)
		if d <= best_dist:
			best = i
			best_dist = d
	return best


## Rastet einen Winkel auf Vielfache von ANGLE_STEP ein.
static func snap_angle(angle: float) -> float:
	return roundf(angle / ANGLE_STEP) * ANGLE_STEP
```

## Tests
`tests/test_editor_placement.gd` mit `extends "res://tests/base_test.gd"`:
- `test_umrechnen`: `EditorPlacement.screen_to_local(Vector2(300, 200), Vector2(200, 200), 100.0)` ist (1, 0); `EditorPlacement.local_to_screen(Vector2(0, -0.5), Vector2(200, 200), 100.0)` ist (200, 150)
- `test_am_koerper`: `EditorPlacement.clamp_to_body(Vector2(2, 0))` ist (1, 0); `clamp_to_body(Vector2(0.3, 0.4))` ist (0.3, 0.4)
- `test_auswahl`: `var b := CellBuild.starter(Diet.PFLANZENFRESSER)` (Maul bei (1, 0), Auge bei (0.4, 0)) → `EditorPlacement.part_at(b, Vector2(0.95, 0.05))` ist 0; `part_at(b, Vector2(0.42, 0))` ist 1; `part_at(b, Vector2(-0.8, 0))` ist -1
- `test_einrasten`: `EditorPlacement.snap_angle(0.4)` ist `PI / 8`; `snap_angle(-0.1)` ist 0.0

Review (16.10.2026): gemergt.
