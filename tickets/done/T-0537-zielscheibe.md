---
id: T-0537
title: TargetScore – Zielscheibe mit Ringen und Wertung
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Referenzspiel mit Ballistik): Eine Zielscheibe wertet Treffer nach dem Abstand zur Mitte in Ringen und führt eine Trefferliste. Reine Rechnung für 2D und 3D.

## Dateien
- `core/target_score.gd` – neu, Klasse `TargetScore`
- `tests/test_target_score.gd` – neu

## Akzeptanzkriterien
`class_name TargetScore`, `extends RefCounted`.
- `var radius := 1.0` (Außenradius der Scheibe in Einheiten), `var rings := 10` (Ring 10 innen … Ring 1 außen), `var hits: Array[int] = []`
- `func _init(radius_value: float = 1.0, ring_count: int = 10) -> void`
- `func ring_for(distance: float) -> int`: `distance < 0` wie 0 behandeln; `distance > radius` → 0 (daneben); sonst `rings - floori(distance / radius * rings)`, mindestens 1 (genau auf dem Rand zählt als Ring 1)
- `func hit_2d(center: Vector2, point: Vector2) -> int` und `func hit_3d(center: Vector3, point: Vector3) -> int`: Ring über den Abstand bestimmen, an `hits` anhängen, Ring zurückgeben
- `func total() -> int`: Summe von `hits`
- `func average() -> float`: Mittelwert, ohne Treffer 0.0
- `func reset() -> void`: `hits` leeren

## Tests
`tests/test_target_score.gd`:
- `test_mitte`: `TargetScore.new(1.0, 10).ring_for(0.0)` ist 10, `ring_for(0.05)` ist 10, `ring_for(0.15)` ist 9
- `test_rand`: `ring_for(1.0)` ist 1, `ring_for(1.01)` ist 0
- `test_treffer`: `hit_2d(Vector2(5, 5), Vector2(5, 5.25))` ist 8, `hit_3d(Vector3.ZERO, Vector3(0, 0, 2))` ist 0; `total()` 8, `average()` 4.0
- `test_zuruecksetzen`: nach `reset()` sind `total()` 0 und `average()` 0.0

Review (21.10.2026): gemergt.
