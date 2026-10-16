class_name Hud
extends CanvasLayer
## Anzeige über dem Spiel. Die Knoten werden in _init angelegt, damit Tests ohne Szene auskommen.

var box: VBoxContainer
var dna_label: Label
var growth_bar: ProgressBar
var stage_label: Label


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


func show_progress(progress: CellProgress) -> void:
	dna_label.text = "DNA: %d" % progress.dna
	growth_bar.value = progress.growth_ratio() * 100.0
	stage_label.text = "Größe %d/%d" % [progress.stage + 1, CellProgress.STAGE_COUNT]
