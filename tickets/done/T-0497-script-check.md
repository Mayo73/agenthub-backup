---
id: T-0497
title: ScriptCheck – Scriptentwürfe vor der Übernahme prüfen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „KI, Agenten und Hub“ (Muss 9: „Script-/Verhaltensentwürfe vor Übernahme auf gültige Syntax prüfen“; Muss 4: „Fehlgeschlagene Scriptänderungen verständlich melden und letzten gültigen Stand wiederherstellen“). Zuerst prüfen einfache Regeln den Text mit Zeilennummer; erst wenn sie passen, übersetzt Godot den Quelltext im Speicher.

## Dateien
- `core/script_check.gd` – neu, Klasse `ScriptCheck`
- `tests/test_script_check.gd` – neu

## Akzeptanzkriterien
`class_name ScriptCheck`, `extends RefCounted`.
- `static func quick_problems(source: String) -> Array[String]`: Meldungen mit Zeilennummer (ab 1), ohne Godot zu fragen:
  - Zeile beginnt mit Leerzeichen statt Tab: `"Zeile %d: mit Tabs einrücken, nicht mit Leerzeichen"`
  - Zeile beginnt (nach Einrückung) mit `func `, `if `, `elif `, `else`, `for `, `while ` oder `match `, endet aber (ohne Kommentar ab `#` und Leerraum) nicht auf `:` → `"Zeile %d: Doppelpunkt fehlt"`
  - am Ende ungleich viele öffnende und schließende Klammern `(`/`)`, `[`/`]` oder `{`/`}` → `"Klammern sind nicht ausgeglichen"`
- `static func check(source: String) -> CommandResult`: leer (nach `strip_edges()`) → `INVALID_ARGUMENT`, `"Das Script ist leer"`; `quick_problems` nicht leer → `INVALID_ARGUMENT`, Meldungen mit `"; "` verbunden, `data = {"problems": liste}`. Sonst `var s := GDScript.new()`, `s.source_code = source`, `s.reload() != OK` → `EXEC_FAILED`, `"Das Script enthält Fehler und wurde nicht übernommen"`; sonst `success({"base": s.get_instance_base_type()})`
- `var last_good := ""`; `func apply(source: String) -> CommandResult`: ok → `last_good = source`; Fehler → `last_good` bleibt, das Fehlerergebnis bekommt zusätzlich `data["restored"] = last_good`

Wichtig: In den Tests **nur** Fehlerbeispiele verwenden, die schon `quick_problems` erkennt. Fehlerhafter Quelltext, der bis zu `reload()` kommt, schreibt „Parse Error“ ins Protokoll, und dann gilt die ganze Prüfung als fehlgeschlagen.

## Tests
`tests/test_script_check.gd`:
- `test_gueltig`: `check("extends Node\n\nfunc f() -> int:\n\treturn 1\n")` ok, `data.base` „Node“
- `test_leer`: `check("   ")` → „invalid_argument“
- `test_leerzeichen`: `quick_problems("extends Node\nfunc f() -> void:\n    pass\n")` enthält „Zeile 3: mit Tabs einrücken, nicht mit Leerzeichen“
- `test_doppelpunkt`: `quick_problems("extends Node\nfunc f() -> void\n\tpass\n")` enthält „Zeile 2: Doppelpunkt fehlt“
- `test_klammern`: `check("extends Node\nfunc f() -> void:\n\tprint((1)\n")` → „invalid_argument“, `data.problems` enthält „Klammern sind nicht ausgeglichen“
- `test_wiederherstellen`: `apply` mit dem gültigen Text aus `test_gueltig`, dann `apply` mit dem Text aus `test_doppelpunkt` → Fehler, `data.restored` ist der gültige Text, `last_good` unverändert

Review (21.10.2026): selbst umgesetzt. Der Agent scheiterte 5x an GDScript-Fehlern (trim_left gibt es nicht, doppelte Schleifenvariable, StringName statt String bei get_instance_base_type). core/script_check.gd und tests/test_script_check.gd mit 6 Tests, verify grün.
