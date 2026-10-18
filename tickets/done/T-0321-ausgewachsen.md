---
id: T-0321
title: Meldung, wenn der Fisch ausgewachsen ist
project: zellenphase
priority: 4
after: T-0315
---
## Ziel
Auftrag „Fischphase – lebendige Welt“: Erreicht der Spielerfisch die letzte Größe, sagt die Anzeige es deutlich und weist darauf hin, dass ihn jetzt die Raubfische fürchten.

## Dateien
- `scripts/fish_main.gd`
- `tests/test_fish_main.gd` – Tests anhängen

## Akzeptanzkriterien
- Neue Konstante direkt unter `const RESPAWN_INTERVAL := 10.0`:
  `const GROWN_MESSAGE := "Dein Fisch ist ausgewachsen! Jetzt fliehen sogar die Zackenbarsche vor dir."`
- In `eat_value(value)` im Zweig, in dem der Fisch gewachsen ist, die Zeile `hud.show_message("Dein Fisch ist gewachsen!")` ersetzen durch:
```gdscript
		if progress.is_final_stage():
			hud.show_message(GROWN_MESSAGE, 6.0)
		else:
			hud.show_message("Dein Fisch ist gewachsen!")
```
- Sonst nichts ändern (Klang und Speichern im selben Zweig bleiben).

## Tests
Am Ende von `tests/test_fish_main.gd` anhängen (vorher alle KI-Fische entfernen):
- `test_gewachsen_meldung`: `fish.progress.stage = 0`; `fish.progress.growth = 0`; `fish.eat_value(FishProgress.GROWTH_NEEDED[0])` → `fish.hud.message_label.text` ist `"Dein Fisch ist gewachsen!"`
- `test_ausgewachsen_meldung`: `fish.progress.stage = 2`; `fish.progress.growth = 0`; `fish.eat_value(FishProgress.GROWTH_NEEDED[2])` → `fish.progress.is_final_stage()` wahr und `fish.hud.message_label.text` ist `fish.GROWN_MESSAGE`

Review (18.10.2026): selbst umgesetzt (Commit 58bc6bf). Die Agents setzten die Tests richtig um, verloren aber beim Bearbeiten von test_fish_main.gd zwei Tests (968 → 966).
