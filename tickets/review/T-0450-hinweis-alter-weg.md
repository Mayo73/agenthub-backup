---
id: T-0450
title: Einführungshinweis für den neuen Weg zum Fisch
project: zellenphase
priority: 4
after: T-0436
---
## Ziel
Auftrag „Übergang zum Fisch im Editor“: Sobald die Zelle zum ersten Mal zum Fisch werden kann, erscheint einmal ein Einführungshinweis, der den Weg erklärt.

## Dateien
- `scripts/tutorial_hints.gd` – neuer Hinweis
- `scripts/main.gd` – Hinweis auslösen
- `tests/test_tutorial_hints.gd` – Test ergänzen

## Akzeptanzkriterien
- `tutorial_hints.gd`: neuer Hinweis mit Kennung `"zum_fisch"` und Text „Du kannst jetzt zum Fisch werden: Rufe einen Partner und wähle im Editor „Zum Fisch entwickeln“.“ (vorher lesen, wie die anderen Hinweise angelegt sind, und genauso eintragen)
- `main.gd`: in `_process`, sobald `FishReadiness.is_ready(progress, unlocks)` zum ersten Mal wahr ist, `hint("zum_fisch")` (die bestehende Funktion zeigt jeden Hinweis nur einmal pro Partie)

## Tests
- `tests/test_tutorial_hints.gd` (gibt es die Datei nicht, neu anlegen): `test_zum_fisch` (der Hinweis `"zum_fisch"` existiert und sein Text enthält „Zum Fisch entwickeln“)
