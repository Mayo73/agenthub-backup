---
id: A-0012
title: Zellkörper-Textur (hell, wird eingefärbt)
project: zellenphase
kind: bild
status: fertig
target: assets/cells/zellkoerper.png
attempted:
credits: 1,25
---
## Beschreibung
Runder Zellkörper in Draufsicht als Textur für alle Zellen (Spieler, KI-Zellen, Partner, Editor). Fast weiß bis hellgrau, damit das Spiel ihn mit der Zellfarbe einfärben kann: durchscheinende Membran mit hellerem Rand, angedeuteter Zellkern und kleine Organellen, sanftes Licht von oben links. Keine Augen, kein Maul, keine Teile, keine Schrift. Quadratisch, der Körper füllt das Bild fast vollständig aus.

## Nachbearbeitung
- Hintergrund mit `remove_background` entfernen, auf 512 × 512 einpassen (`bild.gd --trim --fit 512x512`)

## Verlauf
- 2026-10-16 21:14: gpt_image_2_5 (0,25), freigestellt mit remove_background (1), auf 505 x 512 zugeschnitten
