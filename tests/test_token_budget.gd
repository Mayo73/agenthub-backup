extends "res://tests/base_test.gd"


func test_schaetzen() -> void:
	var s1: String = ""
	var s2: String = "abcde"
	check_eq(TokenBudget.estimate(s1), 0, "leerer String hat 0 Token")
	check_eq(TokenBudget.estimate(s2), 2, "'abcde' hat 2 Token")


func test_kuerzen() -> void:
	var entries: Array = ["SSSS", "aaaaaaaa", "bbbbbbbb", "cccccccc"]

	var r1: Array = TokenBudget.trim(entries, 5)
	check_eq(r1, ["SSSS", "bbbbbbbb", "cccccccc"], "Budget 5")

	var r2: Array = TokenBudget.trim(entries, 3)
	check_eq(r2, ["SSSS", "cccccccc"], "Budget 3")


func test_nur_system() -> void:
	var entries: Array = ["SSSS"]
	var r1: Array = TokenBudget.trim(entries, 0)
	check_eq(r1, ["SSSS"], "Nur System mit Budget 0")

	var empty: Array = []
	var r2: Array = TokenBudget.trim(empty, 10)
	check_eq(r2, [], "Leere Liste ergibt []")


func test_alles() -> void:
	var entries: Array = ["SSSS", "aaaaaaaa", "bbbbbbbb", "cccccccc"]
	var r: Array = TokenBudget.trim(entries, 100)
	check_eq(r, entries, "Alle Einträge bei Budget 100 in ursprünglicher Reihenfolge")
