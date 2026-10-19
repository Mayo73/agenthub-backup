---
id: T-0413
title: PhysicsWorld2D – Körper, statische Hindernisse, Kollisionsebenen und Kontakte
project: hub-engine
priority: 3
after: T-0412
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (Muss 5: Kollisionsgruppen, Treffer-/Kontaktinformationen; Abnahmekriterium 6): Eine kleine 2D-Welt, die mehrere `Body2D` gegen statische Rechtecke prüft, Kollisionsebenen beachtet und Kontakte meldet.

## Dateien
- `core/physics_world_2d.gd` – neu, Klasse `PhysicsWorld2D`
- `tests/test_physics_world_2d.gd` – neu

## Akzeptanzkriterien
`class_name PhysicsWorld2D`, `extends RefCounted`. Nutzt `Body2D` (`core/body_2d.gd`) und `CollisionLayers.collides` (`core/collision_layers.gd`), beide vorher lesen. Körper sind Punkte; statische Hindernisse sind `Rect2`.
- `var bodies: Dictionary = {}` (Kennung → `{"body": Body2D, "layer": int, "mask": int}`), `var statics: Array[Dictionary] = []` (`{"id": String, "rect": Rect2, "layer": int, "mask": int}`), `var contacts: Array[Dictionary] = []`, `var step_count := 0`, `var floor_y := 1000.0`
- `func add_body(id: String, body: Body2D, layer: int = 1, mask: int = 1) -> void`
- `func add_static(id: String, rect: Rect2, layer: int = 1, mask: int = 1) -> void`
- `func step(dt: float) -> Array[Dictionary]`: `step_count += 1`; für jeden Körper (Kennungen sortiert): alte Position merken, `body.step(dt, floor_y)`; dann jedes Hindernis in Reihenfolge prüfen, ob `rect.has_point(body.position)` und `CollisionLayers.collides(layer, mask, s.layer, s.mask)`: dann Körper auf die alte Position zurücksetzen, `velocity = Vector2.ZERO`, Kontakt `{"step": step_count, "body": id, "static": s.id}` anhängen und kein weiteres Hindernis für diesen Körper prüfen. Rückgabe: die Kontakte dieses Schritts (auch an `contacts` anhängen)
- `func run(seconds: float, hz: int = 120) -> int`: `roundi(seconds * hz)` Schritte, Rückgabe Anzahl aller Kontakte in dieser Zeit

## Tests
`tests/test_physics_world_2d.gd`, Welt mit Hindernis „block“ `Rect2(-5, 5, 10, 2)` (Ebene 1, Maske 1):
- `test_kontakt`: Körper „a“ bei `(0, 0)`, Ebene 1, Maske 1; `run(2.0)` → mindestens 1 Kontakt, erster Kontakt `body` „a“, `static` „block“; `a.position.y < 5.0`
- `test_ebene_ignoriert`: Körper „b“ bei `(0, 0)`, Ebene 2, Maske 2; `run(2.0)` → 0 Kontakte, `b.position.y > 7.0`
- `test_reihenfolge`: Körper „b“ und „a“ (beide Ebene 1) über dem Block; der erste Kontakt in `step()` mit zwei Kontakten gehört zu „a“
- `test_schrittzahl`: `run(1.0)` → `step_count` 120
