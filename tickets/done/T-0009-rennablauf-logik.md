---
id: T-0009
title: Rennablauf-Logik (Countdown, 3 Runden, Ergebnis)
project: drift
priority: 3
---
## Ziel
Neue Klasse `RaceState`, die den Ablauf eines Rennens verwaltet: 3 Sekunden Countdown, dann 3 Runden fahren, danach ist das Rennen beendet und es gibt einen Ergebnistext. Nur Logik und Tests, noch nicht ins Spiel einbauen.

## Dateien
- `scripts/race_state.gd`: neu, beginnt mit `class_name RaceState` und `extends RefCounted`
- `tests/test_race_state.gd`: neu

## Akzeptanzkriterien
- `enum Phase { COUNTDOWN, RACING, FINISHED }`
- Konstanten: `const COUNTDOWN_SECONDS := 3.0`, `const TOTAL_LAPS := 3`
- Variablen mit Startwerten:
  - `var phase: Phase = Phase.COUNTDOWN`
  - `var countdown: float = COUNTDOWN_SECONDS` (verbleibende Countdown-Sekunden)
  - `var race_time: float = 0.0` (Sekunden seit dem Start, nur während `RACING`)
  - `var lap_times: Array[float] = []`
- `func update(delta: float) -> void`:
  - `COUNTDOWN`: `countdown -= delta`. Ist `countdown <= 0.0`: `countdown = 0.0` und `phase = Phase.RACING`.
  - `RACING`: `race_time += delta`.
  - `FINISHED`: nichts.
- `func on_lap(time: float) -> void`: Nur in `RACING`: `time` an `lap_times` anhängen; hat `lap_times` danach `TOTAL_LAPS` Einträge, `phase = Phase.FINISHED`. In anderen Phasen nichts tun.
- `func can_drive() -> bool`: wahr genau dann, wenn `phase == Phase.RACING`.
- `func countdown_text() -> String`:
  - `COUNTDOWN`: `str(ceili(countdown))`, also `"3"`, `"2"` oder `"1"`
  - `RACING` und `race_time < 1.0`: `"Los!"`
  - sonst `""`
- `func best_lap() -> float`: kleinster Wert in `lap_times`, `-1.0` wenn leer.
- `func result_text(points: int) -> String`: genau
  `"Ziel!\nGesamtzeit %s\nBeste Runde %s\nPunkte %d\nEnter: neues Rennen" % [LapTimer.format_time(race_time), LapTimer.format_time(best_lap()), points]`
- `func reset() -> void`: alle Variablen auf ihre Startwerte (`lap_times` leeren).

## Tests
Neue Datei `tests/test_race_state.gd` mit `extends "res://tests/base_test.gd"`, in `setup()` `race = RaceState.new()` (Variable `var race: RaceState`):
- `test_start_im_countdown`: `phase` ist `RaceState.Phase.COUNTDOWN`, `can_drive()` ist falsch, `countdown_text()` ist `"3"`
- `test_countdown_text`: `update(0.5)` → `countdown_text()` ist `"3"`; `update(1.0)` → `"2"`; `update(1.0)` → `"1"`
- `test_countdown_endet`: `update(1.0)` dreimal → `phase` ist `RACING`, `can_drive()` ist wahr, `countdown` ist 0.0, `countdown_text()` ist `"Los!"`
- `test_los_verschwindet`: `update(3.0)`, dann `update(1.5)` → `countdown_text()` ist `""` und `race_time` ist 1.5
- `test_runde_im_countdown_zaehlt_nicht`: `on_lap(10.0)` ohne vorheriges `update` → `lap_times.size()` ist 0
- `test_drei_runden_beenden_rennen`: `update(3.0)`, dann `on_lap(30.0)`, `on_lap(28.5)` → `phase` ist `RACING`; `on_lap(29.0)` → `phase` ist `FINISHED`, `can_drive()` ist falsch, `best_lap()` ist 28.5
- `test_nach_ziel_keine_zeit_mehr`: `update(3.0)`, `update(10.0)`, dreimal `on_lap(5.0)`, `update(7.0)` → `race_time` ist 10.0, `lap_times.size()` ist 3
- `test_ergebnistext`: `update(3.0)`, `update(87.5)`, `on_lap(30.0)`, `on_lap(28.5)`, `on_lap(29.0)` → `result_text(1234)` ist `"Ziel!\nGesamtzeit 1:27.50\nBeste Runde 0:28.50\nPunkte 1234\nEnter: neues Rennen"`
- `test_reset`: `update(3.0)`, `on_lap(30.0)`, `reset()` → `phase` ist `COUNTDOWN`, `countdown` ist 3.0, `race_time` ist 0.0, `lap_times.size()` ist 0, `best_lap()` ist -1.0

Review (15.10.2026): gemergt.
