---
id: T-0446
title: Gebogenes Seegras auch im bisherigen Riff
project: zellenphase
priority: 4
after: T-0443
---
## Ziel
Befund aus P-0011: Bis die unendliche Welt eingebaut ist, soll schon das bisherige Riff gebogenes, natürlicheres Seegras zeigen.

## Dateien
- `scripts/reef_layout.gd` – Biegung je Halm
- `scripts/reef_view.gd` – `SeaweedShape` verwenden
- `tests/test_reef.gd`, `tests/test_reef_view.gd` – Tests ergänzen

## Akzeptanzkriterien
- `reef_layout.gd`: jeder Eintrag bekommt `"bend"`: Seegras `rng.randf_range(-0.6, 0.6)` (nach den bisherigen Zufallszahlen des Eintrags ziehen, damit die Lagen gleich bleiben), Felsen 0.0
- `reef_view.gd`: Seegras als `SeaweedShape.build_mesh(height, bend)` statt `CylinderMesh`, Fuß am Boden (Position = `item["position"]`, nicht mehr um die halbe Höhe angehoben), Material wie bisher, auf einer Kopie `cull_mode = BaseMaterial3D.CULL_DISABLED`; das Wiegen bleibt

## Tests
- `tests/test_reef.gd`: `test_biegung` (alle Seegras-Einträge haben `bend` zwischen −0.6 und 0.6, mindestens einer ungleich 0)
- `tests/test_reef_view.gd`: `test_seegras_gebogen` (das erste Seegras hat ein `ArrayMesh`)
