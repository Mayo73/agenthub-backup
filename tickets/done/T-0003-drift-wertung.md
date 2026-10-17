---
id: T-0003
title: Drift-Wertung mit Kombo
project: drift
priority: 2
---
## Ziel
Neue Klasse `DriftScorer`, die aus dem Fahrzustand Drift-Punkte berechnet: Lange, weite, schnelle Drifts bringen Punkte, direkt aufeinanderfolgende Drifts erhöhen die Kombo, ein Abflug von der Strecke kostet den laufenden Drift. Nur Logik und Tests, noch nicht ins Spiel einbauen.

## Dateien
- `scripts/drift_scorer.gd`: neu, beginnt mit `class_name DriftScorer` und `extends RefCounted`
- `tests/test_drift_scorer.gd`: neu

## Akzeptanzkriterien
- Konstanten: `const MIN_ANGLE := 12.0`, `const MIN_SPEED := 150.0`, `const CHAIN_TIME := 1.5`, `const MAX_COMBO := 5`
- Variablen: `var total := 0` (gesicherte Punkte), `var current := 0.0` (Punkte des laufenden Drifts), `var combo := 1`, `var drifting := false`
- Signale: `signal drift_banked(points: int)` und `signal drift_failed`
- `func update(delta: float, slip_angle_deg: float, speed: float, on_track: bool) -> void`:
  - Ist `on_track` falsch und `current > 0`: `current = 0.0`, `combo = 1`, `drifting = false`, `drift_failed` auslösen, fertig.
  - Ein Drift läuft, wenn `absf(slip_angle_deg) >= MIN_ANGLE` und `speed >= MIN_SPEED` und `on_track`.
  - Beginnt ein Drift, während `current > 0` ist (also innerhalb der Kettenzeit nach dem letzten Drift), steigt `combo` um 1, höchstens bis `MAX_COMBO`.
  - Während ein Drift läuft: `current += absf(slip_angle_deg) * speed * delta / 100.0`.
  - Läuft kein Drift, aber `current > 0`: Zähle die Zeit seit dem Ende des Drifts. Sobald sie `CHAIN_TIME` erreicht: `total += roundi(current * combo)`, `drift_banked` mit diesen Punkten auslösen, `current = 0.0`, `combo = 1`.
- `func reset() -> void` setzt `total`, `current`, `combo`, `drifting` und die Kettenzeit zurück.

## Tests
Neue Datei `tests/test_drift_scorer.gd` mit `extends "res://tests/base_test.gd"`. Lege in `setup()` einen `DriftScorer` an. Simuliere immer in Schritten von 0.1 s, also `update(0.1, …)` mehrmals hintereinander:
- `test_kleiner_winkel_ist_kein_drift`: 10 Schritte mit Winkel 5.0, Tempo 400.0 → `current` ist 0.0
- `test_drift_sammelt_punkte`: 10 Schritte mit Winkel 30.0, Tempo 400.0 → `current` ist 120.0
- `test_punkte_werden_nach_pause_gesichert`: 10 Schritte Drift (30.0, 400.0), dann 20 Schritte mit Winkel 0.0 und Tempo 400.0 → `total` ist 120, `current` ist 0.0
- `test_kombo_steigt_bei_kettendrift`: 10 Schritte Drift, 5 Schritte Pause, 10 Schritte Drift → `combo` ist 2; danach 20 Schritte Pause → `total` ist 480
- `test_abflug_loescht_drift`: 10 Schritte Drift, dann ein Schritt mit `on_track = false` → `current` ist 0.0, `combo` ist 1, `total` ist 0

Review (15.10.2026, 16:54): gemergt. Korrigiert: drift_banked meldete die Summe statt der gesicherten Punkte (Test ergänzt).
