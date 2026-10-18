---
id: T-0320
title: Anleitung – Laternenfische, fliehende Raubfische, Schwierigkeitsgrad
project: zellenphase
priority: 4
after: T-0299, T-0313, T-0317
---
## Ziel
Auftrag „Fischphase – lebendige Welt“: Die Bedienungsanleitung beschreibt die neuen Regeln der Fischphase.

## Dateien
- `docs/ANLEITUNG.md`
- `tests/test_doku_anleitung.gd` – Test anhängen

## Akzeptanzkriterien
- Im Abschnitt `## Fischphase` von `docs/ANLEITUNG.md` am Ende drei kurze Sätze ergänzen (Inhalt, nicht wörtlich):
  - In 45 bis 58 m Tiefe leben leuchtende **Laternenfische**, die besonders viel DNA bringen.
  - Ist dein Fisch ausgewachsen und damit deutlich größer als ein Zackenbarsch, flieht der Raubfisch vor dir.
  - Der **Schwierigkeitsgrad** aus den Einstellungen gilt auch für die Bisse der Raubfische; gefressene Fische kommen nach einiger Zeit nach.
- Sonst nichts ändern, keine bestehenden Abschnitte umbenennen.

## Tests
Am Ende von `tests/test_doku_anleitung.gd` anhängen:
- `test_lebendige_welt`: der Text von `PATH` enthält `"Laternenfisch"`, `"Schwierigkeitsgrad"` und `"flieht"`

Review (18.10.2026): gemergt.
