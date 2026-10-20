---
id: T-0433
title: Editor-Knopf „Zum Fisch entwickeln“
project: zellenphase
priority: 4
after: T-0431, T-0430
---
## Ziel
Auftrag „Übergang zum Fisch im Editor“: Der Zelleditor bekommt den Knopf „Zum Fisch entwickeln“. Vorher ist er ausgegraut und sagt, was noch fehlt.

## Dateien
- `scripts/cell_editor.gd` – Knopf und Signal
- `scripts/main.gd` – Zustand setzen
- `tests/test_cell_editor.gd` – Tests ergänzen

## Akzeptanzkriterien
- `cell_editor.gd`: `signal evolve_requested(build: CellBuild)`; `var evolve_button: Button` (Name „EvolveButton“, Text „Zum Fisch entwickeln“) neben den Knöpfen zum Bestätigen und Abbrechen; `var evolve_hint: Label` (Name „EvolveHint“) direkt darunter
- `func set_fish_ready(ready: bool, hint: String) -> void`: `evolve_button.disabled = not ready`, `evolve_hint.text = hint`, `evolve_hint.visible = not ready and hint != ""`
- Klick auf den Knopf (nur wenn nicht `disabled`): setzt `confirmed = true` und sendet `evolve_requested` mit dem aktuellen Aufbau (derselbe Aufbau, den `confirm()` mit `finished` sendet; vorher `confirm()` lesen)
- `main.gd`: `open_editor()` ruft `editor.set_fish_ready(FishReadiness.is_ready(progress, unlocks), FishReadiness.missing_text(progress, unlocks))`

## Tests
`tests/test_cell_editor.gd`:
- `test_fischknopf_gesperrt`: `set_fish_ready(false, "Noch 2 Teile finden")` → `evolve_button.disabled`, `evolve_hint.text` „Noch 2 Teile finden“, sichtbar
- `test_fischknopf_bereit`: Editor mit `open(...)` öffnen (Werte wie in bestehenden Editor-Tests), `set_fish_ready(true, "")`, `evolve_button.pressed.emit()` → Signal `evolve_requested` kam an (Zähler über ein Lambda), `confirmed` wahr

Review (20.10.2026): selbst umgesetzt (5 Fehlversuche: der Test fing bool-Werte in Lambdas ein, der Knopf sendete zusätzlich finished).
