class_name VersionCheck
extends RefCounted
## Statische Hilfsfunktionen zum Vergleichen von Versionsnummern (1.2.3) und Prüfen von Anforderungen.

## Teile eine Versionszeichenkette an `.` auf und gib `[major, minor, patch]` zurück.
## Genau drei Teile erforderlich; jeder Teil muss `is_valid_int()` sein und >= 0.
## Sonst: `[]`.
static func parse(version: String) -> Array[int]:
	var parts := version.split(".", false)
	if parts.size() != 3:
		return []
	var result := [0, 0, 0] as Array[int]
	for i in range(3):
		if not parts[i].is_valid_int():
			return []
		var n := int(parts[i])
		if n < 0:
			return []
		result[i] = n
	return result


## Vergleiche zwei Versionen (a, b). Gib -1, 0 oder 1 zurück.
## Teil für Teil-Vergleich (major, minor, patch).
## Ist eine Version ungültig → 0.
static func compare(a: String, b: String) -> int:
	var pa := parse(a)
	var pb := parse(b)
	if pa.size() != 3 or pb.size() != 3:
		return 0
	for i in range(3):
		if pa[i] < pb[i]:
			return -1
		elif pa[i] > pb[i]:
			return 1
	return 0


## Prüfe, ob `version` eine `requirement` erfüllt.
## Anforderung ist: `">=x.y.z"`, `"<x.y.z"` oder `"=x.y.z"`. Leere Anforderung → wahr.
## `">="` vor `"="` prüfen (also `">="` erkennen, nicht als `"="` behandeln).
## Unbekannter Operator oder ungültige Version → falsch.
static func satisfies(version: String, requirement: String) -> bool:
	# Leere Anforderung gilt immer als erfüllt
	if requirement.is_empty():
		return true

	var op: String
	var req_version: String

	if requirement.begins_with(">="):
		op = ">="
		req_version = requirement.substr(2)
	elif requirement.begins_with("<"):
		op = "<"
		req_version = requirement.substr(1)
	elif requirement.begins_with("="):
		op = "="
		req_version = requirement.substr(1)
	else:
		# Unbekannter Operator
		return false

	var v_parts := parse(version)
	var r_parts := parse(req_version)

	if v_parts.size() != 3 or r_parts.size() != 3:
		return false

	if op == ">=":
		return _compare_arrays(v_parts, r_parts) >= 0
	elif op == "<":
		return _compare_arrays(v_parts, r_parts) < 0
	elif op == "=":
		return _compare_arrays(v_parts, r_parts) == 0

	return false


## Interner Vergleich für zwei Arrays von Int-Werten. Gib -1, 0 oder 1 zurück.
static func _compare_arrays(a: Array[int], b: Array[int]) -> int:
	for i in range(3):
		if a[i] < b[i]:
			return -1
		elif a[i] > b[i]:
			return 1
	return 0


## Prüfe, ob `version` für `what` die `requirement` erfüllt.
## Erfüllt: `CommandResult.success({"version": version})`.
## Sonst: `CommandResult.error(CommandResult.INCOMPATIBLE, ...)`.
static func check(what: String, version: String, requirement: String) -> CommandResult:
	if satisfies(version, requirement):
		return CommandResult.success({"version": version})
	else:
		return CommandResult.error(CommandResult.INCOMPATIBLE, "%s %s erfüllt %s nicht" % [what, version, requirement])
