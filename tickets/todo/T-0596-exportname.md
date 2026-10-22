---
id: T-0596
title: ExportName – sicherer Dateiname und Zielpfad für den Export
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich“ (Export, Abnahmekriterien 1 und 15): Aus dem Spielnamen einen sicheren Windows-Dateinamen für die `.exe` bilden und ihn an den Ausgabeordner hängen.

## Dateien
- `core/export_name.gd` – neu, Klasse `ExportName`
- `tests/test_export_name.gd` – neu

## Akzeptanzkriterien
`class_name ExportName`, `extends RefCounted`, nur statische Funktionen.
- `static func file_name(game_name: String) -> String`:
  1. `strip_edges()`
  2. Umlaute ersetzen: „ä“→„ae“, „ö“→„oe“, „ü“→„ue“, „Ä“→„Ae“, „Ö“→„Oe“, „Ü“→„Ue“, „ß“→„ss“
  3. jedes Zeichen außer `A–Z`, `a–z`, `0–9`, `-` und `_` durch `_` ersetzen (`RegEx` mit `"[^A-Za-z0-9_-]"` und `sub(..., "_", true)`)
  4. mehrere `_` hintereinander zu einem zusammenfassen (`RegEx` `"_+"`)
  5. `_` am Anfang und Ende entfernen (`lstrip("_")`, `rstrip("_")`)
  6. leer → `"spiel"`; dann `".exe"` anhängen
- `static func output_path(root: String, game_name: String) -> String`: `root.replace("\\", "/")`, ein abschließendes `/` entfernen, dann `"/" + file_name(game_name)` anhängen

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Kein `assert`, kein `print`. Einrückung nur mit Tabs. Lokale Variablen mit Typ deklarieren.

## Tests
`tests/test_export_name.gd`:
- `test_einfach`: `file_name("Kisten Spiel")` ist „Kisten_Spiel.exe“; `file_name("demo-2")` ist „demo-2.exe“
- `test_umlaute`: `file_name("Größe: 2!")` ist „Groesse_2.exe“; `file_name("Über")` ist „Ueber.exe“
- `test_leer`: `file_name("   ")` ist „spiel.exe“; `file_name("???")` ist „spiel.exe“
- `test_pfad`: `output_path("C:\\Spiele\\", "Demo")` (GDScript-Literal mit doppelten Backslashes) ist „C:/Spiele/Demo.exe“; `output_path("user://export", "Kisten Spiel")` ist „user://export/Kisten_Spiel.exe“
