---
id: T-0045
title: Platzierung berechnen (LapTimer.distance, RaceRanking)
project: drift
priority: 3
---
## Ziel
Für die Platzierung im Rennen muss man vergleichen können, wer schon weiter gefahren ist. `LapTimer` liefert dafür die insgesamt gefahrene Strecke, und eine kleine Klasse `RaceRanking` rechnet daraus den Platz.

## Dateien
- `scripts/lap_timer.gd`: neue Funktion `distance()`, sonst nichts ändern
- `scripts/race_ranking.gd`: neu, beginnt mit `class_name RaceRanking` und `extends RefCounted`
- `tests/test_race_ranking.gd`: neu

## Akzeptanzkriterien
- In `lap_timer.gd`:
  ```gdscript
  ## Gefahrene Strecke seit dem Start über alle Runden (für die Platzierung).
  ## Steht man vor der ersten Rennhälfte noch hinter der Ziellinie, zählt das negativ.
  func distance() -> float:
  	var p := maxf(_prev_progress, 0.0)
  	if not _half_passed and p > track_length * 0.5:
  		p -= track_length
  	return lap * track_length + p
  ```
- In `race_ranking.gd`:
  ```gdscript
  ## Platz (1 = vorn) eines Fahrers mit `own` gefahrener Strecke gegen die Strecken der anderen.
  static func place(own: float, others: Array) -> int:
  	var result := 1
  	for other in others:
  		if float(other) > own:
  			result += 1
  	return result
  ```

## Tests
Neue Datei `tests/test_race_ranking.gd` mit `extends "res://tests/base_test.gd"`:
- `test_strecke_erste_runde`: `var t := LapTimer.new(1000.0)`, `t.update(0.1, 100.0)` → `t.distance()` ist 100.0
- `test_hinter_der_ziellinie`: `var t := LapTimer.new(1000.0)`, `t.update(0.1, 950.0)` → `t.distance()` ist -50.0
- `test_nach_einer_runde`: `var t := LapTimer.new(1000.0)`, nacheinander `t.update(1.0, 100.0)`, `t.update(1.0, 500.0)`, `t.update(1.0, 900.0)`, `t.update(1.0, 50.0)` → `t.lap` ist 1 und `t.distance()` ist 1050.0
- `test_platz`: `RaceRanking.place(500.0, [100.0, 600.0, 300.0])` ist 2; `RaceRanking.place(700.0, [100.0, 600.0])` ist 1; `RaceRanking.place(0.0, [10.0, 20.0, 30.0])` ist 4

Review (16.10.2026): gemergt.
