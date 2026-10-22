---
id: T-0575
title: RecentProjects – zuletzt geöffnete Projekte
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich“ (Projekt öffnen): Der Editor merkt sich die zuletzt geöffneten Projekte, neueste zuerst, ohne Doppelte.

## Dateien
- `core/recent_projects.gd` – neu, Klasse `RecentProjects`
- `tests/test_recent_projects.gd` – neu

## Akzeptanzkriterien
`class_name RecentProjects`, `extends RefCounted`.
- `var paths: Array = []`, `var limit := 5`
- `func _init(max_count: int = 5) -> void`: `limit = max_count`
- `func add(path: String) -> void`: `path.replace("\\", "/")` (Backslash zu Schrägstrich); einen vorhandenen Eintrag mit gleichem Pfad ohne Rücksicht auf Groß- und Kleinschreibung entfernen (`to_lower()` vergleichen); den neuen vorne einfügen; auf `limit` Einträge kürzen
- `func remove(path: String) -> void`: wie oben normalisieren, passenden Eintrag (ohne Groß/Klein) entfernen
- `func to_dict() -> Dictionary`: `{"paths": paths.duplicate(), "limit": limit}`
- `static func from_dict(d: Dictionary) -> RecentProjects`: `limit` aus `d.get("limit", 5)` (als int), dann die Einträge aus `d.get("paths", [])` von hinten nach vorne mit `add` übernehmen, nur Strings

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq` (Zahlen vergleicht `check_eq` ungefähr). Einrückung nur mit Tabs. Lokale Variablen mit Typ deklarieren (`var x: float = …`).

## Tests
`tests/test_recent_projects.gd`:
- `test_reihenfolge`: `add("a")`, `add("b")`, `add("c")` → `paths` ist `["c", "b", "a"]`
- `test_doppelt`: `add("c:/spiele/a")`, `add("x")`, `add("C:\\Spiele\\A")` (GDScript-Literal mit doppelten Backslashes) → `paths` ist `["C:/Spiele/A", "x"]`
- `test_grenze`: `RecentProjects.new(2)`, drei Pfade → `paths.size()` ist 2
- `test_speichern`: `add("a")`, `add("b")`, `from_dict(to_dict()).paths` ist `["b", "a"]`; `remove("B")` → `["a"]`

Review (21.10.2026): gemergt, nachgebessert: from_dict liest paths als untypisiertes Array.
