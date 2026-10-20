---
id: T-0443
title: SeaweedShape – gebogene, natürlichere Pflanzen
project: zellenphase
priority: 4
---
## Ziel
Befund aus P-0011: Die dünnen geraden Pflanzen wirken wie Stäbe. Seegras soll aus einem leicht gebogenen, nach oben schmaler werdenden Band bestehen.

## Dateien
- `scripts/seaweed_shape.gd` – neu, Klasse `SeaweedShape`
- `tests/test_seaweed_shape.gd` – neu

## Akzeptanzkriterien
`class_name SeaweedShape`, `extends RefCounted`, nur statische Funktionen. Koordinaten relativ zum Fuß der Pflanze, y nach oben.
- `const SEGMENTS := 8`
- `static func spine(height: float, bend: float, segments: int = SEGMENTS) -> PackedVector3Array`: `segments + 1` Punkte vom Fuß `(0, 0, 0)` bis zur Spitze; Punkt `i` mit `t = i / float(segments)`: `Vector3(bend * height * 0.35 * t * t, height * t, 0.0)` (die Biegung nimmt nach oben zu)
- `static func width_at(t: float, base_width: float) -> float`: `base_width * (1.0 - 0.8 * t)`
- `static func build_mesh(height: float, bend: float, base_width: float = 0.35) -> ArrayMesh`: Band aus Dreiecken entlang `spine` (je Punkt der Wirbelsäule zwei Ecken, um ±`width_at(t)/2` in z-Richtung versetzt), mit `SurfaceTool` (`PRIMITIVE_TRIANGLES`, `generate_normals()`), beidseitig sichtbar: das Material setzt der Aufrufer, hier nur das Mesh

## Tests
`tests/test_seaweed_shape.gd`:
- `test_wirbelsaeule`: `spine(10.0, 0.0).size()` 9, erster Punkt `Vector3.ZERO`, letzter `Vector3(0, 10, 0)`
- `test_biegung`: `spine(10.0, 0.5)` → letzter Punkt x ungefähr 1.75, Punkt 4 (Mitte) x ungefähr 0.4375
- `test_breite`: `width_at(0.0, 0.35)` 0.35, `width_at(1.0, 0.35)` ungefähr 0.07
- `test_mesh`: `build_mesh(5.0, 0.3)` hat 1 Oberfläche und mindestens `SEGMENTS * 6` Eckpunkte in `surface_get_arrays(0)[Mesh.ARRAY_VERTEX]`
