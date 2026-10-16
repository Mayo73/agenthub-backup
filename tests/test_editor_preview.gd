extends "res://tests/base_test.gd"

var a: CellBuild

func setup() -> void:
	a = CellBuild.starter(Diet.PFLANZENFRESSER)


func test_unveraendert() -> void:
	var l := EditorPreview.lines(a, a.copy(), 0)
	check_eq(l.size(), 4, "l.size() ist 4")
	check_eq(l[0], "Tempo: 220", "l[0] ist Tempo: 220")
	check_eq(l[1], "Wendigkeit: 6.0", "l[1] ist Wendigkeit: 6.0")
	check_eq(l[2], "Ernährung: Pflanzenfresser", "l[2] ist Ernährung: Pflanzenfresser")
	check_eq(l[3], "Waffen: keine", "l[3] ist Waffen: keine")


func test_umbau() -> void:
	var b := a.copy()
	b.add_part("geissel", Vector2(-1, 0))
	b.add_part("stachel", Vector2(0, 1))
	b.add_part("kiefer", Vector2(0.9, 0.3))
	check_eq(EditorPreview.lines(a, b, 0)[0], "Tempo: 220 → 280", "lines[0] ist Tempo: 220 → 280")
	check_eq(EditorPreview.lines(a, b, 0)[2], "Ernährung: Pflanzenfresser → Allesfresser", "lines[2] ist Ernährung: Pflanzenfresser → Allesfresser")
	check_eq(EditorPreview.lines(a, b, 0)[3], "Waffen: Stachel", "lines[3] ist Waffen: Stachel")


func test_waffen_einmal() -> void:
	var b := CellBuild.new()
	b.add_part("stachel", Vector2(-1, 0))
	b.add_part("stachel", Vector2(0, 1))
	b.add_part("gift", Vector2(0.9, 0.3))
	var w := EditorPreview.weapons(b)
	check_eq(w.size(), 2, "weapons hat Größe 2")
	check_eq(w[0], "Stachel", "w[0] ist Stachel")
	check_eq(w[1], "Giftdrüse", "w[1] ist Giftdrüse")


func test_namen() -> void:
	check_eq(EditorPreview.diet_name(""), "keine Nahrung", "diet_name(\"\") ist keine Nahrung")
	check_eq(EditorPreview.diet_name(Diet.FLEISCHFRESSER), "Fleischfresser", "diet_name(FLEISCHFRESSER) ist Fleischfresser")


func test_wendigkeit() -> void:
	var b := a.copy()
	b.add_part("wimpern", Vector2(0, 1))
	check_eq(EditorPreview.lines(a, b, 0)[1], "Wendigkeit: 6.0 → 9.0", "lines[1] ist Wendigkeit: 6.0 → 9.0")
