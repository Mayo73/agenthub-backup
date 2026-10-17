---
id: T-0004
title: Rundenzeit mit Bestzeit
project: drift
priority: 2
---
## Ziel
Neue Klasse `LapTimer`, die aus dem Fortschritt entlang der Strecke Runden zählt und Rundenzeiten misst. Eine Runde zählt nur, wenn das Auto unterwegs die Streckenhälfte passiert hat (kein Schummeln durch Rückwärtsfahren über die Ziellinie). Nur Logik und Tests, noch nicht ins Spiel einbauen.

## Dateien
- `scripts/lap_timer.gd`: neu, beginnt mit `class_name LapTimer` und `extends RefCounted`
- `tests/test_lap_timer.gd`: neu

## Akzeptanzkriterien
- Variablen: `var track_length: float`, `var lap := 0` (abgeschlossene Runden), `var current_time := 0.0`, `var last_lap_time := -1.0`, `var best_lap_time := -1.0`
- `func _init(length: float = 1000.0) -> void` setzt `track_length`.
- `signal lap_completed(lap_number: int, time: float, is_best: bool)`
- `func update(delta: float, progress: float) -> void` (`progress` läuft von 0 bis `track_length`, 0 = Ziellinie):
  - `current_time += delta`
  - Liegt `progress` zwischen `0.4 * track_length` und `0.6 * track_length`, merkt sich der Timer: Hälfte passiert.
  - War der vorige `progress` größer als `0.75 * track_length`, ist der neue kleiner als `0.25 * track_length` und wurde die Hälfte passiert, ist eine Runde fertig: `lap += 1`, `last_lap_time = current_time`, Bestzeit aktualisieren (`best_lap_time` ist -1.0 oder größer), `lap_completed` auslösen, `current_time = 0.0`, Hälfte-Merker zurücksetzen.
  - Den aktuellen `progress` für den nächsten Aufruf merken.
- `func reset() -> void` setzt alles zurück (außer `track_length`).
- `static func format_time(seconds: float) -> String`: Format `m:ss.cc`, zum Beispiel 75.25 → `"1:15.25"`, 5.0 → `"0:05.00"`. Negative Werte → `"–"`. Rechne mit `roundi(seconds * 100.0)` Hundertstel, dann Minuten, Sekunden und Hundertstel daraus.

## Tests
Neue Datei `tests/test_lap_timer.gd` mit `extends "res://tests/base_test.gd"`. Lege in `setup()` einen `LapTimer.new(1000.0)` an:
- `test_runde_wird_gezaehlt`: `update(1.0, p)` für p = 100, 300, 500, 700, 900, 50 → `lap` ist 1, `last_lap_time` ist 6.0, `current_time` ist 0.0
- `test_ohne_haelfte_keine_runde`: `update(1.0, p)` für p = 900, 50 → `lap` ist 0
- `test_rueckwaerts_ueber_ziel_zaehlt_nicht`: `update(1.0, p)` für p = 50, 950, 500, 50 → `lap` ist 0
- `test_bestzeit`: Runde 1 mit p = 100, 500, 900, 50 (4 s), Runde 2 mit p = 500, 900, 50 (3 s) → `best_lap_time` ist 3.0, `last_lap_time` ist 3.0
- `test_zeitformat`: `format_time(75.25)` ist `"1:15.25"`, `format_time(5.0)` ist `"0:05.00"`, `format_time(-1.0)` ist `"–"`

Review (15.10.2026, 16:54): gemergt. Korrigiert: reset() vergaß den Merker 'Hälfte passiert' (Test ergänzt).
