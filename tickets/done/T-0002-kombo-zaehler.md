---
id: T-0002
title: Kombo-Zähler für schnell gesammelte Münzen
project: testspiel
priority: 3
---
## Ziel
Neue, eigenständige Klasse `ComboCounter`: Wer Münzen kurz hintereinander sammelt, baut eine Kombo auf. Noch nicht ins Spiel einbauen, nur Logik und Tests.

## Dateien
- `scripts/combo_counter.gd`: neu, beginnt mit `class_name ComboCounter` und `extends RefCounted`
- `tests/test_combo_counter.gd`: neu

## Akzeptanzkriterien
- Konstanten `const COMBO_WINDOW := 1.5` (Sekunden) und `const MAX_MULTIPLIER := 5`.
- `func register_coin(time_sec: float) -> int` gibt den Multiplikator für diese Münze zurück:
  - Die erste Münze ergibt 1.
  - Kommt eine Münze höchstens `COMBO_WINDOW` Sekunden nach der vorherigen, ist der Multiplikator um 1 höher als bei der vorherigen, aber höchstens `MAX_MULTIPLIER`.
  - Liegen mehr als `COMBO_WINDOW` Sekunden dazwischen, beginnt die Kombo wieder bei 1.
- `func reset() -> void`: Die nächste Münze zählt wieder als erste.

## Tests
Neue Datei `tests/test_combo_counter.gd` mit `extends "res://tests/base_test.gd"` und diesen Methoden:
- `test_erste_muenze_ist_eins`: `register_coin(0.0)` → 1
- `test_schnelle_muenzen_steigern`: Zeiten 0.0, 1.0, 2.0 → Rückgaben 1, 2, 3
- `test_maximum_ist_fuenf`: Zeiten 0.0 bis 6.0 in Schritten von 1.0 → letzte Rückgabe 5
- `test_pause_setzt_zurueck`: Zeiten 0.0, 1.0, 3.0 → letzte Rückgabe 1
- `test_reset`: Zeiten 0.0, 1.0, dann `reset()`, dann 1.5 → Rückgabe 1

Review (15.10.2026, 13:44): gemergt. Achtung: Versuch 2 galt wegen eines Fehlers in verify.cmd fälschlich als bestanden, und die Tests nutzten setup(), das der Runner damals nicht aufrief. Nach Härtung der Prüfung und setup()-Unterstützung erneut geprüft: alle 5 Tests grün.
