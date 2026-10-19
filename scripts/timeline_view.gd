class_name TimelineView
extends Control
## Leiste mit Einträgen einer EvolutionTimeline: je ein Bild der Lebensform mit farbigem Rand.

const ITEM_SIZE := Vector2(96, 120)

var timeline: EvolutionTimeline
var strip: HBoxContainer
var title_label: Label
var stats_label: Label


func _init() -> void:
	strip = HBoxContainer.new()
	strip.name = "Strip"
	add_child(strip)

var timeline_shown := false

func _ready() -> void:
	# Set spacing after _ready is called, when type checking is complete
	var temp_spacing: float = 12.0
	strip.set("spacing", int(temp_spacing))

	title_label = Label.new()
	title_label.name = "titleLabel"
	title_label.text = "Deine Entwicklung"
	title_label.add_theme_font_size_override("font_size", 24)
	add_child(title_label)

	stats_label = Label.new()
	stats_label.name = "StatsLabel"
	stats_label.add_theme_font_size_override("font_size", 18)
	add_child(stats_label)

	if timeline_shown:
		title_label.visible = false


func show_timeline(t: EvolutionTimeline) -> void:
	timeline = t
	timeline_shown = true

	if title_label != null:
		title_label.visible = false

	# Alle Kinder im strip entfernen (mit free())
	for child in strip.get_children():
		child.free()

	# Für jeden Eintrag ein TimelineItem anlegen
	for entry in timeline.entries:
		var item := TimelineItem.create(entry)
		item.custom_minimum_size = ITEM_SIZE
		strip.add_child(item)


func show_stats(lines: Array[String]) -> void:
	stats_label.text = "\n".join(lines)


func item_count() -> int:
	return strip.get_child_count()
