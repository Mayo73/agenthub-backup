---
id: T-0420
title: Projectile3D – 3D-Projektil mit Lebensdauer, Treffer, Stoppen und Rückprall
project: hub-engine
priority: 3
after: T-0419
---
## Ziel
Meilenstein „3D-Arbeitsablauf“ (Muss 6: wiederverwendbare Projektilkomponente für 3D): Ein Projektil als Kernlogik, das unter Schwerkraft fliegt, Treffer an Quadern ohne Durchtunneln erkennt und je nach Einstellung stoppt, verschwindet oder abprallt.

## Dateien
- `core/projectile_3d.gd` – neu, Klasse `Projectile3D`
- `tests/test_projectile_3d.gd` – neu

## Akzeptanzkriterien
`class_name Projectile3D`, `extends RefCounted`. 3D: Schwerkraft nach **−y**. Nutzt `SweepHit3D` (`core/sweep_hit_3d.gd`, vorher lesen).
- `const STOP := "stop"`, `const REMOVE := "remove"`, `const BOUNCE := "bounce"`
- `var position := Vector3.ZERO`, `var velocity := Vector3.ZERO`, `var gravity := 9.81`, `var lifetime := 5.0`, `var age := 0.0`, `var on_hit := STOP`, `var restitution := 0.5`, `var alive := true`, `var stopped := false`, `var hits: Array[Dictionary] = []`
- `func step(dt: float, boxes: Array[AABB]) -> Dictionary`: nicht `alive` oder `stopped` → `{}`. Sonst `age += dt`; ist `age >= lifetime` → `alive = false`, `{}`. Neue Geschwindigkeit `v = velocity + Vector3(0, -gravity, 0) * dt`, Ziel `to = position + v * dt`. `SweepHit3D.first_hit(position, to, boxes)`:
  - kein Treffer → `position = to`, `velocity = v`, `{}`
  - Treffer → Eintrag `{"index", "position", "normal", "age": age}` an `hits` anhängen; `STOP`: `position` = Trefferpunkt, `velocity = Vector3.ZERO`, `stopped = true`; `REMOVE`: `position` = Trefferpunkt, `alive = false`; `BOUNCE`: `velocity = SweepHit3D.reflect(v, normal, restitution)`, `position` = Trefferpunkt + Normale × 0.001. Rückgabe der Eintrag
- `func run(duration: float, boxes: Array[AABB], hz: int = 120) -> int`: `roundi(duration * hz)` Mal `step(1.0 / hz, boxes)`, Rückgabe `hits.size()`

## Tests
`tests/test_projectile_3d.gd`, Wand `AABB(Vector3(5, -10, -10), Vector3(0.05, 20, 20))`, Projektil bei `Vector3.ZERO`, `gravity = 0.0` (außer im Schwerkrafttest):
- `test_stoppt`: `velocity = Vector3(100, 0, 0)`, `run(1.0, [wand])` → 1 Treffer, `stopped` wahr, `position.x` ungefähr 5.0
- `test_entfernt`: `on_hit = REMOVE`, sonst wie oben → `alive` falsch, 1 Treffer
- `test_abprall`: `on_hit = BOUNCE`, `restitution = 0.5`, `velocity = Vector3(100, 0, 0)`, `run(0.2, [wand])` → 1 Treffer, `velocity.x` ungefähr −50
- `test_lebensdauer`: `lifetime = 0.5`, `velocity = Vector3(1, 0, 0)`, `run(1.0, [])` → `alive` falsch, `age` ungefähr 0.5
- `test_schwerkraft`: `gravity = 9.81`, `velocity = Vector3.ZERO`, `run(1.0, [])` → `position.y` ungefähr −4.9 (Toleranz 0.1)
