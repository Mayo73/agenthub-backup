---
id: T-0576
title: ExportProfile – Exporteinstellungen prüfen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich“ (Windows-Export) und Abnahmekriterium 15: Exporteinstellungen vor dem Export prüfen, Ziel nur im erlaubten Ausgabeordner.

## Dateien
- `core/export_profile.gd` – neu, Klasse `ExportProfile`
- `tests/test_export_profile.gd` – neu

## Akzeptanzkriterien
`class_name ExportProfile`, `extends RefCounted`.
- `var game_name := ""`, `var output_path := ""`, `var icon_path := ""`
- `func validate(allowed_root: String) -> Array`: Liste von Fehlercodes in dieser Reihenfolge:
  - `"name_fehlt"`, wenn `game_name.strip_edges()` leer ist
  - `"pfad_fehlt"`, wenn `output_path` leer ist; sonst:
    - `"keine_exe"`, wenn `output_path.to_lower()` nicht auf `".exe"` endet
    - `"pfad_nicht_erlaubt"`, wenn der Pfad `".."` enthält oder (beide mit `replace("\\", "/")` und `to_lower()`) nicht mit `allowed_root + "/"` beginnt
  - `"icon_kein_ico"`, wenn `icon_path` nicht leer ist und nicht auf `".ico"` endet (ohne Groß/Klein)

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq` (Zahlen vergleicht `check_eq` ungefähr). Einrückung nur mit Tabs. Lokale Variablen mit Typ deklarieren (`var x: float = …`).

## Tests
`tests/test_export_profile.gd`, Ordner `"C:/Spiele"`, Name `"Demo"`:
- `test_gueltig`: Pfad `"C:\\Spiele\\out\\demo.EXE"` (GDScript-Literal mit doppelten Backslashes), Icon `"icon.ico"` → `[]`
- `test_leer`: neues Profil → `["name_fehlt", "pfad_fehlt"]`
- `test_endung`: `"C:/Spiele/out/demo.zip"` → `["keine_exe"]`
- `test_ort`: `"C:/Anders/demo.exe"` → `["pfad_nicht_erlaubt"]`; `"C:/Spiele/../demo.exe"` → `["pfad_nicht_erlaubt"]`
- `test_icon`: gültiger Pfad, Icon `"icon.png"` → `["icon_kein_ico"]`

Review (21.10.2026): gemergt.
