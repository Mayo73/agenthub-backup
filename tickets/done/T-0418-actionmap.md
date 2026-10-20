---
id: T-0418
title: ActionMap – Eingabeaktionen mit Tasten und Maustasten belegen
project: hub-engine
priority: 3
---
## Ziel
Meilenstein „2D-Arbeitsablauf“ (Muss 4: Eingabeaktionen mit Tastatur/Maus): Projektbezogene Eingabeaktionen als JSON-fähige Daten, die Editor und Agenten bearbeiten und die später in Godots InputMap übertragen werden.

## Dateien
- `core/action_map.gd` – neu, Klasse `ActionMap`
- `tests/test_action_map.gd` – neu

## Akzeptanzkriterien
`class_name ActionMap`, `extends RefCounted`. Eingaben sind Texte: Tasten mit Präfix `"taste:"` und einem Namen aus `OS.find_keycode_from_string(...)` (z. B. `"taste:Space"`, `"taste:A"`), Maustasten `"maus:links"`, `"maus:rechts"`, `"maus:mitte"`.
- `var actions: Dictionary = {}` (Aktion → `Array[String]` Eingaben)
- `static func is_valid_input(input: String) -> bool`: `"maus:"` mit einem der drei Namen, oder `"taste:"` und `OS.find_keycode_from_string(rest) != KEY_NONE`
- `func add_action(name: String) -> bool`: leerer Name oder schon vorhanden → `false`
- `func bind(action: String, input: String) -> CommandResult`: Aktion fehlt → `NOT_FOUND`, `"Aktion %s gibt es nicht"`; Eingabe ungültig → `INVALID_ARGUMENT`, `"Eingabe %s ist ungültig"`; schon an diese Aktion gebunden → `success` ohne Änderung; sonst anhängen, `success({"action": action, "inputs": liste})`
- `func unbind(action: String, input: String) -> bool`
- `func actions_for(input: String) -> Array[String]`: Aktionen mit dieser Eingabe, sortiert
- `func to_dict() -> Dictionary` und `static func from_dict(d: Dictionary) -> ActionMap` (Eingaben elementweise mit `str(...)`, ungültige weglassen)

## Tests
`tests/test_action_map.gd`, `setup()`: `map = ActionMap.new()`, `map.add_action("springen")`, `map.add_action("schiessen")`:
- `test_gueltig`: `is_valid_input("taste:Space")` und `is_valid_input("maus:links")` wahr; `is_valid_input("taste:Quatsch")` und `is_valid_input("maus:oben")` falsch
- `test_belegen`: `bind("springen", "taste:Space")` ok, `data["inputs"]` `["taste:Space"]`; nochmal → weiter 1 Eingabe
- `test_fehler`: `bind("laufen", "taste:A")` → „not_found“; `bind("springen", "taste:Quatsch")` → „invalid_argument“
- `test_rueckwaerts`: `taste:Space` an beide Aktionen binden → `actions_for("taste:Space")` `["schiessen", "springen"]`
- `test_speichern`: belegen, `ActionMap.from_dict(map.to_dict()).actions_for("taste:Space")` `["springen"]`

Review (19.10.2026): gemergt, nachgebessert: Block-Kommentare ersetzt, actions_for typisiert.
