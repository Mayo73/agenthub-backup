---
id: T-0390
title: SimClock – Simulation starten, pausieren und schrittweise ausführen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich: Laufzeit, CLI, Editor, Export“ (Abnahmekriterium 4 „Simulation starten/pausieren/schrittweise ausführen“): ein fester Simulationstakt von 120 Schritten pro Sekunde, unabhängig von der Bildrate. GUI, CLI und Agenten steuern ihn gleich. Reine Logik.

## Dateien
- `core/sim_clock.gd` – neu, Klasse `SimClock`
- `tests/test_sim_clock.gd` – neu

## Akzeptanzkriterien
`class_name SimClock`, `extends RefCounted`:
- `signal stepped(step: int)` – nach jedem ausgeführten Schritt mit der neuen Schrittzahl
- `const HZ := 120`, `const MAX_STEPS_PER_ADVANCE := 12` (schützt vor Endlosschleifen nach langen Pausen)
- `var running := false`, `var step_count := 0`, `var accumulator := 0.0`
- `func start() -> void`, `func pause() -> void` (setzt `running`; `pause` leert auch `accumulator`)
- `func step(n: int = 1) -> int`: führt genau `n` Schritte aus (auch pausiert), `n <= 0` → 0; gibt die Zahl ausgeführter Schritte zurück
- `func advance(delta: float) -> int`: pausiert → 0. Sonst `accumulator += delta`; solange `accumulator >= 1.0 / HZ` und weniger als `MAX_STEPS_PER_ADVANCE` Schritte: einen Schritt ausführen und `accumulator -= 1.0 / HZ`. Wird die Grenze erreicht, `accumulator = 0.0`. Rückgabe: ausgeführte Schritte
- `func time() -> float`: `step_count / float(HZ)`
- `func reset() -> void`: `step_count = 0`, `accumulator = 0.0`, `running = false`
- `func state() -> Dictionary`: `{"running": running, "step": step_count, "time": time()}`

## Tests
`tests/test_sim_clock.gd`, Signal mit einer Methode der Testklasse zählen (`var stepped_count := 0`, in `setup()` auf 0, `clock.stepped.connect(_on_stepped)`; ein Lambda zählt nicht, weil es lokale Variablen nur kopiert):
- `test_pausiert`: `advance(1.0)` → 0, `step_count` 0
- `test_laufen`: `start()`, `advance(0.051)` → 6 (knapp über 6 × 1/120, damit Rundungsfehler nicht stören), `step_count` 6, `stepped_count` 6
- `test_rest_bleibt`: `start()`, `advance(0.004)` → 0; `advance(0.005)` → 1 (zusammen über 1/120)
- `test_grenze`: `start()`, `advance(5.0)` → 12, `accumulator` 0
- `test_einzelschritt`: pausiert `step()` → 1, `step(3)` → 3, `step_count` 4, `time()` etwa 0.0333; `step(0)` → 0
- `test_zustand`: `start()`, `step(120)` → `state()` `running` wahr, `step` 120, `time` 1.0; `reset()` → `step` 0, `running` falsch

Review (19.10.2026): gemergt.
