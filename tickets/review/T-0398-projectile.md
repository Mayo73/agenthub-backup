---
id: T-0398
title: Projectile2D – Lebensdauer, Treffer an Wänden, Stoppen, Entfernen, Rückprall
project: hub-engine
priority: 3
after: T-0380, T-0381
---
## Ziel
Meilenstein „Ballistik“ (Lastenheft Muss 6): eine wiederverwendbare Projektil-Logik für 2D mit Startposition, Geschwindigkeit, Schwerkraft, Lebensdauer, Trefferereignissen und einstellbarer Trefferreaktion. Treffer werden je Schritt per Strecke geprüft (`SweepHit`), damit schnelle Projektile dünne Wände nicht durchqueren.

## Dateien
- `core/projectile_2d.gd` – neu, Klasse `Projectile2D`
- `tests/test_projectile_2d.gd` – neu

## Akzeptanzkriterien
`class_name Projectile2D`, `extends RefCounted`. 2D: Schwerkraft nach +y.
- `const STOP := "stop"`, `const REMOVE := "remove"`, `const BOUNCE := "bounce"`
- `var position := Vector2.ZERO`, `var velocity := Vector2.ZERO`, `var gravity := 9.81`, `var lifetime := 5.0`, `var age := 0.0`, `var reaction := REMOVE`, `var restitution := 0.5`, `var alive := true`, `var stopped := false`, `var hits: Array[Dictionary] = []`
- `func step(dt: float, walls: Array[Rect2]) -> Dictionary`: Rückgabe ist der Treffer dieses Schritts oder `{}`.
  - Ist `alive` falsch oder `stopped` wahr: nichts tun, `{}`.
  - `age += dt`; ist `age > lifetime`: `alive = false`, `{}`.
  - `velocity.y += gravity * dt`; `var target := position + velocity * dt`
  - `var hit: Dictionary = SweepHit.first_hit(position, target, walls)`; ohne Treffer `position = target`, `{}`.
  - Mit Treffer: Eintrag `{"index": hit["index"], "position": hit["position"], "normal": hit["normal"], "velocity": velocity}` an `hits` anhängen und am Ende zurückgeben. Vorher je `reaction`:
    - `STOP`: `position = hit["position"]`, `velocity = Vector2.ZERO`, `stopped = true`
    - `REMOVE`: `position = hit["position"]`, `alive = false`
    - `BOUNCE`: `velocity = SweepHit.reflect(velocity, hit["normal"], restitution)`, `position = hit["position"] + hit["normal"] * 0.001`
- `func run(duration: float, walls: Array[Rect2], hz: int = 120) -> int`: `roundi(duration * hz)` Mal `step(1.0 / hz, walls)`, Rückgabe `hits.size()`

## Tests
`tests/test_projectile_2d.gd` (Wand: `Rect2(10, -50, 0.05, 100)`, also 5 cm dick bei x = 10; als `var walls: Array[Rect2] = [Rect2(10, -50, 0.05, 100)]`):
- `test_lebensdauer`: ohne Wände (`var leer: Array[Rect2] = []`), `lifetime = 0.5`, `run(1.0, leer)` → `alive` falsch, `hits` leer
- `test_entfernen`: Start `(0, 0)`, Geschwindigkeit `(200, 0)`, `gravity = 0`, `REMOVE` → `run(1.0, walls)` 1, `alive` falsch, `position.x` ungefähr 10
- `test_stoppen`: wie oben mit `STOP` → `stopped` wahr, `velocity` `Vector2.ZERO`, `hits.size()` 1
- `test_rueckprall`: `BOUNCE`, `restitution = 0.5`, `gravity = 0`, Geschwindigkeit `(200, 0)` → so lange `step(1.0 / 120, walls)` aufrufen, bis der Rückgabewert nicht leer ist (höchstens 120-mal), dann `velocity.x` ungefähr −100
- `test_normale`: Treffer von links → `hits[0]["normal"]` `Vector2(-1, 0)`
