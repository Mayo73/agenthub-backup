---
id: T-0406
title: VersionCheck – Versionen vergleichen und Mindestversionen prüfen
project: hub-engine
priority: 3
---
## Ziel
Meilenstein „Module“ (Muss 2 und 11: Versionskompatibilität von Engine, Modulen und Projekten): Versionsnummern der Form „1.2.3“ vergleichen und Anforderungen wie „>=1.2.0“ prüfen.

## Dateien
- `core/version_check.gd` – neu, Klasse `VersionCheck`
- `tests/test_version_check.gd` – neu

## Akzeptanzkriterien
`class_name VersionCheck`, `extends RefCounted`, nur statische Funktionen:
- `static func parse(version: String) -> Array[int]`: an `.` trennen; genau drei Teile, jeder `is_valid_int()` und ≥ 0 → `[major, minor, patch]`; sonst `[]`
- `static func compare(a: String, b: String) -> int`: −1, 0 oder 1 (Teil für Teil); ist eine Version ungültig → 0
- `static func satisfies(version: String, requirement: String) -> bool`: Anforderung ist `">=x.y.z"`, `"<x.y.z"`, `"=x.y.z"` oder leer (leer → wahr). `">="` vor `"="` prüfen. Unbekannter Operator oder ungültige Version → falsch
- `static func check(what: String, version: String, requirement: String) -> CommandResult`: erfüllt → `CommandResult.success({"version": version})`; sonst `CommandResult.error(CommandResult.INCOMPATIBLE, "%s %s erfüllt %s nicht" % [what, version, requirement])`

## Tests
`tests/test_version_check.gd`:
- `test_lesen`: `parse("1.2.3")` `[1, 2, 3]`; `parse("1.2")` und `parse("a.b.c")` leer
- `test_vergleich`: `compare("1.2.3", "1.10.0")` −1; `compare("2.0.0", "1.9.9")` 1; `compare("1.0.0", "1.0.0")` 0
- `test_anforderung`: `satisfies("1.2.0", ">=1.1.0")` wahr; `satisfies("1.0.0", ">=1.1.0")` falsch; `satisfies("1.0.0", "<2.0.0")` wahr; `satisfies("1.0.0", "=1.0.0")` wahr; `satisfies("1.0.0", "")` wahr; `satisfies("1.0.0", "~1.0.0")` falsch
- `test_pruefen`: `check("Modul beispiel", "0.9.0", ">=1.0.0")` → `code` „incompatible“, Meldung „Modul beispiel 0.9.0 erfüllt >=1.0.0 nicht“; `check("Modul beispiel", "1.0.0", ">=1.0.0").is_ok()` wahr

Review (19.10.2026): gemergt.
