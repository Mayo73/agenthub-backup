---
id: T-0121
title: Symmetrie im Zelleditor (EditorSymmetry)
project: zellenphase
priority: 3
after: T-0115
---
## Ziel
Wie im Spore-Editor werden Teile abseits der Längsachse automatisch gespiegelt eingebaut. Teile auf der Achse (z. B. ein Maul ganz vorn) gibt es nur einmal.

## Dateien
- `scripts/editor_symmetry.gd`: neu
- `tests/test_editor_symmetry.gd`: neu

## Akzeptanzkriterien
`scripts/editor_symmetry.gd` genau so:
```gdscript
class_name EditorSymmetry
extends RefCounted
## Spiegelt Teile an der Längsachse der Zelle (Blickrichtung +x), wie die Symmetrie im Spore-Editor.

## Teile, die so nah an der Achse liegen (in Zellradien), werden nicht gespiegelt.
const AXIS_TOLERANCE := 0.05


static func is_on_axis(pos: Vector2) -> bool:
	return absf(pos.y) <= AXIS_TOLERANCE


static func mirror_pos(pos: Vector2) -> Vector2:
	return Vector2(pos.x, -pos.y)


static func mirror_angle(angle: float) -> float:
	return -angle


## Baut ein Teil ein und abseits der Achse zusätzlich sein Spiegelbild.
## Gibt die Indizes der eingebauten Teile zurück; leer, wenn das Teil gesperrt ist.
static func place_mirrored(session: EditorSession, id: String, pos: Vector2, angle: float = 0.0) -> Array[int]:
	var result: Array[int] = []
	var first := session.place(id, pos, angle)
	if first < 0:
		return result
	result.append(first)
	if not is_on_axis(pos):
		result.append(session.place(id, mirror_pos(pos), mirror_angle(angle)))
	return result
```

## Tests
`tests/test_editor_symmetry.gd` mit `extends "res://tests/base_test.gd"`, `var s: EditorSession`; `setup()`: `var u := PartUnlocks.new()`, `u.unlock("geissel")`, `s = EditorSession.new(CellBuild.starter(Diet.PFLANZENFRESSER), u)`.
- `test_achse`: `EditorSymmetry.is_on_axis(Vector2(1, 0.02))` wahr; `is_on_axis(Vector2(0, 0.5))` falsch; `EditorSymmetry.mirror_pos(Vector2(-0.8, 0.6))` ist (-0.8, -0.6); `mirror_angle(0.3)` ist -0.3
- `test_gespiegelt_einbauen`: `var idx := EditorSymmetry.place_mirrored(s, "geissel", Vector2(-0.8, 0.6), 0.3)` → `idx.size()` ist 2, `idx[0]` ist 2, `idx[1]` ist 3; `s.working.parts[3]["pos"]` ist (-0.8, -0.6); `s.working.parts[3]["angle"]` ist -0.3; `s.cost()` ist 30
- `test_auf_der_achse_einmal`: `EditorSymmetry.place_mirrored(s, "kiefer", Vector2(1, 0.02)).size()` ist 1; `s.cost()` ist 10
- `test_gesperrt`: `EditorSymmetry.place_mirrored(s, "stachel", Vector2(0, 1)).size()` ist 0; `s.working.parts.size()` ist 2

Review (16.10.2026): gemergt, nachgebessert: irreführende Testmeldung zu den Kosten korrigiert.
