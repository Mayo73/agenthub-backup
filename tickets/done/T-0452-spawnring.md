---
id: T-0452
title: SpawnRing – Nachschub rings um den Fisch statt in einer festen Welt
project: zellenphase
priority: 4
after: T-0451
---
## Ziel
Auftrag „Fischphase – unendliche Welt“: Nahrung und Fische sollen in der grenzenlosen Welt weiter um den Fisch entstehen und verschwinden, wenn sie weit hinter ihm liegen. Diese Klasse liefert Startlagen in einem Ring um den Fisch und sagt, was zu weit weg ist.

## Dateien
- `scripts/spawn_ring.gd` – neue Klasse
- `tests/test_spawn_ring.gd` – Tests

## Akzeptanzkriterien
`class_name SpawnRing`, `extends RefCounted`. Vorher `scripts/floor_clamp.gd` lesen.
- `const MIN_DISTANCE := 40.0`, `const MAX_DISTANCE := 110.0`, `const DESPAWN_DISTANCE := 160.0` (waagerechter Abstand, nur x und z)
- `var rng := RandomNumberGenerator.new()`; `func _init(seed_value: int = 1) -> void`: `rng.seed = seed_value`
- `func next_position(center: Vector3, floor: SeafloorHeight) -> Vector3`: Winkel zufällig 0..TAU, Abstand zufällig zwischen `MIN_DISTANCE` und `MAX_DISTANCE`, y zufällig zwischen Boden und Oberfläche an dieser Stelle, danach `FloorClamp.clamp_to_water(...)`
- `func near_floor_position(center: Vector3, floor: SeafloorHeight) -> Vector3`: wie `next_position`, aber y = Bodenhöhe + 1.5 (für Algen am Boden)
- `static func flat_distance(a: Vector3, b: Vector3) -> float`: Abstand nur in x und z
- `static func is_far(p: Vector3, center: Vector3) -> bool`: `flat_distance(p, center) > DESPAWN_DISTANCE`

## Tests
`tests/test_spawn_ring.gd` (Boden `SeafloorHeight.new(7)`, Mitte `Vector3(1000, -20, -400)`):
- `test_abstand`: 50 Aufrufe von `next_position` → jeder waagerechte Abstand zwischen 40 und 110
- `test_im_wasser`: 50 Aufrufe → jede Lage erfüllt `FloorClamp.is_in_water`
- `test_bodennah`: `near_floor_position` → `FloorClamp.height_above_floor` ungefähr 1.5
- `test_gleicher_seed`: zwei `SpawnRing.new(5)` liefern dieselbe erste Lage
- `test_weit_weg`: `is_far(Vector3(0, -10, 200), Vector3.ZERO)` wahr, `is_far(Vector3(0, -10, 100), Vector3.ZERO)` falsch; `flat_distance(Vector3(3, -50, 4), Vector3.ZERO)` ist 5.0

Review (20.10.2026): gemergt, nachgebessert: eigene TAU-Konstante entfernt (überdeckte die eingebaute).
