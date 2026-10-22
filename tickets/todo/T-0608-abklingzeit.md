---
id: T-0608
title: Cooldown – Abklingzeiten für Fähigkeiten und Waffen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“: Eine wiederverwendbare Abklingzeit, mit der Spiele Schüsse, Sprünge oder Fähigkeiten zeitlich begrenzen.

## Dateien
- `core/cooldown.gd` – neu, Klasse `Cooldown`
- `tests/test_cooldown.gd` – neu

## Akzeptanzkriterien
`class_name Cooldown`, `extends RefCounted`.
- `var duration := 1.0`, `var remaining := 0.0`, `var charges_max := 1`, `var charges := 1`
- `func _init(seconds: float = 1.0, max_charges: int = 1) -> void`: setzt `duration`, `charges_max` und `charges = max_charges`
- `func ready() -> bool`: `charges > 0`
- `func trigger() -> bool`: nicht `ready()` → `false`; sonst `charges -= 1`; war `remaining <= 0.0`, dann `remaining = duration`; `true`
- `func tick(delta: float) -> void`: nur wenn `charges < charges_max`: `remaining -= delta`; solange `remaining <= 0.0` und `charges < charges_max`: `charges += 1`, und ist danach `charges < charges_max`, `remaining += duration`, sonst `remaining = 0.0`
- `func progress() -> float`: `charges >= charges_max` → `1.0`; sonst `clampf(1.0 - remaining / duration, 0.0, 1.0)`

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Kein `assert`, kein `print`. Einrückung nur mit Tabs. Lokale Variablen mit Typ deklarieren.

## Tests
`tests/test_cooldown.gd`:
- `test_einmal`: `Cooldown.new(2.0)`: `trigger()` wahr, sofort nochmal falsch; `tick(1.0)` → `ready()` falsch, `progress()` 0.5 (Toleranz 0.001); `tick(1.0)` → `ready()` wahr
- `test_ladungen`: `Cooldown.new(1.0, 3)`: dreimal `trigger()` wahr, viertes falsch; `tick(1.0)` → `charges` 1; `tick(2.0)` → `charges` 3, `remaining` 0.0
- `test_voll_kein_ticken`: `Cooldown.new(1.0)`, `tick(5.0)` → `charges` 1, `remaining` 0.0, `progress()` 1.0
- `test_grosser_schritt`: `Cooldown.new(1.0, 2)`, zweimal `trigger()`, `tick(10.0)` → `charges` 2