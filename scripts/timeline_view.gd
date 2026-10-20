class_name TimelineView
extends Control
## Leiste mit Einträgen einer EvolutionTimeline: je ein Bild der Lebensform mit farbigem Rand.
## Im Spiel als Vollbild (mit Titel und Statistik), im Zelleditor als schmale Leiste ohne Titel.

const ITEM_SIZE := Vector2(96, 120)
const GAP := 12.0
const MAX_ITEMS := 12

var timeline: EvolutionTimeline
var backdrop: ColorRect
var content: VBoxContainer
var strip: HBoxContainer
var title_label: Label
var more_label: Label
var stats_label: Label


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop = ColorRect.new()
	backdrop.name = "Backdrop"
	backdrop.color = Color(0.02, 0.08, 0.12, 0.82)
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	content = VBoxContainer.new()
	content.name = "Content"
	content.position = Vector2(GAP, GAP)
	content.add_theme_constant_override("separation", int(GAP))
	add_child(content)
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "Deine Entwicklung"
	title_label.add_theme_font_size_override("font_size", 40)
	content.add_child(title_label)
	strip = HBoxContainer.new()
	strip.name = "Strip"
	strip.add_theme_constant_override("separation", int(GAP))
	content.add_child(strip)
	more_label = Label.new()
	more_label.name = "More"
	more_label.set("theme_override_colors/font_color", Color(1, 1, 1, 0.7))
	more_label.add_theme_font_size_override("font_size", 22)
	content.add_child(more_label)
	stats_label = Label.new()
	stats_label.name = "StatsLabel"
	stats_label.add_theme_font_size_override("font_size", 22)
	content.add_child(stats_label)


## Vollbild im Spiel: Titel, Leiste und Statistik mit Abstand zum Rand.
func use_fullscreen() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	content.position = Vector2(80, 80)


## Schmale Leiste (Zelleditor): nur die Bilder, ohne Titel und Statistik.
func use_compact(box_size: Vector2) -> void:
	size = box_size
	title_label.visible = false
	stats_label.visible = false
	content.position = Vector2(GAP, GAP)


func show_timeline(t: EvolutionTimeline) -> void:
	timeline = t
	for child in strip.get_children():
		child.free()
	var entry_start := 0
	if timeline.entries.size() > MAX_ITEMS:
		entry_start = timeline.entries.size() - MAX_ITEMS
		more_label.text = "+%d frühere" % (timeline.entries.size() - MAX_ITEMS)
		more_label.visible = true
	else:
		more_label.visible = false
	for i in range(entry_start, timeline.entries.size()):
		var entry := timeline.entries[i]
		var item := TimelineItem.create(entry)
		item.custom_minimum_size = ITEM_SIZE
		strip.add_child(item)


func show_stats(lines: Array[String]) -> void:
	stats_label.text = "\n".join(lines)


func item_count() -> int:
	return strip.get_child_count()
