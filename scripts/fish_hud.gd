class_name FishHud
extends CanvasLayer
## Anzeige der Fischphase: Tiefe, DNA, Wachstum, Steuerungshilfe und kurze Meldungen.

const HELP := "W / linke Maustaste: schwimmen · A/D: drehen · Leertaste: auftauchen · Umschalt: abtauchen · E: Entwicklung"

var depth_label: Label
var dna_label: Label
var growth_label: Label
var health_label: Label
var help_label: Label
var message_label: Label
var message_left := 0.0


func _init() -> void:
	layer = 5
	depth_label = make_label("Depth", Vector2(40, 30), 32)
	dna_label = make_label("Dna", Vector2(40, 76), 28)
	growth_label = make_label("Growth", Vector2(40, 116), 28)
	health_label = make_label("Health", Vector2(40, 156), 28)
	show_health(1.0)
	help_label = make_label("Help", Vector2(40, 1010), 22)
	help_label.text = HELP
	message_label = make_label("Message", Vector2(560, 140), 30)
	message_label.visible = false
	show_depth(FishWorld.depth_of(FishWorld.START))
	show_progress(FishProgress.new())


func make_label(label_name: String, pos: Vector2, font_size: int) -> Label:
	var l := Label.new()
	l.name = label_name
	l.position = pos
	l.add_theme_font_size_override("font_size", font_size)
	add_child(l)
	return l


static func depth_text(depth: float) -> String:
	return "Tiefe: %d m" % roundi(depth)


static func growth_text(progress: FishProgress) -> String:
	if progress.is_final_stage():
		return "Wachstum: ausgewachsen"
	return "Wachstum: %d / %d" % [progress.growth, FishProgress.GROWTH_NEEDED[progress.stage]]


func show_depth(depth: float) -> void:
	depth_label.text = depth_text(depth)


func show_progress(progress: FishProgress) -> void:
	dna_label.text = "DNA: %d" % progress.dna
	growth_label.text = growth_text(progress)


func show_message(text: String, seconds: float = 4.0) -> void:
	message_label.text = text
	message_label.visible = true
	message_left = seconds


static func health_text(ratio: float) -> String:
	return "Gesundheit: %d %%" % roundi(clampf(ratio, 0.0, 1.0) * 100.0)


func show_health(ratio: float) -> void:
	health_label.text = health_text(ratio)


func tick(delta: float) -> void:
	if message_left <= 0.0:
		return
	message_left -= delta
	if message_left <= 0.0:
		message_label.visible = false


func _process(delta: float) -> void:
	tick(delta)
