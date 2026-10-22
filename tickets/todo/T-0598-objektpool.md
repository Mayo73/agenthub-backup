---
id: T-0598
title: ObjectPool – Kennungen für Geschosse und Effekte wiederverwenden
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „2D-Arbeitsablauf“: Häufig erzeugte Objekte (Geschosse, Funken) nicht ständig neu anlegen, sondern freie Kennungen wiederverwenden.

## Dateien
- `core/object_pool.gd` – neu, Klasse `ObjectPool`
- `tests/test_object_pool.gd` – neu

## Akzeptanzkriterien
`class_name ObjectPool`, `extends RefCounted`.
- `var prefix := "obj"`, `var free_ids: Array[String] = []`, `var used: Array[String] = []`, `var created := 0`
- `func _init(id_prefix: String = "obj") -> void`
- `func acquire() -> String`: ist `free_ids` nicht leer, `free_ids.pop_back()` nehmen; sonst `created += 1` und `"%s%d" % [prefix, created]`; die Kennung an `used` anhängen und zurückgeben
- `func release(id: String) -> bool`: nicht in `used` → `false`; sonst aus `used` entfernen, an `free_ids` anhängen, `true`
- `func active_count() -> int`: `used.size()`
- `func prewarm(n: int) -> void`: `n` neue Kennungen erzeugen (wie in `acquire`, `created` zählt mit) und der Reihe nach an `free_ids` anhängen

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Kein `assert`, kein `print`. Einrückung nur mit Tabs.

## Tests
`tests/test_object_pool.gd`, jeweils `ObjectPool.new("kugel")`:
- `test_neu`: `acquire()` ist „kugel1“, nochmal „kugel2“, `active_count()` 2
- `test_wiederverwenden`: zwei holen, `release("kugel1")` wahr, nochmal falsch; `acquire()` ist „kugel1“; `active_count()` 2
- `test_unbekannt`: `release("kugel9")` falsch
- `test_vorwaermen`: `acquire()`, `acquire()`, dann `prewarm(3)` → `created` 5, `free_ids.size()` 3; `acquire()` ist „kugel5“
