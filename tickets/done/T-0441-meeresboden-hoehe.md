---
id: T-0441
title: SeafloorHeight – Höhenprofil des Meeresbodens aus Rauschen
project: zellenphase
priority: 4
---
## Ziel
Auftrag „Fischphase – unendliche Welt“: Der Meeresboden bekommt ein Höhenprofil aus Rauschen (`FastNoiseLite`). Dieselbe Stelle hat immer dieselbe Höhe.

## Dateien
- `scripts/seafloor_height.gd` – neu, Klasse `SeafloorHeight`
- `tests/test_seafloor_height.gd` – neu

## Akzeptanzkriterien
`class_name SeafloorHeight`, `extends RefCounted`. Vorher `scripts/fish_world.gd` lesen (`FishWorld.DEPTH` = 60).
- `const RELIEF := 10.0` (höchste Erhebung über dem tiefsten Boden), `const TRENCH := 25.0` (zusätzliche Tiefe in Tiefseegebieten)
- `var noise := FastNoiseLite.new()`, `var trench_noise := FastNoiseLite.new()`
- `func _init(seed_value: int = 7) -> void`: `noise.seed = seed_value`, `noise.frequency = 0.012`, `noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH`; `trench_noise.seed = seed_value + 1`, `trench_noise.frequency = 0.004`
- `func height_at(x: float, z: float) -> float`: y des Bodens. `basis = -FishWorld.DEPTH + (noise.get_noise_2d(x, z) * 0.5 + 0.5) * RELIEF`. Ist `trench_noise.get_noise_2d(x, z) > 0.35`, kommt eine Tiefseerinne dazu: `basis -= TRENCH * clampf((t - 0.35) / 0.3, 0.0, 1.0)`
- `func is_trench(x: float, z: float) -> bool`: `trench_noise.get_noise_2d(x, z) > 0.35`

## Tests
`tests/test_seafloor_height.gd`:
- `test_gleich`: zwei Instanzen mit gleichem Seed → `height_at(12.5, -40.0)` gleich
- `test_anderer_seed`: Seeds 7 und 8 unterscheiden sich an mindestens einer von 10 Stellen (`x = i * 37.0`, `z = i * 11.0`)
- `test_bereich`: an 200 Stellen (`x = i * 13.0 - 1000.0`, `z = i * 7.0`) liegt die Höhe zwischen `-FishWorld.DEPTH - TRENCH - 0.01` und `-FishWorld.DEPTH + RELIEF + 0.01`
- `test_abwechslung`: an diesen 200 Stellen ist der Unterschied zwischen größter und kleinster Höhe mindestens 3 m

Review (20.10.2026): gemergt.
