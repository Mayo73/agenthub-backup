---
id: T-0299
title: Anleitung: Fortsetzen, Pause und Hinweis in der Fischphase
project: zellenphase
priority: 4
after: T-0279, T-0284, T-0293
---
## Ziel
Der Abschnitt „## Fischphase“ in `docs/ANLEITUNG.md` (aus T-0279) wird um drei Sätze ergänzt: Fortsetzen eines Spielstands in der Fischphase, Pausemenü mit Esc und der Hinweis „E: Verbesserung möglich“.

## Dateien
- `docs/ANLEITUNG.md`
- `tests/test_doku_anleitung.gd` – Test anhängen

## Akzeptanzkriterien
- Im Abschnitt `## Fischphase` von `docs/ANLEITUNG.md` direkt am Ende des vorhandenen Absatzes (vor der Leerzeile und dem nächsten `##`) diese Sätze anhängen, durch ein Leerzeichen getrennt:
  `Esc öffnet das Pausemenü. Die Fischphase speichert in denselben Spielstand wie die Zellenphase; „Fortsetzen“ im Hauptmenü bringt dich direkt zurück zu deinem Fisch. Reicht die DNA für eine Verbesserung, zeigt die Anzeige „E: Verbesserung möglich“.`
- Sonst nichts ändern.

## Tests
In `tests/test_doku_anleitung.gd` anhängen:
- `test_fischphase_fortsetzen`: der Text zwischen `"## Fischphase"` und `"## Leistungstest und Vorführszenen"` (über `find` und `substr`) enthält `"Pausemenü"`, `"Fortsetzen"` und `"E: Verbesserung möglich"`

Review (18.10.2026): gemergt, nachgebessert: Anführungszeichen der Anleitung wiederhergestellt.
