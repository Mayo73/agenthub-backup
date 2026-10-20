extends "res://tests/base_test.gd"

var timeline_view: TimelineView
var evolution_timeline: EvolutionTimeline


func setup() -> void:
	timeline_view = TimelineView.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(timeline_view)
	evolution_timeline = EvolutionTimeline.new()


func teardown() -> void:
	if timeline_view and not timeline_view.is_inside_tree():
		timeline_view.free()


func test_eintraege() -> void:
	evolution_timeline.add("start", "Start", Diet.PFLANZENFRESSER, 0.0, Color.TURQUOISE, "zelle")
	evolution_timeline.add(EvolutionTimeline.START, "Erste Teilung", Diet.FLEISCHFRESSER, 60.0, Color.ORANGE, "zelle")
	evolution_timeline.add(EvolutionTimeline.STAGE, "Abschnitt 1", Diet.ALLESFRESSER, 120.0, Color.PINK, "fisch")

	timeline_view.show_timeline(evolution_timeline)
	check_eq(timeline_view.item_count(), 3, "item_count() ist 3 nach 3 Einträgen")


func test_neu_zeigen() -> void:
	# Erst 3 Einträge
	evolution_timeline.add("start", "Start", Diet.PFLANZENFRESSER, 0.0, Color.TURQUOISE, "zelle")
	evolution_timeline.add(EvolutionTimeline.START, "Erste Teilung", Diet.FLEISCHFRESSER, 60.0, Color.ORANGE, "zelle")
	evolution_timeline.add(EvolutionTimeline.STAGE, "Abschnitt 1", Diet.ALLESFRESSER, 120.0, Color.PINK, "fisch")
	timeline_view.show_timeline(evolution_timeline)
	check_eq(timeline_view.item_count(), 3, "item_count() ist 3 nach ersten 3 Einträgen")

	# Dann ein Zeitstrahl mit 1 Eintrag (soll die alten entfernen und durch 1 ersetzen)
	evolution_timeline.entries.clear()
	evolution_timeline.add(EvolutionTimeline.EDITOR, "Editor", Diet.PFLANZENFRESSER, 300.0, Color.GREEN)
	timeline_view.show_timeline(evolution_timeline)
	check_eq(timeline_view.item_count(), 1, "item_count() ist 1 nach neuem Zeitstrahl mit 1 Eintrag")


func test_statistik() -> void:
	var lines: Array[String] = ["a", "b"]
	timeline_view.show_stats(lines)
	check_eq(timeline_view.stats_label.text, "a\nb", "stats_label.text ist 'a\\nb'")


func test_titel() -> void:
	check_eq(timeline_view.title_label.text, "Deine Entwicklung", "title_label.text ist 'Deine Entwicklung'")


func test_viele_eintraege() -> void:
	for i in range(20):
		evolution_timeline.add_without_phase("schritt", "S%d" % i, Diet.PFLANZENFRESSER, float(i), Color.TURQUOISE)
	timeline_view.show_timeline(evolution_timeline)
	check_eq(timeline_view.item_count(), 12, "item_count() ist 12 bei 20 Einträgen")
	check(timeline_view.more_label.visible, "more_label.visible ist wahr bei vielen Einträgen")
	check_eq(timeline_view.more_label.text, "+8 frühere", "more_label.text ist '+8 frühere'")


func test_wenige_eintraege() -> void:
	evolution_timeline.add_without_phase("schritt", "S0", Diet.PFLANZENFRESSER, 0.0, Color.TURQUOISE)
	evolution_timeline.add_without_phase("schritt", "S1", Diet.FLEISCHFRESSER, 1.0, Color.ORANGE)
	evolution_timeline.add_without_phase("schritt", "S2", Diet.ALLESFRESSER, 2.0, Color.PINK)
	timeline_view.show_timeline(evolution_timeline)
	check_eq(timeline_view.item_count(), 3, "item_count() ist 3 bei 3 Einträgen")
	check(not timeline_view.more_label.visible, "more_label.visible ist falsch bei wenigen Einträgen")


func test_letzte_gezeigt() -> void:
	for i in range(20):
		evolution_timeline.add_without_phase("schritt", "S%d" % i, Diet.PFLANZENFRESSER, float(i), Color.TURQUOISE)
	timeline_view.show_timeline(evolution_timeline)
	var children := timeline_view.strip.get_children()
	var last_item := children[children.size() - 1] as TimelineItem
	check_eq(last_item.entry["label"], "S19", "letztes Kind ist TimelineItem mit label 'S19'")
