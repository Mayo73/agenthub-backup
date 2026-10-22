---
id: T-0564
title: ProjectProperties – dokumentierte Projekteigenschaften mit Prüfung
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Durchstich“ (dokumentierte Projekteigenschaften, über GUI und Agenten gleich änderbar): Ein Satz Projekteigenschaften mit Typ, Standardwert, Grenzen und Beschreibung, der Änderungen prüft.

## Dateien
- `core/project_properties.gd` – neu, Klasse `ProjectProperties`
- `tests/test_project_properties.gd` – neu

## Akzeptanzkriterien
`class_name ProjectProperties`, `extends RefCounted`. Vorher `core/command_result.gd` lesen.
- `const SCHEMA: Dictionary` mit genau diesen Einträgen (je `{"type": …, "default": …, "text": …}`, bei Zahlen zusätzlich `"min"` und `"max"`):
  - `"name"`: `"string"`, Standard `"Neues Projekt"`, Text „Name des Spiels“
  - `"dimension"`: `"string"`, Standard `"2d"`, zusätzlich `"choices": ["2d", "3d"]`, Text „2D- oder 3D-Spiel“
  - `"physics_hz"`: `"int"`, Standard 120, 30 bis 240, Text „Physikschritte pro Sekunde“
  - `"gravity"`: `"float"`, Standard 9.81, 0.0 bis 100.0, Text „Schwerkraft in Einheiten/s²“
  - `"window_width"`: `"int"`, Standard 1280, 320 bis 7680, Text „Fensterbreite in Pixeln“
- `var values: Dictionary = {}`; `func _init() -> void`: alle Standardwerte setzen
- `func set_value(key: String, value: Variant) -> CommandResult`: unbekannt → `CommandResult.error(CommandResult.NOT_FOUND, "Eigenschaft %s gibt es nicht" % key)`; falscher Typ (`"string"` braucht `TYPE_STRING`; `"int"` braucht `TYPE_INT` oder ein ganzzahliges `TYPE_FLOAT`; `"float"` braucht `TYPE_INT` oder `TYPE_FLOAT`) → `INVALID_ARGUMENT` „%s braucht den Typ %s“; außerhalb `min`/`max` oder nicht in `choices` → `INVALID_ARGUMENT` „%s ist außerhalb des erlaubten Bereichs“; sonst speichern (bei `"int"` mit `int(...)`, bei `"float"` mit `float(...)`), `CommandResult.success({"key": key, "value": gespeicherter_wert})`
- `func get_value(key: String) -> Variant`: Wert oder `null`
- `func describe() -> Array[String]`: je Schlüssel alphabetisch `"%s: %s (Standard %s)" % [key, text, str(default)]`
- `func to_dict() -> Dictionary` (Kopie von `values`) und `static func from_dict(d: Dictionary) -> ProjectProperties` (jeden bekannten Schlüssel über `set_value`; ungültige Werte behalten den Standard)

Hinweis Typen: Tests erben von `res://tests/base_test.gd` und nutzen `check`/`check_eq`. Werte aus Dictionaries immer mit Typ lesen (`var entry: Dictionary = SCHEMA[key]`, `var kind: String = entry["type"]`); `typeof(value)` für die Typprüfung. Einrückung nur mit Tabs.

## Tests
`tests/test_project_properties.gd`:
- `test_standard`: `get_value("physics_hz")` 120, `get_value("dimension")` „2d“
- `test_setzen`: `set_value("gravity", 20).code` „ok“, `get_value("gravity")` 20.0
- `test_fehler`: `set_value("farbe", 1).code` „not_found“, `set_value("physics_hz", "schnell").code` „invalid_argument“, `set_value("physics_hz", 500).code` „invalid_argument“, `set_value("dimension", "4d").code` „invalid_argument“
- `test_beschreibung`: `describe().size()` 5, der erste Eintrag beginnt mit „dimension: “
- `test_speichern`: `set_value("name", "Kistenspiel")`, über `JSON.parse_string(JSON.stringify(p.to_dict()))` und `from_dict` → Name „Kistenspiel“, `get_value("physics_hz")` 120 und `typeof(...)` ist `TYPE_INT`

Review (21.10.2026): von Claude fertiggestellt. Der Stand des Agents war richtig bis auf describe() (untypisiertes Array statt Array[String]); übernommen und eine Zeile korrigiert, 649 Tests grün.
