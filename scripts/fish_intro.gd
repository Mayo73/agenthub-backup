class_name FishIntro
extends CanvasLayer
## Übergangsbildschirm zu Beginn der Fischphase: zeigt, was aus der Zelle geworden ist.
## Schließt sich nach DURATION Sekunden oder mit dem Knopf "Losschwimmen".

signal closed

const DURATION := 8.0

var title_label: Label
var lines_box: VBoxContainer
var timeline_view: TimelineView
var go_button: Button
var time_left := 0.0


func _init() -> void:
	layer = 15
	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color(0.02, 0.12, 0.18, 0.85)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var box := VBoxContainer.new()
	box.name = "Box"
	box.position = Vector2(560, 220)
	box.add_theme_constant_override("separation", 14)
	box.custom_minimum_size = Vector2(1300, 144)
	add_child(box)
	title_label = Label.new()
	title_label.name = "Title"
	title_label.text = "Aus deiner Zelle wird ein Fisch"
	title_label.add_theme_font_size_override("font_size", 48)
	box.add_child(title_label)
	lines_box = VBoxContainer.new()
	lines_box.name = "Lines"
	box.add_child(lines_box)
	timeline_view = TimelineView.new()
	timeline_view.name = "Timeline"
	timeline_view.use_compact(Vector2(1300, 144))
	timeline_view.custom_minimum_size = Vector2(1300, 144)
	box.add_child(timeline_view)
	go_button = Button.new()
	go_button.name = "Go"
	go_button.text = "Losschwimmen"
	go_button.custom_minimum_size = Vector2(400, 56)
	box.add_child(go_button)
	go_button.pressed.connect(close)
	visible = false


## Zeigt die Zeilen von FishStart.summary_lines(fish) und startet die Anzeigedauer.
func open(fish: FishBuild) -> void:
	for child in lines_box.get_children():
		lines_box.remove_child(child)
		child.free()
	for line in FishStart.summary_lines(fish):
		var l := Label.new()
		l.text = line
		l.add_theme_font_size_override("font_size", 28)
		lines_box.add_child(l)
	time_left = DURATION
	visible = true


## Zeigt den Zeitstrahl mit Leiste und Zeilen; bei leerem Zeitstrahl bleibt die Leiste unsichtbar.
func show_timeline(t: EvolutionTimeline) -> void:
	if t.size() == 0:
		timeline_view.visible = false
		return
	timeline_view.show_timeline(t)
	timeline_view.visible = true
	for line in t.summary_lines():
		var l := Label.new()
		l.text = line
		l.add_theme_font_size_override("font_size", 24)
		lines_box.add_child(l)


func close() -> void:
	if not visible:
		return
	visible = false
	time_left = 0.0
	closed.emit()


func tick(delta: float) -> void:
	if not visible:
		return
	time_left -= delta
	if time_left <= 0.0:
		close()


func _process(delta: float) -> void:
	tick(delta)
