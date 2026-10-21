---
id: T-0565
title: ScriptHistory – fehlerhafte Scriptänderung melden und letzten gültigen Stand behalten
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich“ (Lastenheft: „Fehlgeschlagene Scriptänderungen verständlich melden und letzten gültigen Stand wiederherstellen“): Verlauf von Scriptständen je Datei, nur gültige werden übernommen.

## Dateien
- `core/script_history.gd` – neu, Klasse `ScriptHistory`
- `tests/test_script_history.gd` – neu

## Akzeptanzkriterien
`class_name ScriptHistory`, `extends RefCounted`. Vorher `core/command_result.gd` lesen. Das Prüfen selbst macht der Aufrufer (z. B. `ScriptCheck`); hier kommt nur das Ergebnis an.
- `var versions: Dictionary = {}` (Pfad → `Array` gültiger Texte, älteste zuerst), `var last_error: Dictionary = {}` (Pfad → Fehlermeldung)
- `const KEEP := 10` (höchstens so viele Versionen je Pfad, älteste fallen weg)
- `func submit(path: String, text: String, ok: bool, error_text: String = "") -> CommandResult`: bei `ok`: an `versions` anhängen (ggf. älteste entfernen), `last_error` für den Pfad löschen, `CommandResult.success({"path": path, "version": version_count(path)})`. Sonst: nichts übernehmen, `last_error[path] = error_text`, `CommandResult.error(CommandResult.EXEC_FAILED, "Script %s hat Fehler: %s. Der letzte gültige Stand bleibt aktiv." % [path, error_text], {"restored": current(path)})`
- `func current(path: String) -> String`: letzte gültige Version oder ""
- `func revert(path: String) -> bool`: letzte Version verwerfen, damit die davor gilt; mit weniger als 2 Versionen `false`
- `func version_count(path: String) -> int`
- `func has_error(path: String) -> bool`

Hinweis Typen: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Werte aus Dictionaries immer mit Typ lesen (`var list: Array = versions.get(path, [])`, `var text: String = list[list.size() - 1]`). Einrückung nur mit Tabs.

## Tests
`tests/test_script_history.gd` (Pfad `p = "res://verhalten/tuer.gd"`):
- `test_gueltig`: `submit(p, "v1", true).code` „ok“, `current(p)` „v1“, `version_count(p)` 1
- `test_fehler_behaelt_stand`: nach „v1“ gültig: `submit(p, "kaputt", false, "Zeile 3: unbekannter Bezeichner")` hat Code „failed“, `data["restored"]` „v1“, die Meldung enthält „letzte gültige Stand“; `current(p)` bleibt „v1“, `has_error(p)` true; danach `submit(p, "v2", true)` → `has_error(p)` false
- `test_zurueck`: „v1“, „v2“ gültig → `revert(p)` true, `current(p)` „v1“; nochmal `revert(p)` false
- `test_grenze`: 12 gültige Stände → `version_count(p)` 10, `current(p)` ist der zwölfte
