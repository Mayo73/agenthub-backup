extends "res://tests/base_test.gd"

var timeline_view: TimelineView
var evolution_timeline: EvolutionTimeline


func setup() -> void:
	timeline_view = TimelineView.new()
	(Engine.get_main_loop() as SceneTree).root.add_child(timeline_view)
	evolution_timeline = EvolutionTimeline.new()


func teardown() -> void:
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
