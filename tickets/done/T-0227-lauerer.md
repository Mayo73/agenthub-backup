---
id: T-0227
title: Der Riesenschlund lauert, bis Beute nah ist
project: zellenphase
priority: 3
after: T-0226
---
## Ziel
Der Riesenschlund (Verhalten "lauerer") jagt nicht über weite Strecken, sondern wartet still und stößt erst zu, wenn Beute nah genug ist.

## Dateien
- `scripts/ai_brain.gd`
- `scripts/ai_cell.gd`
- `tests/test_ai_brain.gd` – Tests anhängen
- `tests/test_ai_cell.gd` – Tests anhängen

## Akzeptanzkriterien
- `scripts/ai_brain.gd`:
  - unter `const TREIBEN := "treiben"` die Zeile `const LAUERN := "lauern"`;
  - unter der Konstante `SIGHT`:
```gdscript
## Lauerer stoßen erst zu, wenn Beute näher als so viele Pixel ist.
const LURK_RANGE := 160.0
```
  - unter `var state := TREIBEN` die Zeile `var lurker := false`;
  - in `decide(...)` den Block `if prey_dist < INF:` so ersetzen:
```gdscript
	if prey_dist < INF:
		if lurker and prey_dist > LURK_RANGE:
			state = LAUERN
			return Vector2.ZERO
		state = JAGEN
		return (prey_pos - own_pos).normalized()
```
  - Den Kommentar oben in der Datei (`## Entscheidung einer KI-Zelle: ...`) um den Satz „Lauerer warten, bis Beute nah ist.“ ergänzen.
- `scripts/ai_cell.gd`, `setup(id, pos)`: direkt nach `brain.sight = AiBrain.sight_for(behavior)` die Zeile `brain.lurker = behavior == "lauerer"`.
- Sonst nichts ändern.

## Tests
In `tests/test_ai_brain.gd` anhängen:
- `test_lauern`: `brain.lurker = true`, `var result := brain.decide(Vector2.ZERO, 60.0, Diet.FLEISCHFRESSER, [{"position": Vector2(200, 0), "radius": 12.0, "diet": Diet.PFLANZENFRESSER}], null)` → `result` ist `Vector2.ZERO`; `brain.state` ist `AiBrain.LAUERN`
- `test_lauerer_stoesst_zu`: `brain.lurker = true`, `var result := brain.decide(Vector2.ZERO, 60.0, Diet.FLEISCHFRESSER, [{"position": Vector2(100, 0), "radius": 12.0, "diet": Diet.PFLANZENFRESSER}], null)` → `result` ist `Vector2(1, 0)`; `brain.state` ist `AiBrain.JAGEN`
- `test_ohne_lauern`: `var result := brain.decide(Vector2.ZERO, 60.0, Diet.FLEISCHFRESSER, [{"position": Vector2(200, 0), "radius": 12.0, "diet": Diet.PFLANZENFRESSER}], null)` → `result` ist `Vector2(1, 0)`; `brain.state` ist `AiBrain.JAGEN`

In `tests/test_ai_cell.gd` anhängen (Zellen am Ende mit `free()` freigeben):
- `test_lauerer`: `var a := AiCell.new()`, `a.setup("riesenschlund", Vector2.ZERO)`; `var b := AiCell.new()`, `b.setup("schnapper", Vector2.ZERO)` → `a.brain.lurker` wahr; `b.brain.lurker` falsch

Review (17.10.2026): gemergt.
