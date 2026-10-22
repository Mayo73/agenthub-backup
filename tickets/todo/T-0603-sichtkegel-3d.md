---
id: T-0603
title: VisionCone3D – Sichtkegel für Gegner in 3D
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“: Prüfen, ob ein Ziel im Sichtkegel einer Figur liegt (Öffnungswinkel und Reichweite).

## Dateien
- `core/vision_cone_3d.gd` – neu, Klasse `VisionCone3D`
- `tests/test_vision_cone_3d.gd` – neu

## Akzeptanzkriterien
`class_name VisionCone3D`, `extends RefCounted`, nur statische Funktionen. Alle lokalen Variablen mit Typ.
- `static func can_see(eye: Vector3, forward: Vector3, target: Vector3, fov_deg: float, range_m: float) -> bool`: `var to: Vector3 = target - eye`; Länge größer `range_m` → `false`; Länge kleiner 0.0001 → `true`; sonst `rad_to_deg(forward.normalized().angle_to(to)) <= fov_deg / 2.0`
- `static func visible_ids(eye: Vector3, forward: Vector3, targets: Dictionary, fov_deg: float, range_m: float) -> Array[String]`: Kennungen (Schlüssel von `targets`, Werte `Vector3`), die `can_see` erfüllen, alphabetisch sortiert

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Kein `assert`, kein `print`. Einrückung nur mit Tabs.

## Tests
`tests/test_vision_cone_3d.gd`, Auge `Vector3.ZERO`, Blick `Vector3(0, 0, -1)`, Öffnung 90, Reichweite 10:
- `test_vorne`: Ziel `Vector3(0, 0, -5)` sichtbar; `Vector3(4, 0, -5)` sichtbar; `Vector3(6, 0, -5)` nicht sichtbar
- `test_hinten_und_fern`: `Vector3(0, 0, 5)` nicht sichtbar; `Vector3(0, 0, -15)` nicht sichtbar
- `test_auge`: Ziel gleich dem Auge ist sichtbar
- `test_liste`: `visible_ids(..., {"a": Vector3(0, 0, -5), "b": Vector3(0, 0, 5), "c": Vector3(1, 0, -3)}, 90.0, 10.0)` ist `["a", "c"]`
