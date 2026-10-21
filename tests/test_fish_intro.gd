extends "res://tests/base_test.gd"

var intro: FishIntro


func setup() -> void:
	intro = FishIntro.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(intro)


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


func test_zeitstrahl() -> void:
	var timeline := EvolutionTimeline.new()
	timeline.add("build", "Schwanzflosse", Diet.PFLANZENFRESSER, 0.0, Color.GREEN, "fisch")
	timeline.add("upgrade", "Sichtweite", Diet.PFLANZENFRESSER, 1.0, Color.BLUE, "fisch")
	check_eq(timeline.size(), 2, "Timeline hat 2 Einträge")
	intro.show_timeline(timeline)
	check_eq(intro.timeline_view.item_count(), 2, "timeline_view.item_count() ist 2")
	check(intro.timeline_view.visible, "timeline_view.visible soll wahr sein")
	var lines := intro.lines_box.get_children()
	check(lines.size() > 0, "mindestens ein Label in lines_box")
	if lines.size() > 0:
		var first_line := lines[0] as Label
		check("Entwicklungsschritte: 2" in first_line.text, "Label hat Text 'Entwicklungsschritte: 2'")


func test_leer() -> void:
	var timeline := EvolutionTimeline.new()
	intro.show_timeline(timeline)
	check(not intro.timeline_view.visible, "timeline_view.visible soll falsch sein bei leerem Zeitstrahl")
