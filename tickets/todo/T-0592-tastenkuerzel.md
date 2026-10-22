---
id: T-0592
title: HotkeyMap – Tastenkürzel für Editorbefehle mit Konfliktprüfung
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich“ (Editor): Tastenkürzel einheitlich schreiben, Befehlen zuordnen und doppelte Belegungen verständlich abweisen.

## Dateien
- `core/hotkey_map.gd` – neu, Klasse `HotkeyMap`
- `tests/test_hotkey_map.gd` – neu

## Akzeptanzkriterien
`class_name HotkeyMap`, `extends RefCounted`. Vorher `core/command_result.gd` lesen.
- `var bindings: Dictionary = {}` (normiertes Kürzel → Befehlsname)
- `static func normalize(combo: String) -> String`: an „+“ trennen, jedes Teil mit `strip_edges().to_lower()`, leere Teile weglassen; zuerst die vorhandenen Umschalttasten in der festen Reihenfolge `"ctrl"`, `"alt"`, `"shift"`, danach die übrigen Teile in ihrer Reihenfolge; mit „+“ verbinden. Leer → ""
- `func bind(combo: String, command: String) -> CommandResult`: Kürzel normieren; leer → `CommandResult.error(CommandResult.INVALID_ARGUMENT, "Tastenkürzel fehlt")`; schon mit einem **anderen** Befehl belegt → `CommandResult.error(CommandResult.CONFLICT, "%s ist schon mit %s belegt" % [kuerzel, alter_befehl])`; sonst speichern und `CommandResult.success({"combo": kuerzel, "command": command})`
- `func unbind(combo: String) -> bool`: normiert entfernen, `true` wenn es den Eintrag gab
- `func command_for(combo: String) -> String`: Befehl zum normierten Kürzel oder ""
- `func combos_for(command: String) -> Array[String]`: alle Kürzel dieses Befehls, sortiert

Hinweis: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Kein `assert`, kein `print`. Einrückung nur mit Tabs. Lokale Variablen mit Typ deklarieren, Ergebnisse in `var result: Array[String] = []` sammeln.

## Tests
`tests/test_hotkey_map.gd`, in `setup()`: `keys = HotkeyMap.new()`:
- `test_normieren`: `normalize("Shift+Ctrl+S")` ist „ctrl+shift+s“; `normalize(" s ")` ist „s“; `normalize("")` ist ""; `normalize("Alt + F4")` ist „alt+f4“
- `test_belegen`: `bind("Ctrl+S", "speichern").code` „ok“, `command_for("ctrl+s")` „speichern“, `command_for("ctrl+z")` ""
- `test_konflikt`: nach `bind("Ctrl+S", "speichern")` hat `bind("S+Ctrl", "rueckgaengig")` Code „conflict“, die Meldung enthält „speichern“; `bind("ctrl+s", "speichern").code` ist „ok“ (gleicher Befehl)
- `test_mehrere`: `bind("Ctrl+Z", "rueckgaengig")`, `bind("Alt+Backspace", "rueckgaengig")` → `combos_for("rueckgaengig")` ist `["alt+backspace", "ctrl+z"]`
- `test_entfernen`: `bind("F5", "spielen")`, `unbind("f5")` wahr, `command_for("F5")` "", nochmal `unbind("F5")` falsch; `bind("", "x").code` „invalid_argument“
