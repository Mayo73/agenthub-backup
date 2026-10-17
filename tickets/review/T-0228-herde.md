---
id: T-0228
title: Weidezellen schwimmen zu ihrer Herde
project: zellenphase
priority: 3
after: T-0227
---
## Ziel
Weidezellen (Verhalten "herde") halten zusammen: Sehen sie keine Gefahr, keine Beute und keine Nahrung, schwimmen sie zur Mitte der anderen Herdenzellen in Sichtweite.

## Dateien
- `scripts/ai_brain.gd`
- `scripts/ai_cell.gd`
- `tests/test_ai_brain.gd` – Tests anhängen
- `tests/test_ai_cell.gd` – Tests anhängen

## Akzeptanzkriterien
- `scripts/ai_brain.gd`:
  - unter `const LAUERN := "lauern"` die Zeile `const HERDE := "herde"`;
  - unter `const LURK_RANGE := 160.0`:
```gdscript
## Herdenzellen bleiben innerhalb so vieler eigener Radien von der Herdenmitte.
const HERD_DIST := 3.0
```
  - unter `var lurker := false` die Zeile `var herd := false`;
  - in `decide(...)`: vor der Schleife `for other in others:` die Zeilen `var herd_sum := Vector2.ZERO` und `var herd_count := 0`; in der Schleife direkt nach der Sichtprüfung (`if dist > sight or dist < 0.001:` / `continue`):
```gdscript
		if other.get("herd", false):
			herd_sum += pos
			herd_count += 1
```
  - direkt vor den letzten beiden Zeilen der Funktion (`state = TREIBEN` und `return Vector2.ZERO`):
```gdscript
	if herd and herd_count > 0:
		var center := herd_sum / herd_count
		if own_pos.distance_to(center) > own_radius * HERD_DIST:
			state = HERDE
			return (center - own_pos).normalized()
```
  - Den Kommentar über `decide` zu `others` um den optionalen Schlüssel `"herd"` (bool, Herdenzelle) ergänzen.
- `scripts/ai_cell.gd`:
  - `setup(id, pos)`: direkt nach `brain.lurker = behavior == "lauerer"` die Zeile `brain.herd = behavior == "herde"`;
  - `info()` gibt zusätzlich den Schlüssel `"herd"` zurück: `return {"position": motion.position, "radius": radius, "diet": diet, "herd": brain.herd}`.
- Sonst nichts ändern.

## Tests
In `tests/test_ai_brain.gd` anhängen:
- `test_zur_herde`: `brain.herd = true`, `var result := brain.decide(Vector2.ZERO, 40.0, Diet.PFLANZENFRESSER, [{"position": Vector2(200, 0), "radius": 40.0, "diet": Diet.PFLANZENFRESSER, "herd": true}, {"position": Vector2(200, 100), "radius": 40.0, "diet": Diet.PFLANZENFRESSER, "herd": true}], null)` → `result.is_equal_approx(Vector2(200, 50).normalized())` wahr; `brain.state` ist `AiBrain.HERDE`
- `test_herde_nah_genug`: `brain.herd = true`, `var result := brain.decide(Vector2.ZERO, 40.0, Diet.PFLANZENFRESSER, [{"position": Vector2(50, 0), "radius": 40.0, "diet": Diet.PFLANZENFRESSER, "herd": true}], null)` → `result` ist `Vector2.ZERO`; `brain.state` ist `AiBrain.TREIBEN`
- `test_nahrung_vor_herde`: `brain.herd = true`, `var result := brain.decide(Vector2.ZERO, 40.0, Diet.PFLANZENFRESSER, [{"position": Vector2(200, 0), "radius": 40.0, "diet": Diet.PFLANZENFRESSER, "herd": true}], Vector2(0, 100))` → `result` ist `Vector2(0, 1)`; `brain.state` ist `AiBrain.SUCHEN`
- `test_keine_herdenzelle`: ohne `brain.herd` zu setzen: `brain.decide(Vector2.ZERO, 40.0, Diet.PFLANZENFRESSER, [{"position": Vector2(200, 0), "radius": 40.0, "diet": Diet.PFLANZENFRESSER, "herd": true}], null)` → `brain.state` ist `AiBrain.TREIBEN`

In `tests/test_ai_cell.gd` anhängen (Zellen am Ende mit `free()` freigeben):
- `test_herde`: `var a := AiCell.new()`, `a.setup("weidezelle", Vector2.ZERO)`; `var b := AiCell.new()`, `b.setup("blasenling", Vector2.ZERO)` → `a.brain.herd` wahr; `a.info()["herd"]` wahr; `b.info()["herd"]` falsch
