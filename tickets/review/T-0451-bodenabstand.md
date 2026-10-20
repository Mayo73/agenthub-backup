---
id: T-0451
title: FloorClamp – im Wasser bleiben über dem gewellten Meeresboden
project: zellenphase
priority: 4
after: T-0441
---
## Ziel
Auftrag „Fischphase – unendliche Welt“: Ohne Weltränder in x und z begrenzen nur noch Oberfläche und Meeresboden die Lage. Der Boden ist jetzt gewellt (`SeafloorHeight`), deshalb braucht es eine Begrenzung, die die Bodenhöhe an der jeweiligen Stelle beachtet.

## Dateien
- `scripts/floor_clamp.gd` – neue Klasse
- `tests/test_floor_clamp.gd` – Tests

## Akzeptanzkriterien
`class_name FloorClamp`, `extends RefCounted`, nur statische Funktionen. Vorher `scripts/seafloor_height.gd` und `scripts/fish_world.gd` lesen.
- `const SURFACE_MARGIN := 0.5`, `const FLOOR_MARGIN := 1.0`
- `static func clamp_to_water(p: Vector3, floor: SeafloorHeight) -> Vector3`: x und z bleiben unverändert (keine Ränder); y wird zwischen `floor.height_at(p.x, p.z) + FLOOR_MARGIN` und `-SURFACE_MARGIN` begrenzt
- `static func height_above_floor(p: Vector3, floor: SeafloorHeight) -> float`: `p.y - floor.height_at(p.x, p.z)`
- `static func is_in_water(p: Vector3, floor: SeafloorHeight) -> bool`: `p.y < 0.0` und `p.y > floor.height_at(p.x, p.z)`

## Tests
`tests/test_floor_clamp.gd` (Boden mit `SeafloorHeight.new(7)`):
- `test_keine_raender`: `clamp_to_water(Vector3(5000, -20, -7000), floor)` hat x 5000 und z -7000
- `test_oberflaeche`: Lage mit y = 3.0 → y ist -0.5
- `test_boden`: Lage mit y = -500 → y ist `floor.height_at(x, z) + 1.0`
- `test_ueber_boden`: `height_above_floor(Vector3(10, floor.height_at(10, 20) + 4.0, 20), floor)` ist 4.0
- `test_im_wasser`: Lage 1 m über dem Boden an dieser Stelle → wahr; y = 2.0 → falsch; 1 m unter dem Boden → falsch
