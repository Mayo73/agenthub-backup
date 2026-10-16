extends "res://tests/base_test.gd"


func test_pflanzenfresser() -> void:
	check(Diet.can_eat(Diet.PFLANZENFRESSER, Diet.PFLANZE), "Pflanzenfresser kann Pflanzen essen")
	check(not Diet.can_eat(Diet.PFLANZENFRESSER, Diet.FLEISCH), "Pflanzenfresser kann kein Fleisch essen")


func test_fleischfresser() -> void:
	check(Diet.can_eat(Diet.FLEISCHFRESSER, Diet.FLEISCH), "Fleischfresser kann Fleisch essen")
	check(not Diet.can_eat(Diet.FLEISCHFRESSER, Diet.PFLANZE), "Fleischfresser kann keine Pflanzen essen")


func test_allesfresser() -> void:
	check(Diet.can_eat(Diet.ALLESFRESSER, Diet.PFLANZE), "Allesfresser kann Pflanzen essen")
	check(Diet.can_eat(Diet.ALLESFRESSER, Diet.FLEISCH), "Allesfresser kann Fleisch essen")
	check(not Diet.can_eat("", Diet.PFLANZE), "Leere Ernährungsart kann nichts essen")
	check(not Diet.can_eat(Diet.ALLESFRESSER, "stein"), "Allesfresser kann keinen Stein essen")


func test_aus_mundwerkzeugen() -> void:
	var m: Array[String] = [Diet.FILTERMAUL]
	check_eq(Diet.from_mouths(m), Diet.PFLANZENFRESSER, "Filtermaul → Pflanzenfresser")

	m = [Diet.KIEFER]
	check_eq(Diet.from_mouths(m), Diet.FLEISCHFRESSER, "Kiefer → Fleischfresser")

	m = [Diet.RUESSEL]
	check_eq(Diet.from_mouths(m), Diet.ALLESFRESSER, "Rüssel → Allesfresser")

	m = [Diet.FILTERMAUL, Diet.KIEFER]
	check_eq(Diet.from_mouths(m), Diet.ALLESFRESSER, "Filtermaul + Kiefer → Allesfresser")

	m = []
	check_eq(Diet.from_mouths(m), "", "Keine Mundwerkzeuge → leere Ernährungsart")
