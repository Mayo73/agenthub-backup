class_name Hud
extends CanvasLayer
## Anzeige über dem Spiel. Die Knoten werden in _init angelegt, damit Tests ohne Szene auskommen.

var box: VBoxContainer
var dna_label: Label
var growth_bar: ProgressBar
var stage_label: Label
var health_bar: ProgressBar
var message_label: Label
var message_time := 0.0


func _init() -> void:
	box = VBoxContainer.new()
	box.name = "Box"
	box.position = Vector2(24, 24)
	add_child(box)
	dna_label = Label.new()
	dna_label.name = "Dna"
	dna_label.add_theme_font_size_override("font_size", 28)
	box.add_child(dna_label)
	growth_bar = ProgressBar.new()
	growth_bar.name = "Growth"
	growth_bar.custom_minimum_size = Vector2(260, 18)
	growth_bar.max_value = 100.0
	growth_bar.show_percentage = false
	box.add_child(growth_bar)
	stage_label = Label.new()
	stage_label.name = "Stage"
	stage_label.add_theme_font_size_override("font_size", 22)
	box.add_child(stage_label)
	health_bar = ProgressBar.new()
	health_bar.name = "Health"
	health_bar.custom_minimum_size = Vector2(260, 14)
	health_bar.max_value = 100.0
	health_bar.value = 100.0
	health_bar.show_percentage = false
	health_bar.modulate = Color(1.0, 0.45, 0.45)
	box.add_child(health_bar)
	message_label = Label.new()
	message_label.name = "Message"
	message_label.add_theme_font_size_override("font_size", 30)
	message_label.position = Vector2(24, 980)
	add_child(message_label)


func show_progress(progress: CellProgress) -> void:
	dna_label.text = "DNA: %d" % progress.dna
	growth_bar.value = progress.growth_ratio() * 100.0
	stage_label.text = "Größe %d/%d" % [progress.stage + 1, CellProgress.STAGE_COUNT]


func show_health(health: CellHealth) -> void:
	health_bar.value = health.ratio() * 100.0


## Zeigt eine Meldung für seconds Sekunden.
func show_message(text: String, seconds: float = 3.0) -> void:
	message_label.text = text
	message_time = seconds


func _process(delta: float) -> void:
	if message_time > 0.0:
		message_time -= delta
		if message_time <= 0.0:
			message_label.text = ""
