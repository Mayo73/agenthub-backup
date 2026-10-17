---
id: T-0026
title: Durchschnittlicher Münzwert im Spielstand
project: testspiel
priority: 1
---
## Ziel
`GameState` soll den durchschnittlichen Wert der gesammelten Münzen liefern. Dient zugleich als Probelauf für die neuen Prüfungen des Workers (Ausgangsprüfung, Testzahl, Konfliktprüfung).

## Dateien
- `scripts/game_state.gd`: neue Funktion
- `tests/test_game_state.gd`: zwei neue Tests anhängen, bestehende Tests unverändert lassen

## Akzeptanzkriterien
- Neue Funktion `func average_coin_value() -> float` in `GameState`.
- Ohne gesammelte Münzen (`coins_collected == 0`) gibt sie `0.0` zurück.
- Sonst gibt sie `float(score) / coins_collected` zurück.

## Tests
In `tests/test_game_state.gd` anhängen:
- `test_durchschnitt_ohne_muenzen`: frischer `GameState` → `average_coin_value()` ist `0.0`
- `test_durchschnitt`: `add_coin(1)`, dann `add_coin(3)` → `average_coin_value()` ist `2.0`

Review (15.10.2026, 23:10): gemergt. Probelauf der neuen Worker-Prüfungen bestanden (Ausgangslage grün, Tests 15 -> 17, kein Konflikt).
