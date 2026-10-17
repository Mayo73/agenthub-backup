---
id: T-0032
title: Neue Rekorde im Ergebnis anzeigen
project: drift
priority: 3
after: T-0031
---
## Ziel
Fährt der Spieler auf der Strecke eine neue Bestzeit oder einen Punkterekord, steht das im Ergebnis („Neue Bestzeit!“, „Neuer Punkterekord!“).

## Dateien
- `scripts/race_state.gd`
- `scripts/hud.gd`
- `scripts/main.gd`
- `scenes/main.tscn`
- `tests/test_race_state.gd`: neuen Test anhängen, bestehende nicht ändern

## Akzeptanzkriterien
- `race_state.gd`: Signatur wird `func result_text(points: int, new_time: bool = false, new_points: bool = false) -> String`. Zwischen der Zeile `Punkte …` und `Enter: neues Rennen` stehen bei Bedarf die Zeilen `Neue Bestzeit!` (wenn `new_time`) und `Neuer Punkterekord!` (wenn `new_points`), in dieser Reihenfolge. Ohne Rekorde ist der Text genau wie bisher.
- `hud.gd`: Signatur wird `func show_race(race: RaceState, points: int, new_time: bool = false, new_points: bool = false) -> void`; sie ruft `race.result_text(points, new_time, new_points)` auf.
- `main.gd`: In `_physics_process` wird der Aufruf zu `hud.show_race(race, scorer.total, last_record.get("new_time", false), last_record.get("new_points", false))`. Sonst nichts an `main.gd` ändern.
- `scenes/main.tscn`: Beim Node `Result` die Zeile `offset_top = -110.0` durch `offset_top = -250.0` und `theme_override_font_sizes/font_size = 32` durch `theme_override_font_sizes/font_size = 28` ersetzen (Platz für mehr Zeilen). Nur diese zwei Zeilen im Block `Result` ändern.

## Tests
In `tests/test_race_state.gd` neue Methode `test_ergebnistext_mit_rekord` anhängen, mit demselben Ablauf wie `test_ergebnistext` (`race.update(3.0)`, `race.update(87.5)`, `race.on_lap(30.0)`, `race.on_lap(28.5)`, `race.on_lap(29.0)`):
- `race.result_text(1234, true, true)` ist `"Ziel!\nGesamtzeit 1:27.50\nBeste Runde 0:28.50\nPunkte 1234\nNeue Bestzeit!\nNeuer Punkterekord!\nEnter: neues Rennen"`
- `race.result_text(1234, false, true)` ist `"Ziel!\nGesamtzeit 1:27.50\nBeste Runde 0:28.50\nPunkte 1234\nNeuer Punkterekord!\nEnter: neues Rennen"`

Review (16.10.2026): gemergt.
