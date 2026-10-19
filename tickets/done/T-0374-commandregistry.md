---
id: T-0374
title: CommandRegistry – Befehle registrieren, prüfen, ausführen, Fähigkeitenverzeichnis
project: hub-engine
priority: 4
---
## Ziel
Meilenstein „Kern: Befehle, Szenen, Revisionen“ (Lastenheft Muss 7, Abnahmekriterium 3): ein gemeinsames Befehlsmodell für GUI, CLI und Agenten mit Parameterprüfung, eindeutigen Fehlercodes und einem Fähigkeitenverzeichnis.

## Dateien
- `core/command_registry.gd` – neu, Klasse `CommandRegistry`
- `tests/test_command_registry.gd` – neu

## Akzeptanzkriterien
`class_name CommandRegistry`, `extends RefCounted`. Ergebnisse sind `CommandResult` (vorhanden in `core/command_result.gd`).
- `const TYPES: Array[String] = ["string", "number", "bool", "dict", "array", "any"]`
- `var commands: Dictionary = {}` – Name → `{"name", "description", "params", "handler"}`
- `func register(name: String, description: String, params: Dictionary, handler: Callable) -> void`: `params` ordnet jedem Parameternamen einen Typ aus `TYPES` zu; alle Parameter sind Pflicht.
- `func has_command(name: String) -> bool`
- `func execute(name: String, args: Dictionary) -> CommandResult`:
  - unbekannt → `CommandResult.error(CommandResult.UNKNOWN_COMMAND, "Unbekannter Befehl: %s" % name)`
  - Parameter fehlt → `INVALID_ARGUMENT`, `"Parameter fehlt: %s"`
  - falscher Typ → `INVALID_ARGUMENT`, `"Parameter %s muss %s sein"` (Name, Typ). `number` nimmt `int` und `float`, `any` alles.
  - sonst `handler.call(args)` und dessen `CommandResult` zurückgeben
- `func type_matches(value: Variant, type_name: String) -> bool` (öffentlich, für die Prüfung oben)
- `func capabilities() -> Array[Dictionary]`: je Befehl `{"name", "description", "params"}` (ohne `handler`), nach Name sortiert

## Tests
`tests/test_command_registry.gd`, in `setup()` `registry = CommandRegistry.new()` und ein Befehl `"math.add"` mit `{"a": "number", "b": "number"}`, dessen Handler `CommandResult.success({"sum": args["a"] + args["b"]})` liefert:
- `test_ausfuehren`: `execute("math.add", {"a": 2, "b": 3.5})` → ok, `data["sum"]` 5.5
- `test_unbekannt`: `execute("gibts.nicht", {})` → Code „unknown_command“, Meldung „Unbekannter Befehl: gibts.nicht“
- `test_parameter_fehlt`: `{"a": 1}` → „invalid_argument“, Meldung „Parameter fehlt: b“
- `test_falscher_typ`: `{"a": 1, "b": "x"}` → „invalid_argument“, Meldung „Parameter b muss number sein“
- `test_typen`: `type_matches("x", "string")`, `type_matches(true, "bool")`, `type_matches({}, "dict")`, `type_matches([], "array")`, `type_matches(null, "any")` wahr; `type_matches(1, "string")` falsch
- `test_verzeichnis`: zusätzlich `"a.first"` registrieren → `capabilities()` Namen `["a.first", "math.add"]`, kein Schlüssel `handler`, `params` von „math.add“ gleich `{"a": "number", "b": "number"}`

Review (19.10.2026): gemergt.
