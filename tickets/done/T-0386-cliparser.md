---
id: T-0386
title: CliParser – Befehlszeile in Befehl und Parameter zerlegen
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich: Laufzeit, CLI, Editor, Export“ (Lastenheft Muss 7 „lokale CLI“): Die CLI nimmt Befehle in der Form `scene.add type=Node2D parent= props={"mass":2}` an. Dieses Ticket zerlegt die Argumente in Befehlsname und Parameter mit passenden Typen. Reine Logik.

## Dateien
- `core/cli_parser.gd` – neu, Klasse `CliParser`
- `tests/test_cli_parser.gd` – neu

## Akzeptanzkriterien
`class_name CliParser`, `extends RefCounted`, nur statische Funktionen:
- `static func parse_value(text: String) -> Variant`:
  - `"true"` → `true`, `"false"` → `false`, `"null"` → `null`
  - ganze Zahl (`text.is_valid_int()`) → `int`; Kommazahl mit Punkt (`text.is_valid_float()`) → `float`
  - beginnt mit `{` oder `[`: `JSON.parse_string(text)`; ist das Ergebnis `null`, den Text unverändert zurückgeben
  - beginnt und endet mit `"` (mindestens 2 Zeichen): Text ohne die Anführungszeichen (so bleiben „42“ oder „true“ Zeichenketten)
  - sonst der Text unverändert
- `static func parse(argv: PackedStringArray) -> Dictionary`: Rückgabe `{"command": String, "args": Dictionary, "error": String}`
  - leere Liste → `error` „Kein Befehl angegeben“
  - erstes Element ist der Befehlsname; enthält es `=`, → `error` „Erst den Befehl nennen, dann Parameter“
  - jedes weitere Element muss `name=wert` sein (Trennung am **ersten** `=`; der Wert darf leer sein und wird dann `""`); sonst `error` `"Parameter ohne '=': %s"`; leerer Name → `error` „Parametername fehlt“
  - doppelter Name → `error` `"Parameter doppelt: %s"`
  - Werte mit `parse_value`; ohne Fehler ist `error` „“

## Tests
`tests/test_cli_parser.gd`:
- `test_werte`: `parse_value("12")` 12 und `typeof` `TYPE_INT`; `parse_value("2.5")` 2.5; `parse_value("true")` wahr; `parse_value("Node2D")` „Node2D“; `parse_value("\"42\"")` „42“ als `TYPE_STRING`
- `test_json`: `parse_value("{\"mass\": 2}")` ist ein Dictionary mit `mass` 2; `parse_value("[1, 2]").size()` 2; `parse_value("{kaputt")` „{kaputt“
- `test_befehl`: `parse(PackedStringArray(["scene.add", "type=Node2D", "parent=", "props={\"mass\":2}"]))` → `command` „scene.add“, `args["type"]` „Node2D“, `args["parent"]` „“, `args["props"]["mass"]` 2, `error` „“
- `test_gleichheitszeichen_im_wert`: `["x", "formel=a=b"]` → `args["formel"]` „a=b“
- `test_fehler`: `[]` → „Kein Befehl angegeben“; `["a=1"]` → „Erst den Befehl nennen, dann Parameter“; `["x", "ohne"]` → „Parameter ohne '=': ohne“; `["x", "=1"]` → „Parametername fehlt“; `["x", "a=1", "a=2"]` → „Parameter doppelt: a“

Review (19.10.2026): gemergt, nachgebessert: JSON nach Vorgabe (auch {}), leere Teile sind ein Fehler, @tool entfernt, Test test_json_und_leere_teile.
