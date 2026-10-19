---
id: T-0387
title: CliRunner – Befehle über die Befehlszeile ausführen, Ausgabe als JSON
project: hub-engine
priority: 4
after: T-0374, T-0386
---
## Ziel
Meilenstein „Durchstich: Laufzeit, CLI, Editor, Export“ (Lastenheft Muss 7, Abnahmekriterium 3): Die CLI führt jeden registrierten Befehl aus und gibt das Ergebnis maschinenlesbar als JSON aus, mit Exit-Code. So können Agenten die Engine ohne Oberfläche steuern.

## Dateien
- `core/cli_runner.gd` – neu, Klasse `CliRunner`
- `tests/test_cli_runner.gd` – neu

## Akzeptanzkriterien
`class_name CliRunner`, `extends RefCounted`. Nutzt `CommandRegistry` (T-0374) und `CliParser` (T-0386).
- `const EXIT_OK := 0`, `const EXIT_ERROR := 1`, `const EXIT_USAGE := 2`
- `var registry: CommandRegistry`, `func _init(reg: CommandRegistry) -> void`
- `static func result_to_dict(r: CommandResult) -> Dictionary`: `{"ok": r.code == CommandResult.CODE_OK, "code": r.code, "message": r.message, "data": r.data}`
- `func run(argv: PackedStringArray) -> Dictionary`: Rückgabe `{"exit_code": int, "output": String}`
  - `CliParser.parse(argv)` meldet `error` → `exit_code` `EXIT_USAGE`, `output` = `JSON.stringify({"ok": false, "code": "invalid_argument", "message": error, "data": {}})`
  - Befehl `help` (ohne Parameter): `output` = `JSON.stringify({"ok": true, "code": "ok", "message": "", "data": {"commands": registry.capabilities()}})`, `EXIT_OK`
  - sonst `registry.execute(command, args)`; `output` = `JSON.stringify(result_to_dict(r))`; `exit_code` `EXIT_OK` bei Erfolg, sonst `EXIT_ERROR`

## Tests
`tests/test_cli_runner.gd`, in `setup()`: `registry = CommandRegistry.new()`, Befehl `"math.add"` mit `{"a": "number", "b": "number"}` (Handler liefert `CommandResult.success({"sum": args["a"] + args["b"]})`), `runner = CliRunner.new(registry)`. Ausgaben mit `JSON.parse_string` prüfen.
- `test_ausfuehren`: `run(["math.add", "a=2", "b=3"])` → `exit_code` 0, Ausgabe `ok` wahr, `data["sum"]` 5
- `test_unbekannt`: `run(["gibts.nicht"])` → `exit_code` 1, `code` „unknown_command“
- `test_falscher_typ`: `run(["math.add", "a=2", "b=x"])` → `exit_code` 1, `code` „invalid_argument“, `message` „Parameter b muss number sein“
- `test_aufruf_falsch`: `run([])` → `exit_code` 2, `message` „Kein Befehl angegeben“
- `test_hilfe`: `run(["help"])` → `exit_code` 0, `data["commands"].size()` 1, erster Eintrag `name` „math.add“
