---
id: T-0419
title: SweepHit3D – Strecke gegen Quader ohne Durchtunneln (3D)
project: hub-engine
priority: 3
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Muss 6, Abnahmekriterium 8 für 3D): Schnelle Projektile in 3D dürfen dünne Wände nicht unbemerkt durchqueren. Dafür eine Streckenprüfung gegen achsenparallele Quader (`AABB`) nach dem Slab-Verfahren.

## Dateien
- `core/sweep_hit_3d.gd` – neu, Klasse `SweepHit3D`
- `tests/test_sweep_hit_3d.gd` – neu

## Akzeptanzkriterien
`class_name SweepHit3D`, `extends RefCounted`, nur statische Funktionen:
- `static func segment_aabb(from: Vector3, to: Vector3, box: AABB) -> Dictionary`: kein Treffer → `{}`; sonst `{"t": float (0..1, erster Eintritt), "position": Vector3, "normal": Vector3}`. Die Normale zeigt aus der getroffenen Seite heraus (z. B. `Vector3(-1, 0, 0)` für die Seite bei `box.position.x`). Achsen, in denen sich die Strecke nicht bewegt (`absf(d) < 1e-9`), treffen nur, wenn `from` in dieser Achse innerhalb liegt. Startet die Strecke im Quader: `t` 0, Normale `-(to - from).normalized()`.
- `static func first_hit(from: Vector3, to: Vector3, boxes: Array[AABB]) -> Dictionary`: Treffer mit kleinstem `t` über alle Quader, zusätzlich `"index": int`; `{}` ohne Treffer
- `static func reflect(velocity: Vector3, normal: Vector3, restitution: float) -> Vector3`: `velocity.bounce(normal) * restitution`

## Tests
`tests/test_sweep_hit_3d.gd`, Wand `AABB(Vector3(5, -10, -10), Vector3(0.05, 20, 20))` (5 cm dick):
- `test_treffer`: `segment_aabb(Vector3.ZERO, Vector3(10, 0, 0), wand)` → `t` ungefähr 0.5, `normal` `Vector3(-1, 0, 0)`, `position.x` ungefähr 5.0
- `test_daneben`: `segment_aabb(Vector3(0, 20, 0), Vector3(10, 20, 0), wand)` leer
- `test_zu_kurz`: `segment_aabb(Vector3.ZERO, Vector3(4, 0, 0), wand)` leer
- `test_schnell`: 100 Strecken mit Länge 50 (von `Vector3(-20, y, 0)` nach `Vector3(30, y, 0)`, `y = -9.0 + i * 0.18`) treffen alle die Wand
- `test_erster`: zwei Wände bei x 5 und x 3 (gleiche Maße) → `first_hit` `index` 1
- `test_abprall`: `reflect(Vector3(10, 0, 0), Vector3(-1, 0, 0), 0.5)` ist `Vector3(-5, 0, 0)`

Review (19.10.2026): gemergt.
