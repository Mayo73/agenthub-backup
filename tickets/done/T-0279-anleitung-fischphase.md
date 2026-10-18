---
id: T-0279
title: Anleitung um die Fischphase ergänzen
project: zellenphase
priority: 4
after: T-0277
---
## Ziel
Die Spielanleitung `docs/ANLEITUNG.md` beschreibt bisher nur die Zellenphase. Ein neuer Abschnitt erklärt die Fischphase für Spieler.

## Dateien
- `docs/ANLEITUNG.md`
- `tests/test_doku_anleitung.gd` – Test anhängen

## Akzeptanzkriterien
- In `docs/ANLEITUNG.md` direkt vor dem Abschnitt `## Leistungstest und Vorführszenen` einen Abschnitt einfügen (mit Leerzeile davor und danach):
```markdown
## Fischphase
Am Ende der Zellenphase führt „Weiter zur Fischphase“ in eine 3D-Unterwasserwelt. Die Teile der Zelle bestimmen den ersten Fisch: Geißel oder Düse werden zur Schwanzflosse, Wimpern zu Brustflossen, Kiefer, Stacheln und Augen bleiben. Steuerung: W oder linke Maustaste schwimmen, A/D drehen, Leertaste auftauchen, Umschalt abtauchen. Algen am Boden und Krebschen bringen DNA und Wachstum, Fleisch- und Allesfresser können auch Silberlinge und Grasfische fressen. Zackenbarsche sind gefährlich. Mit E öffnet sich das Entwicklungsmenü: DNA verbessert Schwanzflosse (Tempo), Brustflossen (Wendigkeit und Tauchen), Kiefer (Biss), Stacheln (Abwehr) und Augen (Sicht im trüben Wasser). Zum Ausprobieren startet `-- --fisch` direkt in der Fischphase.
```
- Sonst nichts ändern.

## Tests
- in `tests/test_doku_anleitung.gd` anhängen: `test_fischphase_beschrieben`: `FileAccess.get_file_as_string("res://docs/ANLEITUNG.md")` enthält `"## Fischphase"`, `"Entwicklungsmenü"` und `"-- --fisch"`; der Abschnitt `"## Fischphase"` steht vor `"## Leistungstest und Vorführszenen"` (über `find`)

Review (18.10.2026): gemergt.
