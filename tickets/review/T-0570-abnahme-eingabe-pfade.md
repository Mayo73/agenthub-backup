---
id: T-0570
title: Abnahmetests Kriterium 9 und 15 – Testeingabe und unzulässige Pfade
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Abnahme“: Kriterium 9 (Taste 120 Schritte halten, zweite Taste zeitweise dazu, Abbruch lässt nichts gedrückt) und Kriterium 15 (unzulässige Zielpfade scheitern verständlich). Nur zwei neue Tests.

## Dateien
- `tests/test_abnahme_eingabe.gd` – neu
- `tests/test_abnahme_pfade.gd` – neu

## Akzeptanzkriterien
Vorher `core/input_sequence.gd` und `core/path_guard.gd` lesen.

Hinweis Typen: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Ergebnisse typisiert (`var pressed: Array[String] = seq.pressed_at(45)`, `var r: CommandResult = guard.check(...)`). Einrückung nur mit Tabs.

## Tests
`tests/test_abnahme_eingabe.gd` (in `setup()`: `seq = InputSequence.new()`, `seq.hold("rechts", 0, 120)`, `seq.hold("springen", 30, 60)`):
- `test_gehalten`: `is_pressed("rechts", 0)` und `is_pressed("rechts", 119)` true, `is_pressed("rechts", 120)` false; über die Schritte 0 bis 199 gezählt genau 120 mit „rechts“ gedrückt
- `test_kombiniert`: `pressed_at(45)` enthält „rechts“ und „springen“; `pressed_at(70)` enthält nur „rechts“ (Größe 1)
- `test_abbruch`: `abort(45)` liefert 2 Einträge, alle mit `pressed` false, der erste mit `action` „rechts“, der zweite „springen“; `abort(130)` ist leer

`tests/test_abnahme_pfade.gd` (in `setup()`: `guard = PathGuard.new()`, `guard.add_root("user://projekte/kisten")`, `guard.add_root("user://export")`):
- `test_erlaubt`: `check("user://projekte/kisten/szenen/start.json").code` „ok“, `check("user://export/kisten.exe").code` „ok“
- `test_ausserhalb`: `check("C:/Windows/system32/x.dll")` und `check("user://projekte/anderes/a.json")` haben Code „forbidden_path“, die Meldung enthält „außerhalb der erlaubten Orte“
- `test_ausbruch`: `check("user://projekte/kisten/../../geheim.txt").code` ist „forbidden_path“
- `test_aehnlicher_name`: `check("user://export2/x.txt").code` ist „forbidden_path“
