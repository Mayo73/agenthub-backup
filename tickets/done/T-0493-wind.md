---
id: T-0493
title: Wind – Luftwiderstand und Wind für Projektile
project: hub-engine
priority: 4
---
## Ziel
Lastenheft „Soll“: „Optionaler Luftwiderstand und Wind für Spielprojektile, mit dokumentiertem vereinfachtem Modell“. Das Modell: Beschleunigung durch Luft = `-drag * (v - wind)`, also linear in der Relativgeschwindigkeit (bewusst vereinfacht, kein quadratischer Luftwiderstand).

## Dateien
- `core/wind.gd` – neu, Klasse `Wind`
- `tests/test_wind.gd` – neu

## Akzeptanzkriterien
`class_name Wind`, `extends RefCounted`. Vereinfachtes Modell als `##`-Kommentar über der Klasse beschreiben.
- `var drag := 0.0` (pro Sekunde, 0 = kein Luftwiderstand), `var wind := Vector3.ZERO` (Einheiten/s)
- `func _init(drag_value: float = 0.0, wind_value: Vector3 = Vector3.ZERO) -> void`
- `func acceleration(velocity: Vector3) -> Vector3`: `-drag * (velocity - wind)`
- `func acceleration_2d(velocity: Vector2) -> Vector2`: dasselbe mit `Vector2(wind.x, wind.y)`
- `func step(velocity: Vector3, dt: float) -> Vector3`: `velocity + acceleration(velocity) * dt`
- `func terminal_velocity(gravity: float) -> float`: Endgeschwindigkeit im freien Fall ohne Wind, `gravity / drag`; bei `drag <= 0` `INF`
- `func to_dict() -> Dictionary` (`{"drag": drag, "wind": [x, y, z]}`) und `static func from_dict(d: Dictionary) -> Wind`

## Tests
`tests/test_wind.gd`:
- `test_ohne_luft`: `Wind.new().acceleration(Vector3(10, 0, 0))` ist `Vector3.ZERO`
- `test_bremst`: `Wind.new(0.5).acceleration(Vector3(10, 0, 0))` ist `Vector3(-5, 0, 0)`
- `test_wind_schiebt`: `Wind.new(0.5, Vector3(4, 0, 0)).acceleration(Vector3.ZERO)` ist `Vector3(2, 0, 0)`
- `test_endgeschwindigkeit`: Körper mit `Wind.new(0.5)` fällt 20 s lang in Schritten von 1/120 s (Geschwindigkeit `v = w.step(v, dt) + Vector3(0, -9.81, 0) * dt`) → `-v.y` ungefähr `terminal_velocity(9.81)` (19.62, Toleranz 0.1)
- `test_2d`: `Wind.new(1.0, Vector3(0, 2, 0)).acceleration_2d(Vector2(0, 2))` ist `Vector2.ZERO`
- `test_speichern`: `Wind.from_dict(Wind.new(0.3, Vector3(1, 2, 3)).to_dict())` hat `drag` 0.3 und `wind` `Vector3(1, 2, 3)`

Review (2026-10-21): gemergt.
