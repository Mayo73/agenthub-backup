---
id: T-0011
title: Rennablauf in main.gd verdrahten
project: drift
priority: 3
after: T-0009, T-0010
---
## Ziel
`main.gd` bekommt einen `RaceState` (T-0009): Während des Countdowns und nach dem Ziel ist das Auto gesperrt (`car.input_enabled` aus T-0010), Punkte und Rundenzeit zählen nur im Rennen, jede fertige Runde geht an den `RaceState`, und nach dem Ziel startet die Taste `neustart` ein neues Rennen. Die Anzeige kommt in einem späteren Ticket.

## Dateien
- `scripts/main.gd`
- `tests/test_main_wiring.gd`: neuer Test anhängen, bestehenden Test nicht ändern

## Akzeptanzkriterien
- Neue Variable in `main.gd`: `var race := RaceState.new()`
- Am Ende von `_ready()`:
  - `lap_timer.lap_completed.connect(_on_lap_completed)`
  - `car.input_enabled = race.can_drive()`
- Neue Funktion `func _on_lap_completed(_lap_number: int, time: float, _is_best: bool) -> void:` ruft `race.on_lap(time)`.
- Neue Funktion `func restart() -> void:` ruft `race.reset()`, `scorer.reset()`, `lap_timer.reset()`, `car.place_at_start()` und setzt `car.input_enabled = race.can_drive()`.
- `_physics_process(delta)`:
  - ganz am Anfang: `race.update(delta)` und `car.input_enabled = race.can_drive()`
  - `scorer.update(...)` und `lap_timer.update(...)` nur aufrufen, wenn `race.phase == RaceState.Phase.RACING`
  - Kamera und HUD-Aufrufe bleiben wie bisher.
  - am Ende: `if race.phase == RaceState.Phase.FINISHED and Input.is_action_just_pressed("neustart"): restart()`

## Tests
In `tests/test_main_wiring.gd` neue Methode `test_rennablauf_ist_verdrahtet` anhängen:
- `main.race is RaceState` ist wahr
- `main.car.input_enabled` ist falsch (Countdown läuft)
- `main.lap_timer.lap_completed.is_connected(main._on_lap_completed)` ist wahr
- `main.race.phase = RaceState.Phase.FINISHED`, `main.scorer.total = 500`, `main.restart()` → `main.race.phase` ist `RaceState.Phase.COUNTDOWN`, `main.scorer.total` ist 0

Review (15.10.2026): gemergt; Konflikt mit T-0007 in main.gd selbst aufgelöst, Einrückung im Test auf Tabs korrigiert. Nachgebessert: Neustart löscht auch die Reifenspuren.
