---
id: T-0440
title: WorldChunks – welche Kacheln um den Fisch geladen sind
project: zellenphase
priority: 4
---
## Ziel
Auftrag „Fischphase – unendliche Welt“: Statt der festen Welt von 300 × 300 m entsteht die Unterwasserwelt aus Kacheln von 64 × 64 m um den Fisch. Diese Klasse rechnet aus, welche Kacheln gebraucht werden und welche nachgeladen bzw. entfernt werden müssen.

## Dateien
- `scripts/world_chunks.gd` – neu, Klasse `WorldChunks`
- `tests/test_world_chunks.gd` – neu

## Akzeptanzkriterien
`class_name WorldChunks`, `extends RefCounted`. Koordinaten wie in der Fischphase: Meter, x und z waagerecht.
- `const SIZE := 64.0`, `const RADIUS := 2` (geladen sind alle Kacheln bis 2 Kacheln Abstand in x und z, also 5 × 5)
- `var loaded: Dictionary = {}` (Kachel `Vector2i` → `true`)
- `static func chunk_of(p: Vector3) -> Vector2i`: `Vector2i(floori(p.x / SIZE), floori(p.z / SIZE))`
- `static func origin_of(c: Vector2i) -> Vector3`: Ecke der Kachel, `Vector3(c.x * SIZE, 0.0, c.y * SIZE)`
- `static func needed(center: Vector3) -> Array[Vector2i]`: alle Kacheln um `chunk_of(center)` im Abstand bis `RADIUS`, sortiert nach x, dann y
- `func update(center: Vector3) -> Dictionary`: `{"load": Array[Vector2i], "unload": Array[Vector2i]}`; `load` sind gebrauchte, noch nicht geladene Kacheln (in der Reihenfolge von `needed`), `unload` sind geladene, nicht mehr gebrauchte (sortiert nach x, dann y). Danach enthält `loaded` genau die gebrauchten Kacheln.

## Tests
`tests/test_world_chunks.gd`:
- `test_kachel`: `chunk_of(Vector3(10, -20, 10))` → `(0, 0)`; `chunk_of(Vector3(-1, 0, 130))` → `(-1, 2)`
- `test_ursprung`: `origin_of(Vector2i(-1, 2))` → `Vector3(-64, 0, 128)`
- `test_gebraucht`: `needed(Vector3.ZERO).size()` 25, erste `(-2, -2)`, letzte `(2, 2)`
- `test_erstes_update`: `update(Vector3.ZERO)` → 25 laden, 0 entfernen
- `test_weiterschwimmen`: nach `update(Vector3.ZERO)` → `update(Vector3(64, 0, 0))` → 5 laden (alle mit x = 3), 5 entfernen (alle mit x = -2); `loaded.size()` 25
- `test_gleiche_kachel`: zweimal `update(Vector3(5, 0, 5))` → beim zweiten 0 laden, 0 entfernen

Review (20.10.2026): gemergt, nachgebessert: umstaendliche Hilfsliste und leeres else beim Entladen entfernt.
