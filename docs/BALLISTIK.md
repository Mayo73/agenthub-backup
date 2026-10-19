# Ballistik

Wie die Hub Engine Projektile bewegt und Treffer erkennt, und womit das geprüft ist.

## Einheiten

- 1 Einheit = 1 Meter, Zeit in Sekunden.
- 120 Physikschritte pro Sekunde (Schritt 1/120 s).
- Schwerkraft 9,81 m/s² nach unten: in 2D nach +y, in 3D nach −y.

## Prüfverfahren

Ein Projektil (`Projectile2D`, `Projectile3D`) prüft in jedem Schritt nicht nur seine neue Position, sondern die ganze **Strecke** von der alten zur neuen Position gegen alle Wände (`SweepHit` für Rechtecke in 2D, `SweepHit3D` für Quader in 3D, Slab-Verfahren). Getroffen wird die Wand mit dem frühesten Eintritt. So kann ein schnelles Projektil auch eine sehr dünne Wand nicht überspringen. Nach dem Treffer gilt die Reaktion des Projektils: anhalten (`stop`), entfernen (`remove`) oder abprallen (`bounce`, mit Rückprallfaktor).

## Abnahmetest

`tests/test_ballistik_abnahme.gd` feuert 100 festgelegte Schüsse ohne Zufall:

| Größe | Werte |
|---|---|
| Geschwindigkeit (m/s) | 50, 150, 300, 600, 1000 |
| Wandstärke (m) | 0,01; 0,05; 0,2; 1,0 |
| Winkel (Grad) | −40, −20, 0, 20, 40 |

Start bei (0, 0), ohne Schwerkraft, Wand `Rect2(5, −100, Stärke, 200)`, Reaktion „entfernen“, Laufzeit 1 s. Erwartet wird je Schuss genau ein Treffer an der Vorderseite der Wand (x = 5 ± 0,001, Normale (−1, 0)).

## Vereinfachungen

- Kein Luftwiderstand, keine Drehung des Projektils.
- Projektile sind Punkte, Wände achsenparallele Rechtecke bzw. Quader.
- Bei 1000 m/s legt ein Projektil 8,3 m pro Schritt zurück; das ist durch die Streckenprüfung abgedeckt.
