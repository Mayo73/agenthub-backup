---
id: T-0553
title: PathFollower2D – Bewegung entlang eines Pfads
project: hub-engine
priority: 4
---
## Ziel
Muss 4 „Spielverhalten“ und 2D-Referenzspiel: Gegner oder Plattformen laufen einen Pfad ab, einmal, im Kreis oder hin und her.

## Dateien
- `core/path_follower_2d.gd` – neu, Klasse `PathFollower2D`
- `tests/test_path_follower_2d.gd` – neu

## Akzeptanzkriterien
`class_name PathFollower2D`, `extends RefCounted`.
- `var points: Array[Vector2] = []`, `var speed := 1.0`, `var mode := "once"` („once“, „loop“, „pingpong“), `var position := Vector2.ZERO`, `var target := 1` (Index des nächsten Punkts), `var direction := 1` (1 vorwärts, −1 rückwärts), `var finished := false`
- `func _init(path: Array[Vector2] = [], move_speed: float = 1.0, follow_mode: String = "once") -> void`: Werte übernehmen (`points = path.duplicate()`); gibt es Punkte, `position = points[0]`; weniger als 2 Punkte → `finished = true`
- `func step(dt: float) -> Vector2`: Strecke `rest = speed * dt`. Solange `rest > 0` und nicht `finished`: Ziel `points[target]`, Abstand `d`. Ist `rest < d`: `position = position.move_toward(ziel, rest)`, `rest = 0`. Sonst `position = ziel`, `rest -= d`, dann den nächsten `target` wählen:
  - „once“: `target + 1`; gibt es den nicht → `finished = true`
  - „loop“: `(target + 1) % points.size()` (nach dem letzten Punkt geht es zum ersten)
  - „pingpong“: `target + direction`; liegt das außerhalb der Liste, `direction = -direction` und `target + direction` nehmen
  
  Am Ende `position` zurückgeben.

Hinweis Typen: `var goal: Vector2 = points[target]`, `var d: float = position.distance_to(goal)`.

## Tests
`tests/test_path_follower_2d.gd`, Punkte `[Vector2(0, 0), Vector2(2, 0), Vector2(2, 2)]`, Geschwindigkeit 1.0:
- `test_einmal`: „once“: `step(1.0)` ist `Vector2(1, 0)`; `step(2.0)` ist `Vector2(2, 1)`; `step(5.0)` ist `Vector2(2, 2)` und `finished` wahr
- `test_schleife`: „loop“: `step(4.0)` ist `Vector2(2, 2)`; `step(2.0)` ist ungefähr `Vector2(0.586, 0.586)` (Toleranz 0.01 je Achse), `finished` falsch
- `test_pendel`: „pingpong“: `step(5.0)` ist `Vector2(2, 1)`
- `test_einzelpunkt`: nur `[Vector2(3, 3)]` → `finished` wahr, `step(1.0)` ist `Vector2(3, 3)`

Review (21.10.2026): Agent scheiterte 5x an falschen Testerwartungen (Schleife, Pendel); Claude hat es selbst umgesetzt, 4 Tests, 504 grün.
