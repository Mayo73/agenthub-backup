extends "res://tests/base_test.gd"

var intro: FishIntro


func setup() -> void:
	intro = FishIntro.new()


func teardown() -> void:
	intro.free()


func test_neu() -> void:
	check(not intro.visible, "intro.visible soll falsch sein")
	check_eq(intro.title_label.text, "Aus deiner Zelle wird ein Fisch", "title_label.text stimmt")


func test_oeffnen() -> void:
	var f := FishBuild.new()
	f.upgrade("schwanz")
	intro.open(f)
	check(intro.visible, "intro.visible soll wahr sein nach open()")
	check_eq(intro.lines_box.get_child_count(), 2, "lines_box hat 2 Kinder")
	check_eq((intro.lines_box.get_child(1) as Label).text, "Schwanzflosse: Stufe 1", "zweiter Label-Text stimmt")


func test_zweimal_oeffnen() -> void:
	intro.open(FishBuild.new())
	intro.open(FishBuild.new())
	check_eq(intro.lines_box.get_child_count(), 1, "lines_box hat nach zweimal open() nur 1 Kind")


func test_zeit() -> void:
	var got := [0]
	intro.closed.connect(func() -> void: got[0] += 1)
	intro.open(FishBuild.new())
	check(intro.visible, "intro.visible soll wahr sein nach 7s")
	intro.tick(7.0)
	intro.tick(1.5)
	check(not intro.visible, "intro.visible soll falsch sein nach 8.5s")
	check_eq(got[0], 1, "closed wurde einmal emittiert")
	intro.tick(1.0)
	check_eq(got[0], 1, "closed bleibt bei 1 nach erneutem tick")


func test_knopf() -> void:
	intro.open(FishBuild.new())
	intro.go_button.pressed.emit()
	check(not intro.visible, "intro.visible soll falsch sein nach Knopfdruck")
