---
id: T-0048
title: Platz im Ergebnis anzeigen
project: drift
priority: 5
after: T-0047
model: qwen3.5:27b
timeout_minutes: 60
---
## Ziel
Im Ergebnis nach dem Rennen steht direkt unter „Ziel!“ der erreichte Platz, z. B. `Platz 2 von 4`.

## Dateien
- `scripts/race_state.gd`
- `scripts/hud.gd`
- `scripts/main.gd`
- `tests/test_race_state.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `race_state.gd`: Signatur wird `func result_text(points: int, new_time: bool = false, new_points: bool = false, place: int = 0, total: int = 0) -> String`. Ist `place > 0`, steht direkt nach der Zeile `Ziel!` die Zeile `Platz %d von %d` (mit `place` und `total`). Bei `place == 0` bleibt der Text genau wie bisher.
- `hud.gd`: Signatur wird `func show_race(race: RaceState, points: int, new_time: bool = false, new_points: bool = false, place: int = 0, total: int = 0) -> void` und gibt `place` und `total` an `race.result_text(...)` weiter.
- `main.gd`: Der Aufruf in `_physics_process` wird zu `hud.show_race(race, scorer.total, last_record.get("new_time", false), last_record.get("new_points", false), place, ai_cars.size() + 1)`. Sonst nichts an `main.gd` ändern.

## Tests
In `tests/test_race_state.gd` neue Methode `test_ergebnistext_mit_platz` anhängen, mit demselben Ablauf wie `test_ergebnistext` (`race.update(3.0)`, `race.update(87.5)`, `race.on_lap(30.0)`, `race.on_lap(28.5)`, `race.on_lap(29.0)`):
- `race.result_text(1234, false, false, 2, 4)` ist `"Ziel!\nPlatz 2 von 4\nGesamtzeit 1:27.50\nBeste Runde 0:28.50\nPunkte 1234\nEnter: neues Rennen"`
- `race.result_text(1234, true, false, 1, 4)` ist `"Ziel!\nPlatz 1 von 4\nGesamtzeit 1:27.50\nBeste Runde 0:28.50\nPunkte 1234\nNeue Bestzeit!\nEnter: neues Rennen"`
- `race.result_text(1234)` ist weiterhin `"Ziel!\nGesamtzeit 1:27.50\nBeste Runde 0:28.50\nPunkte 1234\nEnter: neues Rennen"`

Review (16.10.2026): gemergt.
