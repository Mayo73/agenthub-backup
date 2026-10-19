class_name CommandResult
extends RefCounted
## Ergebnis eines Befehls oder einer Abfrage. Gleich für GUI, CLI und Agenten.
## Fehlercodes sind feste, dokumentierte Zeichenketten (siehe docs/ARCHITEKTUR.md).

const CODE_OK := "ok"
const UNKNOWN_COMMAND := "unknown_command"
const INVALID_ARGUMENT := "invalid_argument"
const NOT_FOUND := "not_found"
const CONFLICT := "conflict"
const FORBIDDEN_PATH := "forbidden_path"
const DEPENDENCY := "dependency"
const INCOMPATIBLE := "incompatible"
const EXEC_FAILED := "failed"

var code := CODE_OK
var message := ""
var data: Dictionary = {}


static func success(result_data: Dictionary = {}, text: String = "") -> CommandResult:
	var r := CommandResult.new()
	r.data = result_data
	r.message = text
	return r


static func error(error_code: String, text: String, result_data: Dictionary = {}) -> CommandResult:
	var r := CommandResult.new()
	r.code = error_code
	r.message = text
	r.data = result_data
	return r


func is_ok() -> bool:
	return code == CODE_OK


func to_dict() -> Dictionary:
	return {"ok": is_ok(), "code": code, "message": message, "data": data}
