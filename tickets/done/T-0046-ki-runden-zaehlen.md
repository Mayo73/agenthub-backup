---
id: T-0046
title: KI-Autos zählen ihre Runden
project: drift
priority: 3
after: T-0041, T-0045
---
## Ziel
Für die Platzierung muss jedes KI-Auto wissen, wie weit es schon gefahren ist. Es bekommt dafür einen eigenen `LapTimer`.

## Dateien
- `scripts/ai_car.gd`
- `tests/test_ai_car.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- Neue Variable `var lap_timer: LapTimer`
- Am Ende von `place_at(...)`: `lap_timer = LapTimer.new(track.length) if track else null`
- In `_physics_process` ganz am Ende:
  ```gdscript
  	if driving_enabled and lap_timer:
  		lap_timer.update(delta, track.progress_at(physics.position))
  ```
- Neue Funktion:
  ```gdscript
  ## Insgesamt gefahrene Strecke (für die Platzierung).
  func race_distance() -> float:
  	return lap_timer.distance() if lap_timer else 0.0
  ```

## Tests
In `tests/test_ai_car.gd` neue Methode `test_zaehlt_strecke` anhängen:
- `ai.place_at(ai.track.start_position(), ai.track.start_heading())` → `ai.lap_timer != null` ist wahr, `ai.race_distance()` ist 0.0
- `ai.driving_enabled = true`, 120-mal `ai._physics_process(1.0 / 60.0)` → `ai.race_distance() > 100.0`
- `ai.place_at(ai.track.start_position(), ai.track.start_heading())` → `ai.race_distance()` ist wieder 0.0

Review (16.10.2026): gemergt.
