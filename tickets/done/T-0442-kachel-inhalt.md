---
id: T-0442
title: ChunkLayout – Seegras, Felsen und Tiefsee je Kachel
project: zellenphase
priority: 4
after: T-0441, T-0440
---
## Ziel
Auftrag „Fischphase – unendliche Welt“: Seegras, Felsen und Tiefseegebiete entstehen je Kachel aus einem festen Seed. Dieselbe Kachel sieht immer gleich aus.

## Dateien
- `scripts/chunk_layout.gd` – neu, Klasse `ChunkLayout`
- `tests/test_chunk_layout.gd` – neu

## Akzeptanzkriterien
`class_name ChunkLayout`, `extends RefCounted`. Vorher `scripts/reef_layout.gd` (bisheriger fester Riffaufbau), `scripts/world_chunks.gd` und `scripts/seafloor_height.gd` lesen.
- `const WEEDS := 18`, `const ROCKS := 5` (je Kachel)
- `static func seed_for(c: Vector2i, world_seed: int = 7) -> int`: `hash([c.x, c.y, world_seed])`
- `var chunk: Vector2i`, `var items: Array[Dictionary] = []` – je Eintrag wie in `ReefLayout`: `{"kind": "seegras" oder "fels", "position": Vector3, "height": float}`, zusätzlich `"bend": float` (Biegung des Seegrases, −0.6 bis 0.6, bei Felsen 0.0)
- `func _init(c: Vector2i, floor: SeafloorHeight) -> void`: `RandomNumberGenerator` mit `seed_for(c)`; Positionen gleichmäßig innerhalb der Kachel (`WorldChunks.origin_of(c)` plus 0 bis `WorldChunks.SIZE` in x und z), y = `floor.height_at(x, z)`; Seegras Höhe 3–12 m, Felsen 1,5–6 m. In Tiefseerinnen (`floor.is_trench(x, z)`) wächst kein Seegras (Eintrag überspringen).
- `func count(kind: String) -> int`

## Tests
`tests/test_chunk_layout.gd`:
- `test_gleich`: zweimal `ChunkLayout.new(Vector2i(3, -2), SeafloorHeight.new())` → gleiche Anzahl und gleiche erste Position
- `test_verschieden`: Kacheln `(0, 0)` und `(1, 0)` → erste Positionen verschieden
- `test_in_kachel`: alle Positionen der Kachel `(-1, 2)` liegen in x zwischen −64 und 0 und in z zwischen 128 und 192
- `test_auf_dem_boden`: y jeder Position gleich `floor.height_at(x, z)`
- `test_felsen`: `count("fels")` ist 5

Review (20.10.2026): gemergt, nachgebessert: seed_for statisch wie im Ticket, unnötiges if/pass entfernt.
