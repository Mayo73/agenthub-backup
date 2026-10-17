---
id: T-0001
title: Highscore im Spielstand merken
project: testspiel
priority: 2
---
## Ziel
`GameState` soll sich die höchste je erreichte Punktzahl merken. Ein Reset setzt die aktuellen Punkte zurück, den Highscore aber nicht.

## Dateien
- `scripts/game_state.gd`: hier die Logik ergänzen
- `tests/test_game_state.gd`: hier die neuen Tests anhängen (bestehende Tests nicht ändern)

## Akzeptanzkriterien
- Neue Variable `var high_score := 0`.
- Neues Signal `signal high_score_changed(new_high_score: int)`.
- In `add_coin()`: Ist `score` danach größer als `high_score`, wird `high_score = score` gesetzt und `high_score_changed` mit dem neuen Wert ausgelöst.
- `reset()` setzt `score` und `coins_collected` auf 0. `high_score` bleibt unverändert.

## Tests
In `tests/test_game_state.gd` drei neue Methoden anhängen:
- `test_highscore_steigt_mit_punkten`: `add_coin(2)`, `add_coin(3)` → `high_score` ist 5.
- `test_highscore_bleibt_nach_reset`: `add_coin(4)`, `reset()` → `score` ist 0 und `high_score` ist 4.
- `test_highscore_signal_nur_bei_neuem_rekord`: Signal mit einem Lambda in ein Array mitschreiben; `add_coin(4)`, `reset()`, `add_coin(2)` → das Array ist `[4]`.

Review (15.10.2026, 13:44): gemergt. Umsetzung und Tests entsprechen genau den Akzeptanzkriterien.
