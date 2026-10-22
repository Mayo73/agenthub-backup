---
id: T-0609
title: SeededRandom – reproduzierbarer Zufall für Spiele und Tests
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich“: Zufall, der mit demselben Startwert immer dieselbe Folge liefert, damit Spieltests und KI-Aufträge reproduzierbar sind.

## Dateien
- `core/seeded_random.gd` – neu, Klasse `SeededRandom`
- `tests/test_seeded_random.gd` – neu

## Akzeptanzkriterien
`class_name SeededRandom`, `extends RefCounted`. Intern `var _rng := RandomNumberGenerator.new()`, `var seed_value := 0`.
- `func _init(start_seed: int = 0) -> void`: `seed_value = start_seed`, `_rng.seed = start_seed`
- `func reset() -> void`: `_rng.seed = seed_value` (Folge beginnt von vorn)
- `func range_int(a: int, b: int) -> int`: `_rng.randi_range(a, b)`
- `func range_float(a: float, b: float) -> float`: `_rng.randf_range(a, b)`
- `func chance(p: float) -> bool`: `p <= 0.0` → `false`, `p >= 1.0` → `true`, sonst `_rng.randf() < p`
- `func pick(items: Array) -> Variant`: leer → `null`; sonst `items[range_int(0, items.size() - 1)]`
- `func shuffled(items: Array) -> Array`: Kopie (`items.duplicate()`), Fisher-Yates mit `range_int`, Original bleibt unverändert

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Kein `assert`, kein `print`. Einrückung nur mit Tabs. Lokale Variablen mit Typ deklarieren.

## Tests
`tests/test_seeded_random.gd`:
- `test_gleicher_seed`: zwei `SeededRandom.new(42)`, je 10 Werte `range_int(0, 1000)` → beide Listen gleich
- `test_reset`: `SeededRandom.new(7)`, 5 Werte `range_float(0.0, 1.0)` merken, `reset()`, wieder 5 Werte → gleich
- `test_grenzen`: 200-mal `range_int(3, 5)` liegt immer in 3..5
- `test_chance_grenzen`: `chance(0.0)` immer falsch, `chance(1.0)` immer wahr (je 50-mal)
- `test_pick`: `pick([])` ist `null`; `pick(["a", "b", "c"])` ist in der Liste
- `test_shuffled`: `var a := [1, 2, 3, 4, 5]`, `shuffled(a)` hat Größe 5 und sortiert `[1, 2, 3, 4, 5]`; `a` ist weiter `[1, 2, 3, 4, 5]`