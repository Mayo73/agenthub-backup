---
id: T-0397
title: SimCommands – Simulation über Befehle starten, pausieren, schrittweise ausführen
project: hub-engine
priority: 3
after: T-0390
---
## Ziel
Meilenstein „Durchstich“ (Lastenheft Muss 5 und 7, Abnahmekriterium 4): Agenten und CLI steuern die Simulation über dieselben Befehle wie die Oberfläche: starten, pausieren, einzelne Schritte, Zustand abfragen.

## Dateien
- `core/sim_commands.gd` – neu, Klasse `SimCommands`
- `tests/test_sim_commands.gd` – neu

## Akzeptanzkriterien
`class_name SimCommands`, `extends RefCounted`:
- `static func register_all(commands: CommandRegistry, clock: SimClock) -> void` registriert:
  - `"sim.start"`, Parameter `{}` → `clock.start()`, `success(clock.state())`
  - `"sim.pause"`, Parameter `{}` → `clock.pause()`, `success(clock.state())`
  - `"sim.step"`, Parameter `{"n": "number"}` → `var n: int = int(args["n"])`; `n < 1` oder `n > 10000` → `CommandResult.error(CommandResult.INVALID_ARGUMENT, "n muss zwischen 1 und 10000 liegen")`; sonst `clock.step(n)` und `success(clock.state())`
  - `"sim.state"`, Parameter `{}` → `success(clock.state())`
  - `"sim.reset"`, Parameter `{}` → `clock.reset()`, `success(clock.state())`
- Beschreibungen auf Deutsch, je ein kurzer Satz.

## Tests
`tests/test_sim_commands.gd`, `setup()`: `CommandRegistry.new()`, `SimClock.new()`, `SimCommands.register_all(...)`.
- `test_start_pause`: `sim.start` → `data["running"]` wahr; `sim.pause` → falsch
- `test_schritte`: `execute("sim.step", {"n": 120})` ok, `data["step"]` 120, `data["time"]` 1.0
- `test_schritte_als_float`: `{"n": 3.0}` (wie aus JSON) → `data["step"]` 3
- `test_ungueltig`: `{"n": 0}` → „invalid_argument“; `{"n": 20000}` → „invalid_argument“; `step_count` bleibt 0
- `test_reset`: 10 Schritte, `sim.reset` → `data["step"]` 0, `data["running"]` falsch

Review (19.10.2026): gemergt.
