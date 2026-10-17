---
id: T-0074
title: KI-Gegner fahren die anderen Autos
project: drift
priority: 2
after: T-0073
---
## Ziel
Die drei KI-Gegner bekommen in der Rennszene Autos aus dem `CarCatalog`, beginnend mit denen, die der Spieler nicht gewählt hat.

## Dateien
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- In `_ready()` direkt vor der Schleife `for i in AI_COLORS.size():` die Zeile `var opponent_ids := CarCatalog.opponents(GameSettings.car_id, AI_COLORS.size())`
- In der Schleife direkt nach `ai.color = AI_COLORS[i]`: `ai.set_car(opponent_ids[i])`
- Sonst nichts an `main.gd` ändern.

## Tests
In `tests/test_main_wiring.gd` neue Methode `test_gegner_autos`:
- `main.ai_cars.size()` ist 3
- für jedes `i` in 0..2 ist `main.ai_cars[i].car_id` gleich `CarCatalog.opponents(GameSettings.car_id, 3)[i]`
- `main.ai_cars[0].texture != null` ist wahr

Review (16.10.2026): gemergt.
