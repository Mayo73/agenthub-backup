---
id: T-0013
title: Geisterauto – Runde aufnehmen (GhostLap)
project: drift
priority: 3
---
## Ziel
Für das Geisterauto muss eine gefahrene Runde aufgezeichnet werden. Neue Klasse `GhostLap` speichert in festen Abständen Position und Fahrtrichtung des Autos samt Zeitpunkt in der Runde. Nur Logik und Tests, noch nicht ins Spiel einbauen.

## Dateien
- `scripts/ghost_lap.gd`: neu, beginnt mit `class_name GhostLap` und `extends RefCounted`
- `tests/test_ghost_lap.gd`: neu

## Akzeptanzkriterien
- `const SAMPLE_INTERVAL := 0.05` (Sekunden zwischen zwei Proben)
- Variablen: `var times := PackedFloat32Array()`, `var positions := PackedVector2Array()`, `var headings := PackedFloat32Array()`
- `func record(time: float, position: Vector2, heading: float) -> void`: hängt `time`, `position` und `heading` an die drei Arrays an, **wenn** noch keine Probe da ist **oder** `time - times[times.size() - 1] >= SAMPLE_INTERVAL - 0.0001`. Sonst nichts tun.
- `func sample_count() -> int`: Anzahl der Proben (`times.size()`).
- `func duration() -> float`: Zeit der letzten Probe, `0.0` wenn leer.
- `func is_empty() -> bool`: wahr, wenn keine Probe da ist.

## Tests
Neue Datei `tests/test_ghost_lap.gd` mit `extends "res://tests/base_test.gd"`, Variable `var ghost: GhostLap`, in `setup()` `ghost = GhostLap.new()`:
- `test_neu_ist_leer`: `is_empty()` wahr, `sample_count()` 0, `duration()` 0.0
- `test_erste_probe_immer`: `record(0.0, Vector2(1, 2), 0.5)` → `sample_count()` 1, `positions[0]` ist `Vector2(1, 2)`, `headings[0]` ist 0.5, `is_empty()` falsch
- `test_zu_dichte_probe_wird_ausgelassen`: `record(0.0, Vector2.ZERO, 0.0)`, `record(0.02, Vector2(5, 0), 0.0)` → `sample_count()` 1; dann `record(0.05, Vector2(10, 0), 0.0)` → `sample_count()` 2, `positions[1]` ist `Vector2(10, 0)`
- `test_dauer`: `record(0.0, Vector2.ZERO, 0.0)`, `record(0.1, Vector2.ZERO, 0.0)`, `record(0.2, Vector2.ZERO, 0.0)` → `duration()` ist 0.2, `sample_count()` 3

Review (16.10.2026): gemergt.
