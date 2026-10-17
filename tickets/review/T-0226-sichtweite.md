---
id: T-0226
title: Sichtweite je Verhalten (scheue Zellen sehen weiter, Lauerer kürzer)
project: zellenphase
priority: 3
after: T-0225
---
## Ziel
Die Verhaltensmuster der Arten sollen sich unterscheiden: Scheue Zellen (Blasenling) bemerken Gefahren früher, der lauernde Riesenschlund sieht nur in der Nähe.

## Dateien
- `scripts/ai_brain.gd`
- `scripts/ai_cell.gd`
- `tests/test_ai_brain.gd` – Tests anhängen
- `tests/test_ai_cell.gd` – Tests anhängen

## Akzeptanzkriterien
- `scripts/ai_brain.gd`: unter `const PREY_FACTOR := 0.8`:
```gdscript
## Sichtweite je Verhaltensmuster in Pixeln; alle anderen sehen 350.
const SIGHT := {"scheu": 450.0, "lauerer": 250.0}
```
  und nach der Zeile `var state := TREIBEN`:
```gdscript


static func sight_for(behavior: String) -> float:
	return float(SIGHT.get(behavior, 350.0))
```
- `scripts/ai_cell.gd`, `setup(id, pos)`: direkt nach `behavior = d["behavior"]` die Zeile `brain.sight = AiBrain.sight_for(behavior)`.
- Sonst nichts ändern.

## Tests
In `tests/test_ai_brain.gd` anhängen:
- `test_sicht_je_verhalten`: `AiBrain.sight_for("scheu")` ist 450.0; `AiBrain.sight_for("lauerer")` ist 250.0; `AiBrain.sight_for("jaeger")` ist 350.0; `AiBrain.sight_for("")` ist 350.0
- `test_scheu_sieht_weiter`: `brain.sight = AiBrain.sight_for("scheu")`, `var result := brain.decide(Vector2.ZERO, 12.0, Diet.PFLANZENFRESSER, [{"position": Vector2(400, 0), "radius": 27.0, "diet": Diet.FLEISCHFRESSER}], null)` → `result` ist `Vector2(-1, 0)`; `brain.state` ist `AiBrain.FLIEHEN`

In `tests/test_ai_cell.gd` anhängen (Zellen am Ende mit `free()` freigeben):
- `test_sichtweite`: `var a := AiCell.new()`, `a.setup("blasenling", Vector2.ZERO)`; `var b := AiCell.new()`, `b.setup("riesenschlund", Vector2.ZERO)`; `var c := AiCell.new()`, `c.setup("schnapper", Vector2.ZERO)` → `a.brain.sight` ist 450.0; `b.brain.sight` ist 250.0; `c.brain.sight` ist 350.0
