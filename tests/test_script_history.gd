extends "res://tests/base_test.gd"

var history: ScriptHistory


func setup() -> void:
	history = ScriptHistory.new()


func test_gueltig() -> void:
	var p := "res://verhalten/tuer.gd"
	var result := history.submit(p, "v1", true)
	check_eq(result.code, "ok", "success code")
	check_eq(history.current(p), "v1", "current after submit")
	check_eq(history.version_count(p), 1, "version count after first")


func test_fehler_behaelt_stand() -> void:
	var p := "res://verhalten/tuer.gd"
	history.submit(p, "v1", true)
	var result := history.submit(p, "kaputt", false, "Zeile 3: unbekannter Bezeichner")
	check_eq(result.code, "failed", "error code for bad script")
	check_eq(result.data.get("restored", ""), "v1", "restored value in data")
	check(result.message.contains("letzte gültige Stand"), "message contains fallback text")
	check_eq(history.current(p), "v1", "current remains v1 after error")
	check(history.has_error(p), "has_error is true after error")
	history.submit(p, "v2", true)
	check(not history.has_error(p), "has_error false after valid submit")


func test_zurueck() -> void:
	var p := "res://verhalten/tuer.gd"
	history.submit(p, "v1", true)
	history.submit(p, "v2", true)
	check(history.revert(p), "revert returns true with enough versions")
	check_eq(history.current(p), "v1", "current after first revert")
	check(not history.revert(p), "revert returns false with less than 2 versions")


func test_grenze() -> void:
	var p := "res://verhalten/tuer.gd"
	for i in range(12):
		history.submit(p, "v%d" % (i + 1), true)
	check_eq(history.version_count(p), 10, "max versions kept")
	check_eq(history.current(p), "v12", "last version is current")
